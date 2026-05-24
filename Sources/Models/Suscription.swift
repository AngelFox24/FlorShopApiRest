import Vapor
import Fluent
import FlorShopDTOs

final class Suscription: Model, @unchecked Sendable {
    static let schema = "suscription"

    @ID var id: UUID?
    
    @Parent(key: "plan_id") var plan: Plan

    @Field(key: "suscription_cic") var suscriptionCic: String
    @Field(key: "company_cic") var companyCic: String
    @Enum(key: "status") var status: SubscriptionStatus
    @Field(key: "start_at") var startAt: Date
    @Field(key: "end_at") var endAt: Date
    @Field(key: "cancel_at_period_end") var cancelAtPeriodEnd: Bool

    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?

    init() {}

    init(
        suscriptionCic: String,
        planID: UUID,
        companyCic: String,
        status: SubscriptionStatus,
        startAt: Date,
        endAt: Date,
        cancelAtPeriodEnd: Bool = false
    ) {
        self.$plan.id = planID
        self.suscriptionCic = suscriptionCic
        self.companyCic = companyCic
        self.status = status
        self.startAt = startAt
        self.endAt = endAt
        self.cancelAtPeriodEnd = cancelAtPeriodEnd
    }
}

extension Suscription {
    static func firstCurrent(companyCic: String, on db: any Database) async throws -> Suscription? {
        try await Suscription.query(on: db)
            .filter(Suscription.self, \.$companyCic == companyCic)
            .filter(Suscription.self, \.$status == .active)
            .filter(Suscription.self, \.$startAt <= Date())
            .filter(Suscription.self, \.$endAt >= Date())
            .with(\.$plan)
            .first()
    }
    static func find(suscriptionCic: String, on db: any Database) async throws -> Suscription? {
        try await Suscription.query(on: db)
            .filter(Suscription.self, \.$suscriptionCic == suscriptionCic)
            .first()
    }
//    static func getSuscriptionInfo(companyCic: String, on db: any Database) async throws -> SuscriptionClientDTO? {
//        guard let suscription = try await Suscription.query(on: db)
//            .filter(Suscription.self, \.$companyCic == companyCic)
//            .filter(Suscription.self, \.$status == .active)
//            .filter(Suscription.self, \.$startAt <= Date())
//            .filter(Suscription.self, \.$endAt >= Date())
//            .with(\.$plan)
//            .first() else {
//            return nil
//        }
//        return SuscriptionClientDTO(suscriptionCic: suscription.suscriptionCic, suscriptionExpireAt: suscription.endAt)
//    }
}

extension Suscription {
    func toDTO() -> SuscriptionServerDTO {
        SuscriptionServerDTO(
            suscriptionCic: self.suscriptionCic,
            companyCic: self.companyCic,
            suscriptionExpireAt: self.endAt,
            planCic: self.plan.planCic,
            status: self.status
        )
    }
    func toClientDTO() -> SuscriptionClientDTO {
        SuscriptionClientDTO(
            suscriptionCic: self.suscriptionCic,
            suscriptionExpireAt: self.endAt,
            planName: self.plan.name,
            planPrice: Money(self.plan.price)
        )
    }
}
