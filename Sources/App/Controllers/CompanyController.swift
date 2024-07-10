import Fluent
import Vapor

struct CompanyController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let companies = routes.grouped("companies")
        companies.get(use: index)
        companies.post(use: create)
    }
    
    func index(req: Request) async throws -> [Company] {
        try await Company.query(on: req.db).all()
    }
    func create(req: Request) async throws -> HTTPStatus {
        let company = try req.content.decode(Company.self)
        guard company.id != nil else {
            throw Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
        }
        try await company.save(on: req.db)
        return .ok
    }
}
