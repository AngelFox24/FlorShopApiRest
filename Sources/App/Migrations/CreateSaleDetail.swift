import Fluent

struct CreateSaleDetail: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("saleDetails")
            .id()
            .field("productName", .string, .required)
            .field("quantitySold", .int, .required)
            .field("subtotal", .double, .required)
            .field("unitCost", .double, .required)
            .field("unitPrice", .double, .required)
            .field("sale_id", .uuid, .required, .references("sales", "id"))
            .field("imageUrl_id", .uuid, .references("imageUrls", "id"))
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("saleDetails").delete()
    }
}
