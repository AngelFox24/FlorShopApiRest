import Fluent
import Vapor

struct SubsidiaryController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let subsidiaries = routes.grouped("subsidiaries")
        subsidiaries.get(use: index)
        subsidiaries.post("sync", use: sync)
        subsidiaries.get("byCompanyId", use: getByCompanyId)
        subsidiaries.post(use: save)
    }
    
    func index(req: Request) async throws -> [SubsidiaryDTO] {
        try await Subsidiary.query(on: req.db)
            .with(\.$imageUrl)
            .with(\.$company)
            .all().mapToListSubsidiaryDTO()
    }
    func sync(req: Request) async throws -> [SubsidiaryDTO] {
        //Precicion de segundos solamente
        //No se requiere mas precicion ya que el objetivo es sincronizar y en caso haya repetidos esto se mitiga en la app
        let request = try req.content.decode(SyncFromCompanyParameters.self)
        
        let query = Subsidiary.query(on: req.db)
            .filter(\.$company.$id == request.companyId)
            .filter(\.$updatedAt >= request.updatedSince)
            .sort(\.$updatedAt, .ascending)
            .with(\.$imageUrl)
            .limit(50)
        
        let subsidiaries = try await query.all()
        
        return subsidiaries.mapToListSubsidiaryDTO()
    }
    func getByCompanyId(req: Request) async throws -> [SubsidiaryDTO] {
        // Obtén el parámetro de consulta "companyId" de la solicitud
        guard let companyId = req.query[UUID.self, at: "companyId"] else {
            // Manejar el caso en el que no se proporciona el parámetro "companyId"
            throw Abort(.badRequest, reason: "Se requiere el parámetro 'companyId'")
        }
        
        // Realiza la consulta para obtener todas las subsidiarias de la compañía específica
        return try await Subsidiary.query(on: req.db)
            .filter(\.$company.$id == companyId)
            .with(\.$imageUrl)
            .all().mapToListSubsidiaryDTO()
    }
    
    func save(req: Request) async throws -> HTTPStatus {
        let subsidiaryDTO = try req.content.decode(SubsidiaryDTO.self)
        
        return try await req.db.transaction { transaction in
            if let imageURLDTO = subsidiaryDTO.imageUrl {
                if let imageUrl = try await ImageUrl.find(imageURLDTO.id, on: transaction) {
                    //Update
                    imageUrl.imageUrl = imageURLDTO.imageUrl
                    imageUrl.imageHash = imageURLDTO.imageHash
                    try await imageUrl.update(on: transaction)
                } else {
                    //Create
                    let imageUrlNew = imageURLDTO.toImageUrl()
                    try await imageUrlNew.save(on: transaction)
                }
            }
            if let subsidiary = try await Subsidiary.find(subsidiaryDTO.id, on: transaction) {
                //Update
                subsidiary.name = subsidiaryDTO.name
                subsidiary.$company.id = subsidiaryDTO.companyID
                subsidiary.$imageUrl.id = subsidiaryDTO.imageUrl?.id
                try await subsidiary.update(on: transaction)
            } else {
                //Create
                let subsidiaryNew = subsidiaryDTO.toSubsidiary()
                try await subsidiaryNew.save(on: transaction)
            }
            return .ok
        }
    }
}

struct SyncFromCompanyParameters: Content {
    let companyId: UUID
    let updatedSince: Date
}
