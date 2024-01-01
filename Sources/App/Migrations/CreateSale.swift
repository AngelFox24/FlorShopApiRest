import Fluent

struct CreateSale: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        print("Se esta migrando")
        return database.schema("sales")
            .id()
            .field("paid", .bool, .required)
            .field("paymentType", .string, .required)
            .field("saleDate", .date, .required)
            .field("total", .double, .required)
            .field("customer_id", .uuid, .references("customers", "id"))
            .field("employee_id", .uuid, .required, .references("employees", "id"))
            .field("subsidiary_id", .uuid, .required, .references("subsidiaries", "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("sales").delete()
    }
}
