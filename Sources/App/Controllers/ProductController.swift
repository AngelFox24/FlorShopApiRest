import Fluent
import Vapor

struct TodoController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let song = routes.grouped("songs")
        song.get(use: index)
        //song.post(use: create)
    }
    
    //func index(req: Request) throws -> EventLoopFuture<[Song]> {
    func index(req: Request) throws -> EventLoopFuture<String> {
        return "HOla"
        //return Song.query(on: req.db).all()
    }
    /*
    func create(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let song = try req.content.decode(Song.self)
        return song.save(on: req.db).transform(to: .ok)
    }
     */
}
