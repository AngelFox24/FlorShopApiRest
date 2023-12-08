import Fluent
import Vapor

struct CompanyController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let companies = routes.grouped("companies")
        companies.get(use: index)
        companies.post(use: create)
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Company]> {
        return Company.query(on: req.db).all()
    }
    func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let company = try req.content.decode(Company.self)
        guard company.id != nil else {
            let error = Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
            return req.eventLoop.makeFailedFuture(error)
        }
        return company.save(on: req.db).transform(to: .ok)
    }
}
