import Fluent
import Vapor

struct SaleController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let sales = routes.grouped("sales")
        sales.get(use: index)
        sales.post(use: create)
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Sale]> {
        return Sale.query(on: req.db).all()
    }
    func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let saleDTO = try req.content.decode(SaleDTO.self)
        let sale = Sale(id: saleDTO.id, paid: saleDTO.paid, paymentType: saleDTO.paymentType, saleDate: saleDTO.saleDate, total: saleDTO.total, subsidiaryID: saleDTO.subsidiaryId, customerID: saleDTO.customerId, employeeID: saleDTO.employeeId)
        return sale.save(on: req.db).flatMap { //Sincrono
            return req.eventLoop.flatten( //Asincrono
                saleDTO.saleDetail.map { saleDetailDTO in
                    let saleDetail = SaleDetail(id: saleDetailDTO.id, productName: saleDetailDTO.productName, quantitySold: saleDetailDTO.quantitySold, subtotal: saleDetailDTO.subtotal, unitCost: saleDetailDTO.unitCost, unitPrice: saleDetailDTO.unitPrice, saleID: saleDTO.id, imageUrlID: saleDetailDTO.imageUrlId)
                    return saleDetail.save(on: req.db)
                }
            ).transform(to: .ok)
        }.flatMapError { error in
            // Manejar el error aquí según tus necesidades.
            return req.eventLoop.makeFailedFuture(error)
        }
    }
}

struct SaleDTO: Content {
    let id: UUID
    let paid: Bool
    let paymentType: String
    let saleDate: Date
    let total: Double
    let subsidiaryId: UUID
    let customerId: UUID?
    let employeeId: UUID
    let saleDetail: [SaleDetailDTO]
}

struct SaleDetailDTO: Content {
    let id: UUID
    let productName: String
    let quantitySold: Int
    let subtotal: Double
    let unitCost: Double
    let unitPrice: Double
    let imageUrlId: UUID
}
