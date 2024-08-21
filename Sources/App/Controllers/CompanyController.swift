import Fluent
import Vapor

struct CompanyController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let companies = routes.grouped("companies")
        companies.post("sync", use: sync)
        companies.post(use: save)
    }
    func sync(req: Request) async throws -> CompanyDTO {
        //Precicion de segundos solamente
        //No se requiere mas precicion ya que el objetivo es sincronizar y en caso haya repetidos esto se mitiga en la app
        let request = try req.content.decode(SyncCompanyParameters.self)
        
        let query = Company.query(on: req.db)
            .filter(\.$updatedAt >= request.updatedSince)
            .sort(\.$updatedAt, .ascending)
            .limit(1)
        
        let company = try await query.all().first
        guard let companyNN = company else {
            throw Abort(.badRequest, reason: "No existe compania en la BD")
        }
        
        return companyNN.toCompanyDTO()
    }
    func save(req: Request) async throws -> DefaultResponse {
        let companyDTO = try req.content.decode(CompanyDTO.self)
        
        return try await req.db.transaction { transaction in
            if let company = try await Company.find(companyDTO.id, on: transaction) {
                //Update
                company.companyName = companyDTO.companyName
                company.ruc = companyDTO.ruc
                try await company.update(on: transaction)
            } else {
                //Create
                //TODO: Check if more parameters exist
                let companyNew = companyDTO.toCompany()
                try await companyNew.save(on: transaction)
            }
            return DefaultResponse(code: 200, message: "Ok")
        }
    }
}
