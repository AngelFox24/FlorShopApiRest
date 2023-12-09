import Fluent

struct CreateCompany: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("companies")
            .id()
            .field("companyName", .string, .required)
            .field("ruc", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("companies").delete()
    }
}


