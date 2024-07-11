import Fluent
import Vapor

struct ProductController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let products = routes.grouped("products")
        products.get(use: index)
        products.post(use: create)
    }
    
    func index(req: Request) async throws -> [ProductDTO] {
        try await Product.query(on: req.db).with(\.$imageUrl).all().map { product in
            guard let imageUrlId = product.imageUrl?.id else {
                throw Abort(.badRequest, reason: "imageURL no tiene ID")
            }
            guard let imageUrlS = product.imageUrl?.imageUrl else {
                throw Abort(.badRequest, reason: "imageURL no tiene url")
            }
            guard let imageHash = product.imageUrl?.imageHash else {
                throw Abort(.badRequest, reason: "imageURL no tiene Hash")
            }
            let productDTO = ProductDTO(
                id: product.id!,
                productName: product.productName,
                barCode: product.barCode,
                active: product.active,
                expirationDate: product.expirationDate,
                quantityStock: product.quantityStock,
                unitType: product.unitType,
                unitCost: product.unitCost,
                unitPrice: product.unitPrice,
                subsidiaryId: product.$subsidiary.id,
                imageUrl: ImageURLDTO(
                    id: imageUrlId,
                    imageUrl: imageUrlS,
                    imageHash: imageHash
//                    id: product.imageUrl?.id ?? UUID(),
//                    imageUrl: product.imageUrl?.imageUrl ?? "",
//                    imageHash: product.imageUrl?.imageHash ?? ""
                ),
                createdAt: product.createdAt,
                updatedAt: product.updatedAt
            )
            return productDTO
        }
    }
    
//    func index(req: Request) async throws -> [Product] {
//        try await Product.query(on: req.db).with(\.$imageUrl).all()
//    }
    
    func create(req: Request) async throws -> HTTPStatus {
        let productDTO = try req.content.decode(ProductDTO.self)
        let imageUrlDTO = productDTO.imageUrl
        let imageUrl = ImageUrl(
            id: imageUrlDTO.id,
            imageUrl: imageUrlDTO.imageUrl,
            imageHash: imageUrlDTO.imageHash
        )
        let product = Product(
            id: productDTO.id,
            productName: productDTO.productName,
            barCode: productDTO.barCode,
            active: productDTO.active,
            expirationDate: productDTO.expirationDate, //En la BD hay que cambiar de .date a .timestamptz para que registre la hora
            unitType: productDTO.unitType,
            quantityStock: productDTO.quantityStock,
            unitCost: productDTO.unitCost,
            unitPrice: productDTO.unitPrice,
            subsidiaryID: productDTO.subsidiaryId,
            imageUrlID: productDTO.imageUrl.id
        )
        return try await req.db.transaction { transaction in
            try await imageUrl.save(on: transaction)
            try await product.save(on: transaction)
            return .ok
        }
    }
}

struct ProductDTO: Content {
    let id: UUID
    let productName: String
    let barCode: String
    let active: Bool
    let expirationDate: Date?
    let quantityStock: Int
    let unitType: String
    let unitCost: Int
    let unitPrice: Int
    let subsidiaryId: UUID
    let imageUrl: ImageURLDTO
    let createdAt: Date?
    let updatedAt: Date?
}

struct ImageURLDTO: Content {
    let id: UUID
    let imageUrl: String
    let imageHash: String
}
