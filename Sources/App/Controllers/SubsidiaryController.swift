import Fluent
import Vapor

struct SubsidiaryController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let subsidiaries = routes.grouped("subsidiaries")
        subsidiaries.get(use: index)
        subsidiaries.get("byCompanyId", use: getByCompanyId)
        subsidiaries.post(use: create)
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Subsidiary]> {
        return Subsidiary.query(on: req.db)
            .with(\.$imageUrl)
            .with(\.$company)// Carga ansiosa para obtener datos del artista
            .all()
    }
    
    func getByCompanyId(req: Request) throws -> EventLoopFuture<[Subsidiary]> {
        // Obtén el parámetro de consulta "companyId" de la solicitud
        guard let companyId = req.query[UUID.self, at: "companyId"] else {
            // Manejar el caso en el que no se proporciona el parámetro "companyId"
            throw Abort(.badRequest, reason: "Se requiere el parámetro 'companyId'")
        }
        
        // Realiza la consulta para obtener todas las subsidiarias de la compañía específica
        return Subsidiary.query(on: req.db)
            .filter(\.$company.$id == companyId)
            .with(\.$imageUrl)
            .all()
    }
    
    func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let subsidiary = try req.content.decode(Subsidiary.self)
        guard subsidiary.id != nil else {
            let error = Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
            return req.eventLoop.makeFailedFuture(error)
        }
        return subsidiary.save(on: req.db).transform(to: .ok)
    }
}
