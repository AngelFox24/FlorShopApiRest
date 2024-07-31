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
        //TODO: Pagination
        try await Product.query(on: req.db).with(\.$imageUrl).all().mapToListProductDTO()
    }
    func sync(req: Request) async throws -> [ProductDTO] {
        //Precicion de segundos solamente
        //No se requiere mas precicion ya que el objetivo es sincronizar y en caso haya repetidos esto se mitiga en la app
        let request = try req.content.decode(SyncFromSubsidiaryParameters.self)
        
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
        
        return try await req.db.transaction { transaction in
            if let imageURLDTO = productDTO.imageUrl {
                if let imageUrl = try await ImageUrl.find(imageURLDTO.id, on: transaction) {
                    //Update
                    imageUrl.imageUrl = imageURLDTO.imageUrl
                    imageUrl.imageHash = imageURLDTO.imageHash
                    try await imageUrl.update(on: transaction)
                } else {
                    //Create
                    let imageUrlNew = imageURLDTO.toImageUrl()
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

struct SyncFromSubsidiaryParameters: Content {
    let subsidiaryId: UUID
    let updatedSince: Date
}
