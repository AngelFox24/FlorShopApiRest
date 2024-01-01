import Fluent

struct CreateCompany: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("companies")
            .id()
            .field("companyName", .string, .required)
            .field("ruc", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("companies").delete()
    }
}


