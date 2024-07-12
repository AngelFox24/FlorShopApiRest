import Fluent
import Vapor
//MARK: Not Visible
struct ImageUrlController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let imageUrl = routes.grouped("imageUrls")
        imageUrl.get(use: index)
//        imageUrl.post(use: create)
    }
    
    func index(req: Request) async throws -> [ImageURLDTO] {
        //TODO: Pagination
        try await ImageUrl.query(on: req.db).all().mapToListImageURLDTO()
    }
    //Not Create with this func
//    func create(req: Request) async throws -> HTTPStatus {
//        let imageUrl = try req.content.decode(ImageUrl.self)
//        guard imageUrl.id != nil else {
//            throw Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
//        }
//        try await imageUrl.save(on: req.db)
//        return .ok
//    }
}
