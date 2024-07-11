import Fluent
import Vapor

struct SaleController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let sales = routes.grouped("sales")
        sales.get(use: index)
        sales.post(use: create)
    }
    
    func index(req: Request) async throws -> [Sale] {
        try await Sale.query(on: req.db).all()
    }
    
//    func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
//        let saleDTO = try req.content.decode(SaleDTO.self)
//        let sale = Sale(id: saleDTO.id, paid: saleDTO.paid, paymentType: saleDTO.paymentType, saleDate: saleDTO.saleDate, total: saleDTO.total, subsidiaryID: saleDTO.subsidiaryId, customerID: saleDTO.customerId, employeeID: saleDTO.employeeId)
//        return sale.save(on: req.db).flatMap { //Sincrono
//            return req.eventLoop.flatten( //Asincrono
//                saleDTO.saleDetail.map { saleDetailDTO in
//                    let saleDetail = SaleDetail(id: saleDetailDTO.id, productName: saleDetailDTO.productName, quantitySold: saleDetailDTO.quantitySold, subtotal: saleDetailDTO.subtotal, unitCost: saleDetailDTO.unitCost, unitPrice: saleDetailDTO.unitPrice, saleID: saleDTO.id, imageUrlID: saleDetailDTO.imageUrlId)
//                    return saleDetail.save(on: req.db)
//                }
//            ).transform(to: .ok)
//        }.flatMapError { error in
//            // Manejar el error aquí según tus necesidades.
//            return req.eventLoop.makeFailedFuture(error)
//        }
//    }
    
    func create(req: Request) async throws -> HTTPStatus {
        let saleDTO = try req.content.decode(SaleDTO.self)
        let sale = Sale(
            id: saleDTO.id,
            paid: saleDTO.paid,
            paymentType: saleDTO.paymentType,
            saleDate: saleDTO.saleDate,
            total: saleDTO.total,
            subsidiaryID: saleDTO.subsidiaryId,
            customerID: saleDTO.customerId,
            employeeID: saleDTO.employeeId
        )
        let saleDetails = saleDTO.saleDetail.map { saleDetailDTO in
            return SaleDetail(
                id: saleDetailDTO.id,
                productName: saleDetailDTO.productName,
                barCode: saleDetailDTO.barCode,
                quantitySold: saleDetailDTO.quantitySold,
                subtotal: saleDetailDTO.subtotal,
                unitType: saleDetailDTO.unitType,
                unitCost: saleDetailDTO.unitCost,
                unitPrice: saleDetailDTO.unitPrice,
                saleID: saleDTO.id,
                imageUrlID: saleDetailDTO.imageUrlId
            )
        }
        return try await req.db.transaction { transaction in
            try await sale.save(on: transaction)
            for saleDetail in saleDetails {
                try await saleDetail.save(on: transaction)
            }
            return .ok
        }
    }
}

struct SaleDTO: Content {
    let id: UUID
    let paid: Bool
    let paymentType: String
    let saleDate: Date
    let total: Int
    let subsidiaryId: UUID
    let customerId: UUID?
    let employeeId: UUID
    let saleDetail: [SaleDetailDTO]
}

struct SaleDetailDTO: Content {
    let id: UUID
    let productName: String
    let barCode: String
    let quantitySold: Int
    let subtotal: Int
    let unitType: String
    let unitCost: Int
    let unitPrice: Int
    let imageUrlId: UUID
}
