import Fluent

struct CreateSale: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("sales")
            .id()
            .field("paid", .bool, .required)
            .field("paymentType", .string, .required)
            .field("saleDate", .date, .required)
            .field("total", .double, .required)
            .field("customer_id", .uuid, .references("customers", "id"))
            .field("employee_id", .uuid, .references("employees", "id"))
            .field("subsidiary_id", .uuid, .references("subsidiaries", "id"))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("sales").delete()
    }
}
