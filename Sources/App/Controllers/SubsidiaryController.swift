import Fluent
import Vapor

struct SubsidiaryController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let subsidiaries = routes.grouped("subsidiaries")
        subsidiaries.get(use: index)
        subsidiaries.get("byCompanyId", use: getByCompanyId)
        subsidiaries.post(use: create)
    }
    
    func index(req: Request) async throws -> [Subsidiary] {
        try await Subsidiary.query(on: req.db)
            .with(\.$imageUrl)
            .with(\.$company)// Carga ansiosa para obtener datos del artista
            .all()
    }
    
    func getByCompanyId(req: Request) async throws -> [Subsidiary] {
        // Obtén el parámetro de consulta "companyId" de la solicitud
        guard let companyId = req.query[UUID.self, at: "companyId"] else {
            // Manejar el caso en el que no se proporciona el parámetro "companyId"
            throw Abort(.badRequest, reason: "Se requiere el parámetro 'companyId'")
        }
        
        // Realiza la consulta para obtener todas las subsidiarias de la compañía específica
        return try await Subsidiary.query(on: req.db)
            .filter(\.$company.$id == companyId)
            .with(\.$imageUrl)
            .all()
    }
    
    func create(req: Request) async throws -> HTTPStatus {
        let subsidiary = try req.content.decode(Subsidiary.self)
        guard subsidiary.id != nil else {
            throw Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
        }
        try await subsidiary.save(on: req.db)
        return .ok
    }
}
