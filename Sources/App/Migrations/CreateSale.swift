import Foundation

struct CreateSale: Migration {
    func prepare(on database: Database) throws {
        try database.schema("sales")
            .id()
            .field("paid", .bool)
            .field("paymentType", .string)
            .field("saleDate", .date)
            .field("total", .double)
            .field("customer_id", .uuid, .references("customers", "id"))
            .field("employee_id", .uuid, .references("employees", "id"))
            .field("subsidiary_id", .uuid, .references("subsidiaries", "id"))
            .create()
    }

    func revert(on database: Database) throws {
        try database.schema("sales").delete()
    }
}
