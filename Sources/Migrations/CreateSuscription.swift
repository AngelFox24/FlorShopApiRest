import Fluent

struct CreateSuscription: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Suscription.schema)
            .id()
            .field("suscription_cic", .string, .required)
            .field("plan_id", .uuid, .required, .references(Plan.schema, "id", onDelete: .restrict))
            .field("company_cic", .string, .required)
            .field("status", .string, .required)
            .field("start_at", .datetime, .required)
            .field("end_at", .datetime, .required)
            .field("cancel_at_period_end", .bool, .required, .sql(.default(false)))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "suscription_cic")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Suscription.schema).delete()
    }
}
