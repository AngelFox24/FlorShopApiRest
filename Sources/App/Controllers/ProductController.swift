import Fluent
import Vapor

struct ProductController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let products = routes.grouped("products")
        products.get(use: index)
        products.post(use: create)
    }
    
    func index(req: Request) throws -> EventLoopFuture<[Product]> {
        return Product.query(on: req.db).all()
    }
    func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let product = try req.content.decode(Product.self)
        guard product.id != nil else {
            let error = Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
            return req.eventLoop.makeFailedFuture(error)
        }
        return product.save(on: req.db).transform(to: .ok)
    }
}
