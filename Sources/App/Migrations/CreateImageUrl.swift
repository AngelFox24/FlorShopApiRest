import Fluent

struct CreateImageUrl: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("imageUrls")
            .id()
            .field("imageUrl", .string, .required)
            .field("product_id", .uuid, .references("products", "id"))
            .field("customer_id", .uuid, .references("customers", "id"))
            .field("employee_id", .uuid, .references("employees", "id"))
            .field("saleDetail_id", .uuid, .references("saleDetails", "id"))
            .field("subsidiary_id", .uuid, .references("subsidiaries", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("imageUrls").delete()
    }
}
