import Fluent
import Vapor

enum PaymentType: CustomStringConvertible, Equatable {
    case cash
    case loan
    var description: String {
        switch self {
        case .cash:
            return "Efectivo"
        case .loan:
            return "Fiado"
        }
    }
    var icon: String {
        switch self {
        case .cash:
            return "dollarsign"
        case .loan:
            return "list.clipboard"
        }
    }
    static var allValues: [PaymentType] {
        return [.cash, .loan]
    }
    static func == (lhs: PaymentType, rhs: PaymentType) -> Bool {
        return lhs.description == rhs.description
    }
    static func from(description: String) throws -> PaymentType? {
//        for case let tipo in PaymentType.allValues where tipo.description == description {
//            return tipo
//        }
        var result: PaymentType?
        for tipo in PaymentType.allValues {
            if tipo.description == description {
                result = tipo
            }
        }
        return result
    }
}

enum SaleError: Error {
    case alreadyExist
}

// Implementa el protocolo AbortError para proporcionar más información sobre el error
extension SaleError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .alreadyExist:
            return .internalServerError
        }
    }

    var reason: String {
        switch self {
        case .alreadyExist:
            return "Ya hay una venta con el mismo ID"
        }
    }
}

enum SaleDetailError: Error {
    case alreadyExist
}

// Implementa el protocolo AbortError para proporcionar más información sobre el error
extension SaleDetailError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .alreadyExist:
            return .internalServerError
        }
    }

    var reason: String {
        switch self {
        case .alreadyExist:
            return "Ya hay una detalle de venta con el mismo ID"
        }
    }
}

struct SaleController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let sales = routes.grouped("sales")
        sales.post("sync", use: sync)
        sales.post(use: save)
    }
    func sync(req: Request) async throws -> [SaleDTO] {
        //Precicion de segundos solamente
        //No se requiere mas precicion ya que el objetivo es sincronizar y en caso haya repetidos esto se mitiga en la app
        let request = try req.content.decode(SyncFromSubsidiaryParameters.self)
        
        let query = Sale.query(on: req.db)
            .filter(\.$updatedAt >= request.updatedSince)
            .sort(\.$updatedAt, .ascending)
            .with(\.$toSaleDetail) { saleDetail in
                saleDetail.with(\.$imageUrl)
            }
            .limit(50)
        
        let sales = try await query.all()
        
        return sales.mapToListSaleDTO()
    }
    func save2(req: Request) async throws -> DefaultResponse {
        let saleDTO = try req.content.decode(SaleDTO.self)
        let saleDetails = saleDTO.saleDetail.mapToListSaleDetail()
        return try await req.db.transaction { transaction in
            if try await Sale.find(saleDTO.id, on: transaction) != nil {
                //Las Ventas no se modifican
                throw SaleError.alreadyExist
            } else {
                try await saleDTO.toSale().save(on: transaction)
                for saleDetail in saleDetails {
                    if try await SaleDetail.find(saleDetail.id, on: transaction) != nil {
                        //El detalle de las ventas no se modifican
                        throw SaleDetailError.alreadyExist
                    } else {
                        try await saleDetail.save(on: transaction)
                    }
                }
            }
            return DefaultResponse(code: 200, message: "Ok")
        }
    }
    func save(req: Request) async throws -> DefaultResponse {
        let saleTransactionDTO = try req.content.decode(SaleTransactionDTO.self)
        let date: Date = Date()
        guard saleTransactionDTO.cart.cartDetails.isEmpty else {
            print("No se encontro productos en la solicitud de venta")
            throw Abort(.badRequest, reason: "No se encontro productos en la solicitud de venta")
        }
        guard let paymentType = try PaymentType.from(description: saleTransactionDTO.paymentType) else {
            print("El tipo de Pago no existe")
            throw Abort(.badRequest, reason: "El tipo de Pago no existe")
        }
        let saleId = UUID()
        let saleNew = Sale(
            id: saleId,
            paymentType: paymentType.description,
            saleDate: date,
            total: saleTransactionDTO.cart.total,
            subsidiaryID: saleTransactionDTO.subsidiaryId,
            customerID: saleTransactionDTO.customerId,
            employeeID: saleTransactionDTO.employeeId
        )
        //Agregamos detalles a la venta
        try await req.db.transaction { transaction in
            if let customer = try await Customer.find(saleTransactionDTO.customerId, on: transaction) {
                customer.lastDatePurchase = date
                if customer.totalDebt == 0 {
                    var calendario = Calendar.current
                    calendario.timeZone = TimeZone(identifier: "UTC")!
                    customer.dateLimit = calendario.date(byAdding: .day, value: customer.creditDays, to: date)!
                }
                if paymentType == .loan {
                    customer.firstDatePurchaseWithCredit = customer.totalDebt == 0 ? date : customer.firstDatePurchaseWithCredit
                    customer.totalDebt = customer.totalDebt + saleTransactionDTO.cart.total
                    if customer.totalDebt > customer.creditLimit && customer.isCreditLimitActive {
                        customer.isCreditLimit = true
                    } else {
                        customer.isCreditLimit = false
                    }
                }
                try await customer.save(on: transaction)
            }
            for cartDetailDTO in saleTransactionDTO.cart.cartDetails {
                let product = try await reduceStock(cartDetailDTO: cartDetailDTO, db: transaction)
                try await product.save(on: transaction)
                let saleDetailNew = SaleDetail(
                    id: UUID(),
                    productName: cartDetailDTO.product.productName,
                    barCode: cartDetailDTO.product.barCode,
                    quantitySold: cartDetailDTO.quantity,
                    subtotal: cartDetailDTO.subtotal,
                    unitType: cartDetailDTO.product.unitType, //Enum
                    unitCost: cartDetailDTO.product.unitCost,
                    unitPrice: cartDetailDTO.product.unitPrice,
                    saleID: saleId,
                    imageUrlID: cartDetailDTO.product.imageUrlId
                )
                try await saleDetailNew.save(on: transaction)
            }
            try await saleNew.save(on: transaction)
        }
        return DefaultResponse(code: 200, message: "Ok")
    }
    private func reduceStock(cartDetailDTO: CartDetailDTO, db: any Database) async throws -> Product {
        guard let product = try await Product.find(cartDetailDTO.product.id, on: db) else {
            print("No se encontro este producto en la BD")
            throw Abort(.badRequest, reason: "No se encontro este producto en la BD")
        }
        if product.quantityStock >= cartDetailDTO.quantity {
            product.quantityStock -= cartDetailDTO.quantity
            return product
        } else {
            print("No hay stock suficiente")
            throw Abort(.badRequest, reason: "No hay stock suficiente")
        }
    }
}

struct SaleTransactionDTO: Content {
    let subsidiaryId: UUID
    let employeeId: UUID
    let customerId: UUID?
    let paymentType: String
    let cart: CartDTO
}
