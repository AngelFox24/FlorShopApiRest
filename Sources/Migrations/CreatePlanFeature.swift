import Fluent

struct CreatePlanFeature: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(PlanFeature.schema)
            .id()
            .field("plan_id", .uuid, .required, .references(Plan.schema, "id", onDelete: .cascade))
            .field("key", .string, .required)
            .field("label", .string, .required)
            .field("is_web_visible", .bool, .required)
            .field("value_int", .int)
            .field("value_string", .string)
            .field("value_bool", .bool)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "plan_id", "key")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(PlanFeature.schema).delete()
    }
}
