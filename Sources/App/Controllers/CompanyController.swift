import Fluent
import Vapor

struct CompanyController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let companies = routes.grouped("companies")
        companies.get(use: index)
        companies.post(use: save)
    }
    
    func index(req: Request) async throws -> [CompanyDTO] {
        try await Company.query(on: req.db).all().mapToListCompanyDTO()
    }
    func save(req: Request) async throws -> HTTPStatus {
//        let company = try req.content.decode(Company.self)
//        guard company.id != nil else {
//            throw Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
//        }
//        try await company.save(on: req.db)
//        return .ok
//        
        let companyDTO = try req.content.decode(CompanyDTO.self)
        
        return try await req.db.transaction { transaction in
            if let company = try await Company.find(companyDTO.id, on: transaction) {
                //Update
                company.companyName = companyDTO.companyName
                company.ruc = companyDTO.ruc
                try await company.update(on: transaction)
            } else {
                //Create
                let companyNew = companyDTO.toCompany()
                try await companyNew.save(on: transaction)
            }
            return .ok
        }
    }
}
