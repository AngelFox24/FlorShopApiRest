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
            .field("sale_id", .uuid, .references("sales", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("saleDetails").delete()
    }
}
