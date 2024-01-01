import Fluent

struct CreateImageUrl: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("imageUrls")
            .id()
            .field("imageUrl", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("imageUrls").delete()
    }
}
