import Fluent
import Vapor

struct EmployeeController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let employees = routes.grouped("employees")
        employees.get(use: index)
        employees.post(use: create)
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Employee]> {
        return Employee.query(on: req.db).all()
    }
    func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let employee = try req.content.decode(Employee.self)
        guard employee.id != nil else {
            let error = Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
            return req.eventLoop.makeFailedFuture(error)
        }
        return employee.save(on: req.db).transform(to: .ok)
    }
}
