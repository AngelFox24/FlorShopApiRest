import Fluent

struct CreateCustomer: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("customers")
            .id()
            .field("name", .string, .required)
            .field("lastName", .string, .required)
            .field("totalDebt", .int, .required)
            .field("creditScore", .int, .required)
            .field("creditDays", .int, .required)
            .field("dateLimit", .date, .required)
            .field("lastDatePurchase", .date, .required)
            .field("firstDatePurchaseWithCredit", .date)
            .field("phoneNumber", .string, .required)
            .field("creditLimit", .int, .required)
            .field("isCreditLimitActive", .bool, .required)
            .field("isCreditLimit", .bool, .required)
            .field("isDateLimitActive", .bool, .required)
            .field("isDateLimit", .bool, .required)
            .field("company_id", .uuid, .required, .references("companies", "id"))
            .field("imageUrl_id", .uuid, .references("imageUrls", "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("customers").delete()
    }
}
