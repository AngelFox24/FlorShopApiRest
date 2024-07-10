import Fluent

struct CreateCustomer: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("customers")
            .id()
            .field("name", .string, .required)
            .field("lastName", .string, .required)
            .field("totalDebt", .double, .required)
            .field("dateLimit", .date, .required)
            .field("phoneNumber", .string, .required)
            .field("creditLimit", .double, .required)
            .field("active", .bool, .required)
            .field("company_id", .uuid, .required, .references("companies", "id"))
            .field("imageUrl_id", .uuid, .references("imageUrls", "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("customers").delete()
    }
}
