import Fluent
import Vapor

struct SaleDetailController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let saleDetails = routes.grouped("saleDetails")
        saleDetails.get(use: index)
        saleDetails.post(use: create)
    }
    
    func index(req: Request) throws -> EventLoopFuture<[SaleDetail]> {
        return SaleDetail.query(on: req.db).all()
    }
    func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let saleDetail = try req.content.decode(SaleDetail.self)
        guard saleDetail.id != nil else {
            let error = Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
            return req.eventLoop.makeFailedFuture(error)
        }
        return saleDetail.save(on: req.db).transform(to: .ok)
    }
}
