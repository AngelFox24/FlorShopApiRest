import Fluent
import Vapor

enum SaleError: Error {
    case alreadyExist
}

// Implementa el protocolo AbortError para proporcionar más información sobre el error
extension SaleError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .alreadyExist:
            return .internalServerError
        }
    }

    var reason: String {
        switch self {
        case .alreadyExist:
            return "Ya hay una venta con el mismo ID"
        }
    }
}

enum SaleDetailError: Error {
    case alreadyExist
}

// Implementa el protocolo AbortError para proporcionar más información sobre el error
extension SaleDetailError: AbortError {
    var status: HTTPResponseStatus {
        switch self {
        case .alreadyExist:
            return .internalServerError
        }
    }

    var reason: String {
        switch self {
        case .alreadyExist:
            return "Ya hay una detalle de venta con el mismo ID"
        }
    }
}

struct SaleController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let sales = routes.grouped("sales")
        sales.get(use: index)
        sales.post(use: create)
    }
    
    func index(req: Request) async throws -> [SaleDTO] {
        try await Sale.query(on: req.db).all().mapToListSaleDTO()
    }
    
    func create(req: Request) async throws -> HTTPStatus {
        let saleDTO = try req.content.decode(SaleDTO.self)
        let saleDetails = saleDTO.saleDetail.mapToListSaleDetail()
        return try await req.db.transaction { transaction in
            if try await Sale.find(saleDTO.id, on: transaction) != nil {
                //Las Ventas no se modifican
                throw SaleError.alreadyExist
            } else {
                try await saleDTO.toSale().save(on: transaction)
                for saleDetail in saleDetails {
                    if try await SaleDetail.find(saleDetail.id, on: transaction) != nil {
                        //El detalle de las ventas no se modifican
                        throw SaleDetailError.alreadyExist
                    } else {
                        try await saleDetail.save(on: transaction)
                    }
                }
            }
            return .ok
        }
    }
}
