import Fluent

struct CreateSubsidiary: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("subsidiaries")
            .id()
            .field("name", .string, .required)
            .field("company_id", .uuid, .required, .references("companies", "id"))
            .field("imageUrl_id", .uuid, .references("imageUrls", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("subsidiaries").delete()
    }
}
