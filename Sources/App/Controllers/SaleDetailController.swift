import Fluent
import Vapor
//MARK: Not Visible
//Se registra a travez de SaleController
struct SaleDetailController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let saleDetails = routes.grouped("saleDetails")
        saleDetails.get(use: index)
    }
    func index(req: Request) async throws -> [SaleDetailDTO] {
        return []
//        try await SaleDetail.query(on: req.db).all().mapToListSaleDetailDTO()
    }
}
