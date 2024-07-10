import Fluent

struct CreateEmployee: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("employees")
            .id()
            .field("user", .string, .required)
            .field("name", .string, .required)
            .field("lastName", .string, .required)
            .field("email", .string, .required)
            .field("phoneNumber", .string, .required)
            .field("role", .string, .required)
            .field("active", .bool, .required)
            .field("subsidiary_id", .uuid, .required, .references("subsidiaries", "id"))
            .field("imageUrl_id", .uuid, .references("imageUrls", "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("employees").delete()
    }
}
