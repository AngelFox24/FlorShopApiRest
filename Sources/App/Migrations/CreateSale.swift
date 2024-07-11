import Fluent

struct CreateSale: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("sales")
            .id()
            .field("paid", .bool, .required)
            .field("paymentType", .string, .required)
            .field("saleDate", .date, .required)
            .field("total", .int, .required)
            .field("customer_id", .uuid, .references("customers", "id"))
            .field("employee_id", .uuid, .required, .references("employees", "id"))
            .field("subsidiary_id", .uuid, .required, .references("subsidiaries", "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("sales").delete()
    }
}
