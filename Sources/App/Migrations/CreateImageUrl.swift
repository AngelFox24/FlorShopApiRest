import Fluent

struct CreateImageUrl: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("imageUrls")
            .id()
            .field("imageUrl", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("imageUrls").delete()
    }
}
