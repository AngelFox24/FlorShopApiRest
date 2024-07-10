import Fluent
import Vapor

struct ProductController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let products = routes.grouped("products")
        products.get(use: index)
        products.post(use: create)
    }
    
    func index(req: Request) async throws -> [ProductDTO] {
        try await Product.query(on: req.db).all().map { product in
            ProductDTO(
                id: product.id!,
                productName: product.productName,
                active: product.active,
                expirationDate: product.expirationDate,
                quantityStock: product.quantityStock,
                unitCost: product.unitCost,
                unitPrice: product.unitPrice,
                subsidiaryId: product.$subsidiary.id,
                imageUrlId: product.$imageUrl.id!,
                createdAt: product.createdAt,
                updatedAt: product.updatedAt)
        }
    }
    
    func create(req: Request) async throws -> HTTPStatus {
        let productDTO = try req.content.decode(ProductDTO.self)
        let product = Product(
            id: productDTO.id,
            productName: productDTO.productName,
            active: productDTO.active,
            expirationDate: productDTO.expirationDate, //En la BD hay que cambiar de .date a .timestamptz para que registre la hora
            quantityStock: productDTO.quantityStock,
            unitCost: productDTO.unitCost,
            unitPrice: productDTO.unitPrice,
            subsidiaryID: productDTO.subsidiaryId,
            imageUrlID: productDTO.imageUrlId)
        try await product.save(on: req.db)
        return .ok
    }
}

struct ProductDTO: Content {
    let id: UUID
    let productName: String
    let active: Bool
    let expirationDate: Date?
    let quantityStock: Int
    let unitCost: Double
    let unitPrice: Double
    let subsidiaryId: UUID
    let imageUrlId: UUID
    let createdAt: Date?
    let updatedAt: Date?
}
