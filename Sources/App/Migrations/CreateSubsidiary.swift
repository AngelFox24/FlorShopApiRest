import Fluent

struct CreateSubsidiary: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("subsidiaries")
            .id()
            .field("name", .string, .required)
            .field("company_id", .uuid, .required, .references("companies", "id"))
            .field("imageUrl_id", .uuid, .references("imageUrls", "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("subsidiaries").delete()
    }
}
