import Fluent
import Vapor

final class Product: Model, Content {
    static let schema = "products"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "productName")
    var productName: String
    @Field(key: "active")
    var active: Bool
    @Field(key: "expirationDate")
    var expirationDate: Date?
    @Field(key: "quantityStock")
    var quantityStock: Int
    @Field(key: "unitCost")
    var unitCost: Double
    @Field(key: "unitPrice")
    var unitPrice: Double
    
    // Relación uno a muchos: un autor puede tener varios libros
    @Parent(key: "toProduct")
    var toSubsidiary: Subsidiary
    
    @OptionalChild(for: \.$toProduct)
    var toImageUrl: ImageUrl?
    
    init() { }
    
    init(id: UUID? = nil, productName: String, active: Bool, expirationDate: Date? = nil, quantityStock: Int, unitCost: Double, unitPrice: Double, toImageUrlID: UUID? = nil) {
        self.id = id
        self.productName = productName
        self.active = active
        self.expirationDate = expirationDate
        self.quantityStock = quantityStock
        self.unitCost = unitCost
        self.unitPrice = unitPrice
        self.toImageUrl?.id = toImageUrlID
    }
}
