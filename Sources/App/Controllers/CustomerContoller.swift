import Fluent
import Vapor

struct CustomerContoller: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let customers = routes.grouped("customers")
        customers.get(use: index)
        customers.post(use: create)
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Customer]> {
        return Customer.query(on: req.db).all()
    }
    func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let customer = try req.content.decode(Customer.self)
        guard customer.id != nil else {
            let error = Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
            return req.eventLoop.makeFailedFuture(error)
        }
        return customer.save(on: req.db).transform(to: .ok)
    }
}
