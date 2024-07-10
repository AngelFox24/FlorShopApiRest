import Fluent
import Vapor

struct EmployeeController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let employees = routes.grouped("employees")
        employees.get(use: index)
        employees.post(use: create)
    }
    
    func index(req: Request) async throws -> [Employee] {
        try await Employee.query(on: req.db).all()
    }
    func create(req: Request) async throws -> HTTPStatus {
        let employee = try req.content.decode(Employee.self)
        guard employee.id != nil else {
            throw Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
        }
        try await employee.save(on: req.db)
        return .ok
    }
}
