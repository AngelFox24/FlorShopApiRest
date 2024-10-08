import Fluent

struct CreateSaleDetail: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("saleDetails")
            .id()
            .field("productName", .string, .required)
            .field("barCode", .string, .required)
            .field("quantitySold", .int, .required)
            .field("subtotal", .int, .required)
            .field("unitType", .string, .required)
            .field("unitCost", .int, .required)
            .field("unitPrice", .int, .required)
            .field("sale_id", .uuid, .required, .references("sales", "id"))
            .field("imageUrl_id", .uuid, .references("imageUrls", "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("saleDetails").delete()
    }
}
