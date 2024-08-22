import Fluent
import Vapor

struct ProductController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let products = routes.grouped("products")
        products.post("sync", use: sync)
        products.post(use: save)
        products.post("bulkCreate", use: bulkCreate)
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
    func save(req: Request) async throws -> DefaultResponse {
        let productDTO = try req.content.decode(ProductDTO.self)
            if let product = try await Product.find(productDTO.id, on: req.db) {
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
                product.$imageUrl.id = productDTO.imageUrlId //Solo se registra Id porque la imagen se guarda en ImageUrlController
                try await product.update(on: req.db)
            } else if try await productExist(productDTO: productDTO, db: req.db) {
                print("El producto ya existe")
                throw Abort(.badRequest, reason: "El producto ya existe")
            } else {
                //Create
                let productNew = productDTO.toProduct()
                try await productNew.save(on: req.db)
            }
            return DefaultResponse(code: 200, message: "Ok")
//        }
    }
    private func productExist(productDTO: ProductDTO, db: any Database) async throws -> Bool {
        let productName = productDTO.productName
        let barCode = productDTO.barCode
        let query = try await Product.query(on: db)
            .group(.or) { orGroup in
                orGroup.filter(\.$productName == productName)
                    .filter(\.$barCode == barCode)
            }
            .first()
        if query != nil {
            return true
        } else {
            return false
        }
    }
    func bulkCreate(req: Request) async throws -> DefaultResponse {
        //No controla elementos repetidos osea Update
        let productsDTO = try req.content.decode([ProductDTO].self)
        
        // Iniciar la transacción
        return try await req.db.transaction { transaction in
            // Iterar sobre cada producto y guardarlo
            for productDTO in productsDTO {
                let imageUrlDTO = productDTO.imageUrlId
//                if let imageUrl = imageUrlDTO?.toImageUrl() {
//                    try await imageUrl.save(on: transaction)
//                }
                let product = productDTO.toProduct()
                try await product.save(on: transaction)
            }
            return DefaultResponse(code: 200, message: "Ok")
        }
    }
}
