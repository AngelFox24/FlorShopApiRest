import Fluent
import Vapor

struct CustomerContoller: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let customers = routes.grouped("customers")
        customers.post(use: create)
    }
    func create(req: Request) async throws -> DefaultResponse {
        let customer = try req.content.decode(Customer.self)
        guard customer.id != nil else {
            throw Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
        }
        try await customer.save(on: req.db)
        return DefaultResponse(code: 200, message: "Ok")
    }
}
