import Fluent
import Vapor

struct ImageUrlController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let imageUrl = routes.grouped("imageUrls")
        imageUrl.get(use: index)
        imageUrl.post(use: create)
    }
    
    func index(req: Request) async throws -> [ImageUrl] {
        try await ImageUrl.query(on: req.db).all()
    }
    func create(req: Request) async throws -> HTTPStatus {
        let imageUrl = try req.content.decode(ImageUrl.self)
        guard imageUrl.id != nil else {
            throw Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
        }
        try await imageUrl.save(on: req.db)
        return .ok
    }
}
