import Fluent
import Vapor

struct ImageUrlController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let imageUrl = routes.grouped("imageUrls")
        imageUrl.get(use: index)
        imageUrl.post(use: create)
    }
    
    func index(req: Request) throws -> EventLoopFuture<[ImageUrl]> {
        return ImageUrl.query(on: req.db).all()
    }
    func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let imageUrl = try req.content.decode(ImageUrl.self)
        guard imageUrl.id != nil else {
            let error = Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
            return req.eventLoop.makeFailedFuture(error)
        }
        return imageUrl.save(on: req.db).transform(to: .ok)
    }
}
