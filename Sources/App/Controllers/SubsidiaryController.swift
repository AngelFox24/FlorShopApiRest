import Fluent
import Vapor

struct SubsidiaryController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let subsidiaries = routes.grouped("subsidiaries")
        subsidiaries.post("sync", use: sync)
        subsidiaries.post(use: save)
    }
    func sync(req: Request) async throws -> SyncSubsidiariesResponse {
        let request = try req.content.decode(SyncFromCompanyParameters.self)
        guard try SyncTimestamp.shared.shouldSync(clientSyncIds: request.syncIds, entity: .subsidiary) else {
            return SyncSubsidiariesResponse(
                subsidiariesDTOs: [],
                syncIds: SyncTimestamp.shared.getLastSyncDate()
            )
        }
        let maxPerPage = 50
        let query = Subsidiary.query(on: req.db)
            .filter(\.$company.$id == request.companyId)
            .filter(\.$updatedAt >= request.updatedSince)
            .sort(\.$updatedAt, .ascending)
            .with(\.$imageUrl)
            .limit(maxPerPage)
        let subsidiaries = try await query.all()
        return SyncSubsidiariesResponse(
            subsidiariesDTOs: subsidiaries.mapToListSubsidiaryDTO(),
            syncIds: subsidiaries.count == maxPerPage ? SyncTimestamp.shared.getLastSyncDateTemp(entity: .subsidiary) : SyncTimestamp.shared.getLastSyncDate()
        )
    }
    func save(req: Request) async throws -> DefaultResponse {
        let subsidiaryDTO = try req.content.decode(SubsidiaryDTO.self)
        //Las imagenes se guardan por separado
        if let subsidiary = try await Subsidiary.find(subsidiaryDTO.id, on: req.db) {
            //Update
            var update = false
            if subsidiary.name != subsidiaryDTO.name {
                guard try await !subsidiaryNameExist(subsidiaryDTO: subsidiaryDTO, db: req.db) else {
                    throw Abort(.badRequest, reason: "La subsidiaria con este nombre ya existe")
                }
                subsidiary.name = subsidiaryDTO.name
                update = true
            }
            if subsidiary.$imageUrl.id != subsidiaryDTO.imageUrlId {
                subsidiary.$imageUrl.id = try await ImageUrl.find(subsidiaryDTO.imageUrlId, on: req.db)?.id
                update = true
            }
            if update {
                try await subsidiary.update(on: req.db)
                SyncTimestamp.shared.updateLastSyncDate(to: .subsidiary)
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
            guard try await !subsidiaryNameExist(subsidiaryDTO: subsidiaryDTO, db: req.db) else {
                throw Abort(.badRequest, reason: "La subsidiaria con este nombre ya existe")
            }
            guard let companyId = try await Company.find(subsidiaryDTO.companyID, on: req.db)?.id else {
                throw Abort(.badRequest, reason: "La compañia no existe existe")
            }
            let subsidiaryNew = Subsidiary(
                id: UUID(),
                name: subsidiaryDTO.name,
                companyID: companyId,
                imageUrlID: try await ImageUrl.find(subsidiaryDTO.imageUrlId, on: req.db)?.id
            )
            try await subsidiaryNew.save(on: req.db)
            SyncTimestamp.shared.updateLastSyncDate(to: .subsidiary)
            return DefaultResponse(
                code: 200,
                message: "Created",
                syncIds: SyncTimestamp.shared.getLastSyncDate()
            )
        }
    }
    private func subsidiaryNameExist(subsidiaryDTO: SubsidiaryDTO, db: any Database) async throws -> Bool {
        guard subsidiaryDTO.name != "" else {
            print("Subsidiaria existe vacio aunque no exista xd")
            return true
        }
        let query = try await Subsidiary.query(on: db)
            .filter(\.$name == subsidiaryDTO.name)
            .limit(1)
            .first()
        if query != nil {
            return true
        } else {
            return false
        }
    }
}
