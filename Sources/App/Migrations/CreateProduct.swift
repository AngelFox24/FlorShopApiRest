import Fluent

struct CreateProduct: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("products")
            .id()
            .field("productName", .string, .required)
            .field("active", .bool, .required)
            .field("expirationDate", .date)
            .field("quantityStock", .int, .required)
            .field("unitCost", .double, .required)
            .field("unitPrice", .double, .required)
            .field("subsidiary_id", .uuid, .required, .references("subsidiaries", "id"))
            .field("imageUrl_id", .uuid, .references("imageUrls", "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("products").delete()
    }
}
