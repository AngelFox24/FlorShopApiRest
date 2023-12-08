import Fluent

struct CreateCompany: Migration {
    func prepare(on database: Database) throws {
        try database.schema("companies")
            .id()
            .field("companyName", .string)
            .field("ruc", .string)
            .create()
    }

    func revert(on database: Database) throws {
        try database.schema("companies").delete()
    }
}

