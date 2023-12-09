import Fluent

struct CreateEmployee: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("employees")
            .id()
            .field("user", .string, .required)
            .field("name", .string, .required)
            .field("lastName", .string, .required)
            .field("email", .string, .required)
            .field("phoneNumber", .string, .required)
            .field("role", .string, .required)
            .field("active", .bool, .required)
            .field("subsidiary_id", .uuid, .required, .references("subsidiaries", "id"))
            .field("imageUrl_id", .uuid, .references("imageUrls", "id"))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("employees").delete()
    }
}
