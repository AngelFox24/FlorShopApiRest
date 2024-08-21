import Fluent
import Vapor
//MARK: Not Visible
struct SaleDetailController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let saleDetails = routes.grouped("saleDetails")
        saleDetails.get(use: index)
    }
    func index(req: Request) async throws -> [SaleDetailDTO] {
        try await SaleDetail.query(on: req.db).all().mapToListSaleDetailDTO()
    }
}
