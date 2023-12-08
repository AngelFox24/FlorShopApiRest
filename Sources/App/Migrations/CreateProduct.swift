import Fluent

struct CreateProduct: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("products")
            .id()
            .field("productName", .string, .required)
            .field("active", .bool, .required)
            .field("expirationDate", .date)
            .field("quantityStock", .int, .required)
            .field("unitCost", .double, .required)
            .field("unitPrice", .double, .required)
            .field("subsidiary_id", .uuid, .references("subsidiaries", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("products").delete()
    }
}
