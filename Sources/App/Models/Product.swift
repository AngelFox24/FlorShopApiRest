import Fluent
import Vapor

final class Product: Model, Content {
    static let schema = "products"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "active")
    var active: Bool
    @Field(key: "expirationDate")
    var expirationDate: Date
    @Field(key: "productName")
    var productName: String
    @Field(key: "quantityStock")
    var quantityStock: Int
    @Field(key: "unitCost")
    var unitCost: Double
    @Field(key: "unitPrice")
    var unitPrice: Double
    
    init() { }

    init(id: UUID? = nil, active: Bool, expirationDate: Date, productName: String, quantityStock: Int, unitCost: Double, unitPrice: Double) {
        self.id = id
        self.active = active
        self.expirationDate = expirationDate
        self.productName = productName
        self.quantityStock = quantityStock
        self.unitCost = unitCost
        self.unitPrice = unitPrice
    }
}
