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
        let sale = try req.content.decode(Sale.self)
        guard sale.id != nil else {
            let error = Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
            return req.eventLoop.makeFailedFuture(error)
        }
        return sale.save(on: req.db).transform(to: .ok)
    }
}
