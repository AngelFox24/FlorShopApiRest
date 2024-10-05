import Fluent
import Vapor

struct ProductController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let products = routes.grouped("products")
        products.post("sync", use: sync)
        products.post(use: save)
        products.post("bulkCreate", use: bulkCreate)
    }
    func sync(req: Request) async throws -> SyncProductsResponse {
        let request = try req.content.decode(SyncFromSubsidiaryParameters.self)
        guard try SyncTimestamp.shared.shouldSync(clientSyncIds: request.syncIds, entity: .product) else {
            return SyncProductsResponse(
                productsDTOs: [],
                syncIds: SyncTimestamp.shared.getLastSyncDate()
            )
        }
        let maxPerPage: Int = 50
        let query = Product.query(on: req.db)
            .filter(\.$subsidiary.$id == request.subsidiaryId)
            .filter(\.$updatedAt >= request.updatedSince)
            .sort(\.$updatedAt, .ascending)
            .with(\.$imageUrl)
            .limit(maxPerPage)
        let products = try await query.all()
        return SyncProductsResponse(
            productsDTOs: products.mapToListProductDTO(),
            syncIds: products.count == maxPerPage ? SyncTimestamp.shared.getLastSyncDateTemp(entity: .product) : SyncTimestamp.shared.getLastSyncDate()
        )
    }
    func save(req: Request) async throws -> DefaultResponse {
        let productDTO = try req.content.decode(ProductDTO.self)
        guard productDTO.productName != "" else {
            throw Abort(.badRequest, reason: "El nombre del producto no puede ser vacio")
        }
        if let product = try await Product.find(productDTO.id, on: req.db) {
            //Update
            if product.productName != productDTO.productName {
                guard try await !productNameExist(productDTO: productDTO, db: req.db) else {
                    throw Abort(.badRequest, reason: "El nombre del producto ya existe")
                }
                product.productName = productDTO.productName
            }
            if product.barCode != productDTO.barCode {
                guard try await !productBarCodeExist(productDTO: productDTO, db: req.db) else {
                    throw Abort(.badRequest, reason: "El codigo de barras del producto ya existe")
                }
                product.barCode = productDTO.barCode
            }
            product.active = productDTO.active
            product.expirationDate = productDTO.expirationDate
            product.quantityStock = productDTO.quantityStock
            product.unitType = productDTO.unitType
            product.unitCost = productDTO.unitCost
            product.unitPrice = productDTO.unitPrice
            product.$imageUrl.id = try await ImageUrl.find(productDTO.imageUrlId, on: req.db)?.id
            try await product.update(on: req.db)
            SyncTimestamp.shared.updateLastSyncDate(to: .product)
            return DefaultResponse(
                code: 200,
                message: "Updated",
                syncIds: SyncTimestamp.shared.getLastSyncDate()
            )
        } else {
            guard let subsidiaryId = try await Subsidiary.find(productDTO.subsidiaryId, on: req.db)?.id else {
                throw Abort(.badRequest, reason: "La subsidiaria no existe")
            }
            guard try await !productNameExist(productDTO: productDTO, db: req.db) else {
                throw Abort(.badRequest, reason: "El nombre del producto ya existe")
            }
            guard try await !productBarCodeExist(productDTO: productDTO, db: req.db) else {
                throw Abort(.badRequest, reason: "El codigo de barras del producto ya existe")
            }
            //Create
            let productNew = Product(
                id: UUID(),
                productName: productDTO.productName,
                barCode: productDTO.barCode,
                active: productDTO.active,
                expirationDate: productDTO.expirationDate,
                unitType: productDTO.unitType,
                quantityStock: productDTO.quantityStock,
                unitCost: productDTO.unitCost,
                unitPrice: productDTO.unitPrice,
                subsidiaryID: subsidiaryId,
                imageUrlID: try await ImageUrl.find(productDTO.imageUrlId, on: req.db)?.id
            )
            try await productNew.save(on: req.db)
            SyncTimestamp.shared.updateLastSyncDate(to: .product)
            return DefaultResponse(
                code: 200,
                message: "Created",
                syncIds: SyncTimestamp.shared.getLastSyncDate()
            )
        }
    }
    private func productNameExist(productDTO: ProductDTO, db: any Database) async throws -> Bool {
        guard productDTO.productName != "" else {
            print("Producto existe vacio aunque no exista xd")
            return true
        }
        let query = try await Product.query(on: db)
            .filter(\.$productName == productDTO.productName)
            .limit(1)
            .first()
        if query != nil {
            return true
        } else {
            return false
        }
    }
    private func productBarCodeExist(productDTO: ProductDTO, db: any Database) async throws -> Bool {
        guard productDTO.barCode != "" else {
            print("Producto barcode vacio aunque no exista xd")
            return false
        }
        let query = try await Product.query(on: db)
            .filter(\.$barCode == productDTO.barCode)
            .limit(1)
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
            return DefaultResponse(
                code: 200,
                message: "Ok",
                syncIds: SyncTimestamp.shared.getLastSyncDate()
            )
        }
    }
}
