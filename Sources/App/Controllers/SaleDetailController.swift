import Fluent
import Vapor
//MARK: Not Visible
struct SaleDetailController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let saleDetails = routes.grouped("saleDetails")
        saleDetails.get(use: index)
//        saleDetails.post(use: create)
    }
    
    func index(req: Request) async throws -> [SaleDetail] {
        try await SaleDetail.query(on: req.db).all()
    }
    //Not Create with this func
//    func create(req: Request) async throws -> HTTPStatus {
//        let saleDetail = try req.content.decode(SaleDetail.self)
//        guard saleDetail.id != nil else {
//            throw Abort(.badRequest, reason: "Se debe proporcionar el Id al registro")
//        }
//        try await saleDetail.save(on: req.db)
//        return .ok
//    }
}
