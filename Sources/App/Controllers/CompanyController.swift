import Fluent
import Vapor

struct CompanyController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let companies = routes.grouped("companies")
        companies.post("sync", use: sync)
        companies.post(use: save)
    }
    func sync(req: Request) async throws -> SyncCompanyResponse {
        let request = try req.content.decode(SyncCompanyParameters.self)
        let companyClientLastSyncId = request.syncIds.companyLastUpdate
        let companyBackendLastSyncId = SyncTimestamp.shared.getLastSyncDate().companyLastUpdate
        guard companyClientLastSyncId != companyBackendLastSyncId else {
            return SyncCompanyResponse(
                companyDTO: nil,
                syncIds: SyncTimestamp.shared.getLastSyncDate()
            )
        }
        let query = Company.query(on: req.db)
            .filter(\.$updatedAt >= request.updatedSince)
            .sort(\.$updatedAt, .ascending)
            .limit(1)
        let company = try await query.all().first
        guard let companyNN = company else {
            throw Abort(.badRequest, reason: "No existe compania en la BD")
        }
        return SyncCompanyResponse(
            companyDTO: companyNN.toCompanyDTO(),
            syncIds: SyncTimestamp.shared.getLastSyncDate()
        )
    }
    func save(req: Request) async throws -> DefaultResponse {
        let companyDTO = try req.content.decode(CompanyDTO.self)
        if let company = try await Company.find(companyDTO.id, on: req.db) {
            //Update
            var update = false
            if company.companyName != companyDTO.companyName {
                guard try await !companyNameExist(companyDTO: companyDTO, db: req.db) else {
                    throw Abort(.badRequest, reason: "El nombre de la compañia ya existe")
                }
                company.companyName = companyDTO.companyName
                update = true
            }
            if company.ruc != companyDTO.ruc {
                guard try await !companyRucExist(companyDTO: companyDTO, db: req.db) else {
                    throw Abort(.badRequest, reason: "El RUC de la compañia ya existe")
                }
                company.ruc = companyDTO.ruc
                update = true
            }
            if update {
                try await company.update(on: req.db)
                SyncTimestamp.shared.updateLastSyncDate(to: .company)
                return DefaultResponse(
                    code: 200,
                    message: "Updated",
                    syncIds: SyncTimestamp.shared.getLastSyncDate()
                )
            } else {
                return DefaultResponse(
                    code: 200,
                    message: "Not Updated",
                    syncIds: SyncTimestamp.shared.getLastSyncDate()
                )
            }
        } else {
            //Create
            guard try await !companyNameExist(companyDTO: companyDTO, db: req.db) else {
                throw Abort(.badRequest, reason: "El nombre de la compañia ya existe")
            }
            guard try await !companyRucExist(companyDTO: companyDTO, db: req.db) else {
                throw Abort(.badRequest, reason: "El RUC de la compañia ya existe")
            }
            let companyNew = companyDTO.toCompany()
            try await companyNew.save(on: req.db)
            SyncTimestamp.shared.updateLastSyncDate(to: .company)
            return DefaultResponse(
                code: 200,
                message: "Created",
                syncIds: SyncTimestamp.shared.getLastSyncDate()
            )
        }
    }
    private func companyNameExist(companyDTO: CompanyDTO, db: any Database) async throws -> Bool {
        guard companyDTO.companyName != "" else {
            print("Compañia existe vacio aunque no exista xd")
            return true
        }
        let query = try await Company.query(on: db)
            .filter(\.$companyName == companyDTO.companyName)
            .limit(1)
            .first()
        if query != nil {
            return true
        } else {
            return false
        }
    }
    private func companyRucExist(companyDTO: CompanyDTO, db: any Database) async throws -> Bool {
        guard companyDTO.ruc != "" else {
            print("RUC vacio normal")
            return false
        }
        let query = try await Company.query(on: db)
            .filter(\.$ruc == companyDTO.ruc)
            .limit(1)
            .first()
        if query != nil {
            return true
        } else {
            return false
        }
    }
}
