import Fluent
import Vapor

struct ProductController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let products = routes.grouped("products")
        products.get(use: index)
        products.post("sync", use: sync)
        products.post(use: save)
        products.post("bulkCreate", use: bulkCreate)
    }
    
    func index(req: Request) async throws -> [ProductDTO] {
        try await Product.query(on: req.db).with(\.$imageUrl).all().mapToListProductDTO()
    }
    
    func sync(req: Request) async throws -> [ProductDTO] {
        //Precicion de segundos solamente
        //No se requiere mas precicion ya que el objetivo es sincronizar y en caso haya repetidos esto se mitiga en la app
        let request = try req.content.decode(ProductRequest.self)
        
        let query = Product.query(on: req.db)
            .filter(\.$subsidiary.$id == request.subsidiaryId)
            .filter(\.$updatedAt >= request.updatedSince)
            .sort(\.$updatedAt, .ascending)
            .with(\.$imageUrl)
            .limit(50)
        
        let products = try await query.all()
        
        return products.mapToListProductDTO()
    }
    
    func save(req: Request) async throws -> HTTPStatus {
        let productDTO = try req.content.decode(ProductDTO.self)
        let imageUrlDTO = productDTO.imageUrl
        
        return try await req.db.transaction { transaction in
            if let imageURLDTONN = imageUrlDTO {
                if let imageUrl = try await ImageUrl.find(imageURLDTONN.id, on: transaction) {
                    //Update
                    imageUrl.imageUrl = imageURLDTONN.imageUrl
                    imageUrl.imageHash = imageURLDTONN.imageHash
                    try await imageUrl.update(on: transaction)
                } else {
                    //Create
                    let imageUrlNew = imageURLDTONN.toImageUrl()
                    try await imageUrlNew.save(on: transaction)
                }
            }
            if let product = try await Product.find(productDTO.id, on: transaction) {
                //Update
                product.productName = productDTO.productName
                product.barCode = productDTO.barCode
                product.active = productDTO.active
                product.expirationDate = productDTO.expirationDate
                product.quantityStock = productDTO.quantityStock
                product.unitType = productDTO.unitType
                product.unitCost = productDTO.unitCost
                product.unitPrice = productDTO.unitPrice
//                product.$subsidiary.id = productDTO.subsidiaryId
                product.$imageUrl.id = productDTO.imageUrl?.id
                try await product.update(on: transaction)
            } else {
                //Create
                let productNew = productDTO.toProduct()
                try await productNew.save(on: transaction)
            }
            return .ok
        }
    }
    
    func bulkCreate(req: Request) async throws -> HTTPStatus {
        //No controla elementos repetidos osea Update
        let productsDTO = try req.content.decode([ProductDTO].self)
        
        // Iniciar la transacción
        return try await req.db.transaction { transaction in
            // Iterar sobre cada producto y guardarlo
            for productDTO in productsDTO {
                let imageUrlDTO = productDTO.imageUrl
                if let imageUrl = imageUrlDTO?.toImageUrl() {
                    try await imageUrl.save(on: transaction)
                }
                let product = productDTO.toProduct()
                try await product.save(on: transaction)
            }
            return .ok // Todo se guardó exitosamente
        }
    }
}

struct ProductRequest: Content {
    let subsidiaryId: UUID
    let updatedSince: Date
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
    let imageUrl: ImageURLDTO?
    let createdAt: Date?
    let updatedAt: Date?
}

struct ImageURLDTO: Content {
    let id: UUID
    let imageUrl: String
    let imageHash: String
}

extension Array where Element == Product {
    func mapToListProductDTO() -> [ProductDTO] {
        return self.compactMap({$0.toProductDTO()})
    }
}

extension ProductDTO {
    func toProduct() -> Product {
        return Product(
            id: id,
            productName: productName,
            barCode: barCode,
            active: active,
            expirationDate: expirationDate,
            unitType: unitType,
            quantityStock: quantityStock,
            unitCost: unitCost,
            unitPrice: unitPrice,
            subsidiaryID: subsidiaryId,
            imageUrlID: imageUrl?.id
        )
    }
}

extension Product {
    func toProductDTO() -> ProductDTO {
        return ProductDTO(
            id: id!,
            productName: productName,
            barCode: barCode,
            active: active,
            expirationDate: expirationDate,
            quantityStock: quantityStock,
            unitType: unitType,
            unitCost: unitCost,
            unitPrice: unitPrice,
            subsidiaryId: self.$subsidiary.id,
            imageUrl: imageUrl?.toImageUrlDTO(),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension ImageURLDTO {
    func toImageUrl() -> ImageUrl {
        return ImageUrl(
            id: id,
            imageUrl: imageUrl,
            imageHash: imageHash
        )
    }
}

extension ImageUrl {
    func toImageUrlDTO() -> ImageURLDTO {
        return ImageURLDTO(
            id: id!,
            imageUrl: imageUrl,
            imageHash: imageHash
        )
    }
}
