import Fluent

struct CreateCompany: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("companies")
            .id()
            .field("companyName", .string, .required)
            .field("ruc", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("companies").delete()
    }
}


