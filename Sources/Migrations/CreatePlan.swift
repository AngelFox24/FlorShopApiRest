import Fluent

struct CreatePlan: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Plan.schema)
            .id()
            .field("plan_cic", .string, .required)
            .field("name", .string, .required)
            .field("price", .int, .required)
            .field("currency", .string, .required)
            .field("interval", .string, .required)
            .field("is_active", .bool, .required, .sql(.default(true)))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "plan_cic")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Plan.schema).delete()
    }
}
