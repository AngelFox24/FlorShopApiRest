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
    func sync(req: Request) async throws -> SyncSalesResponse {
        let request = try req.content.decode(SyncFromSubsidiaryParameters.self)
        guard try SyncTimestamp.shared.shouldSync(clientSyncIds: request.syncIds, entity: .sale) else {
            return SyncSalesResponse(
                salesDTOs: [],
                syncIds: SyncTimestamp.shared.getLastSyncDate()
            )
        }
        let maxPerPage: Int = 50
        let query = Sale.query(on: req.db)
            .filter(\.$updatedAt >= request.updatedSince)
            .sort(\.$updatedAt, .ascending)
            .with(\.$toSaleDetail) { saleDetail in
                saleDetail.with(\.$imageUrl)
            }
            .limit(50)
        let sales = try await query.all()
        return SyncSalesResponse(
            salesDTOs: sales.mapToListSaleDTO(),
            syncIds: sales.count == maxPerPage ? SyncTimestamp.shared.getLastSyncDateTemp(entity: .sale) : SyncTimestamp.shared.getLastSyncDate()
        )
    }
    func save(req: Request) async throws -> DefaultResponse {
        let saleTransactionDTO = try req.content.decode(RegisterSaleParameters.self)
        let date: Date = Date()
        guard !saleTransactionDTO.cart.cartDetails.isEmpty else {
            print("No se encontro productos en la solicitud de venta")
            throw Abort(.badRequest, reason: "No se encontro productos en la solicitud de venta")
        }
        guard let paymentType = try PaymentType.from(description: saleTransactionDTO.paymentType) else {
            print("El tipo de Pago no existe")
            throw Abort(.badRequest, reason: "El tipo de Pago no existe")
        }
        guard let subsidiaryId = try await Subsidiary.find(saleTransactionDTO.subsidiaryId, on: req.db)?.id else {
            throw Abort(.badRequest, reason: "La subsidiaria no existe")
        }
        guard let employeeId = try await Employee.find(saleTransactionDTO.employeeId, on: req.db)?.id else {
            throw Abort(.badRequest, reason: "El empleado no existe")
        }
        //Agregamos detalles a la venta
        try await req.db.transaction { transaction in
            var customerEntityPN: Customer?
            if let customerId = saleTransactionDTO.customerId {//Si quiere registrar un cliente este debe existir sino no se puede registrar la venta
                guard let customerEntity = try await Customer.find(customerId, on: transaction) else {
                    throw Abort(.badRequest, reason: "El cliente no existe")
                }
                customerEntityPN = customerEntity
            }
            let saleId = UUID()
            let saleNew = Sale(
                id: saleId,
                paymentType: paymentType.description,
                saleDate: date,
                total: saleTransactionDTO.cart.total,
                subsidiaryID: subsidiaryId,
                customerID: customerEntityPN?.id,
                employeeID: employeeId
            )
            try await saleNew.save(on: transaction)
            var totalOwn = 0
            for cartDetailDTO in saleTransactionDTO.cart.cartDetails {
                let product = try await reduceStock(cartDetailDTO: cartDetailDTO, db: transaction)
                try await product.update(on: transaction)
                let saleDetailNew = SaleDetail(
                    id: UUID(),
                    productName: product.productName,
                    barCode: product.barCode,
                    quantitySold: cartDetailDTO.quantity,
                    subtotal: cartDetailDTO.subtotal,
                    unitType: product.unitType, //Enum
                    unitCost: product.unitCost,
                    unitPrice: product.unitPrice,
                    saleID: saleId,
                    imageUrlID: product.imageUrl?.id
                )
                try await saleDetailNew.save(on: transaction)
                totalOwn += cartDetailDTO.quantity * product.unitPrice
            }
            guard totalOwn == saleTransactionDTO.cart.total else {
                print("Monto no coincide con el calculo de la BD, calculo real: \(totalOwn) calculo enviado: \(saleTransactionDTO.cart.total)")
                throw Abort(.badRequest, reason: "Monto no coincide con el calculo de la BD, calculo real: \(totalOwn) calculo enviado: \(saleTransactionDTO.cart.total)")
            }
            if let customerEntity = customerEntityPN {
                customerEntity.lastDatePurchase = date
                if customerEntity.totalDebt == 0 {
                    var calendario = Calendar.current
                    calendario.timeZone = TimeZone(identifier: "UTC")!
                    customerEntity.dateLimit = calendario.date(byAdding: .day, value: customerEntity.creditDays, to: date)!
                }
                if paymentType == .loan {
                    customerEntity.firstDatePurchaseWithCredit = customerEntity.totalDebt == 0 ? date : customerEntity.firstDatePurchaseWithCredit
                    customerEntity.totalDebt = customerEntity.totalDebt + saleTransactionDTO.cart.total
                    if customerEntity.totalDebt > customerEntity.creditLimit && customerEntity.isCreditLimitActive {
                        customerEntity.isCreditLimit = true
                    } else {
                        customerEntity.isCreditLimit = false
                    }
                }
                try await customerEntity.update(on: transaction)
            }
        }
        SyncTimestamp.shared.updateLastSyncDate(to: .product)
        SyncTimestamp.shared.updateLastSyncDate(to: .customer)
        SyncTimestamp.shared.updateLastSyncDate(to: .sale)
        return DefaultResponse(
            code: 200,
            message: "Created",
            syncIds: SyncTimestamp.shared.getLastSyncDate()
        )
    }
//    private func correctAmount(saleTransactionDTO: SaleTransactionDTO, db: any Database) async throws -> Bool {
//        let cartDTO = saleTransactionDTO.cart
//        for cartDetailDTO in cartDTO.cartDetails {
//            
//        }
//    }
    private func reduceStock(cartDetailDTO: CartDetailDTO, db: any Database) async throws -> Product {
        let productEntity = try await Product.query(on: db)
            .filter(\.$id == cartDetailDTO.productId)
            .sort(\.$updatedAt, .ascending)
            .with(\.$imageUrl)
            .limit(1).first()
        guard let product = productEntity else {
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
