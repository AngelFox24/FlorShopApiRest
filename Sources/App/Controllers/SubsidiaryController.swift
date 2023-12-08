import Fluent
import Vapor

struct SubsidiaryController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let subsidiaries = routes.grouped("subsidiaries")
        subsidiaries.get(use: index)
        subsidiaries.post(use: create)
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Subsidiary]> {
        return Subsidiary.query(on: req.db).all()
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
