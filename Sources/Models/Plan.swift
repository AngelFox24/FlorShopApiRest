import Vapor
import Fluent
import FlorShopDTOs

final class Plan: Model, @unchecked Sendable {
    static let schema = "plan"

    @ID var id: UUID?
    
    @Field(key: "plan_cic") var planCic: String
    @Field(key: "name") var name: String
    @Field(key: "price") var price: Int
    @Enum(key: "currency") var currency: Currency
    @Enum(key: "interval") var interval: BillingInterval
    @Field(key: "is_active") var isActive: Bool

    @Children(for: \.$plan) var features: [PlanFeature]
    
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?

    init() {}

    init(
        planCic: String,
        name: String,
        price: Int,
        currency: Currency,
        interval: BillingInterval,
        isActive: Bool = true
    ) {
        self.planCic = planCic
        self.name = name
        self.price = price
        self.currency = currency
        self.interval = interval
        self.isActive = isActive
    }
}

extension Plan {
    func toDTO() -> PlanDTO {
        PlanDTO(
            planCic: self.planCic,
            name: self.name,
            price: Money(self.price),
            currency: self.currency,
            interval: self.interval,
            isActive: self.isActive,
            limits: self.features.toDTOs()
        )
    }
}

extension Plan {
    static func getPlan(planCic: String, on db: any Database) async throws -> Plan? {
        return try await Plan.query(on: db)
            .filter(Plan.self, \.$planCic == planCic)
            .with(\.$features)
            .first()
    }
    static func nameExist(name: String, on db: any Database) async throws -> Bool {
        let plan = try await Plan.query(on: db)
            .filter(Plan.self, \.$name == name)
            .first()
        return plan != nil
    }
}
