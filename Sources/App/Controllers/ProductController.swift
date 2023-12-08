import Fluent
import Vapor

struct ProductController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let song = routes.grouped("products")
        song.get(use: index)
        //song.post(use: create)
    }
    
    //func index(req: Request) throws -> EventLoopFuture<[Song]> {
    func index(req: Request) throws -> EventLoopFuture<[Product]> {
        return Product.query(on: req.db).all()
        //return Song.query(on: req.db).all()
    }
    /*
    func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let song = try req.content.decode(Song.self)
        return song.save(on: req.db).transform(to: .ok)
    }
     */
}
