import Fluent

struct UpdateCompanyParams: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Company.schema)
            .field("subscription_id", .uuid, .references(Suscription.schema, "id", onDelete: .setNull))
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Company.schema)
            .deleteField("subscription_id")
            .update()
    }
}
