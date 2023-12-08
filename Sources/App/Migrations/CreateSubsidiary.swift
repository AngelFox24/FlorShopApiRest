import Fluent

struct CreateSubsidiary: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("subsidiaries")
            .id()
            .field("name", .string, .required)
            .field("company_id", .uuid, .references("companies", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("subsidiaries").delete()
    }
}
