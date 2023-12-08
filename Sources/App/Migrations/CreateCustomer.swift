import Fluent

struct CreateCustomer: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("customers")
            .id()
            .field("name", .string, .required)
            .field("lastName", .string, .required)
            .field("totalDebt", .double, .required)
            .field("dateLimit", .date, .required)
            .field("phoneNumber", .string, .required)
            .field("creditLimit", .double, .required)
            .field("active", .bool, .required)
            .field("company_id", .uuid, .references("companies", "id"))
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("customers").delete()
    }
}
