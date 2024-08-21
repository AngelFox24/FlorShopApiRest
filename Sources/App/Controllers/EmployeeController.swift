import Fluent
import Vapor

struct EmployeeController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let employees = routes.grouped("employees")
        employees.post(use: create)
    }
    func create(req: Request) async throws -> DefaultResponse {
        let employee = try req.content.decode(Employee.self)
        guard employee.id != nil else {
            throw Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
        }
        try await employee.save(on: req.db)
        return DefaultResponse(code: 200, message: "Ok")
    }
}
