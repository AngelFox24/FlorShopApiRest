import Fluent
import Vapor

struct CustomerContoller: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let customers = routes.grouped("customers")
        customers.get(use: index)
        customers.post(use: create)
    }
    
    func index(req: Request) async throws -> [Customer] {
        try await Customer.query(on: req.db).all()
    }
    func create(req: Request) async throws -> HTTPStatus {
        let customer = try req.content.decode(Customer.self)
        guard customer.id != nil else {
            throw Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
        }
        try await customer.save(on: req.db)
        return .ok
    }
}
