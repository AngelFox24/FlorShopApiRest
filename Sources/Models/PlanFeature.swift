import Vapor
import Fluent
import FlorShopDTOs

final class PlanFeature: Model, @unchecked Sendable {
    static let schema = "plan_feature"

    @ID var id: UUID?
    
    @Parent(key: "plan_id") var plan: Plan

    @Field(key: "key") var key: String
    @Field(key: "label") var label: String
    @Field(key: "is_web_visible") var isWebVisible: Bool
    @Field(key: "value_int") var valueInt: Int?
    @Field(key: "value_string") var valueString: String?
    @Field(key: "value_bool") var valueBool: Bool?

    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?

    init() {}

    init(
        planId: UUID,
        key: String,
        label: String,
        isWebVisible: Bool,
        valueInt: Int? = nil,
        valueString: String? = nil,
        valueBool: Bool? = nil
    ) {
        self.$plan.id = planId
        self.key = key
        self.label = label
        self.isWebVisible = isWebVisible
        self.valueInt = valueInt
        self.valueString = valueString
        self.valueBool = valueBool
    }
}

extension PlanFeature {
    static func getPlanFeatures(planCic: String, on db: any Database) async throws -> [PlanFeature] {
        return try await PlanFeature.query(on: db)
            .join(Plan.self, on: \Plan.$id == \PlanFeature.$plan.$id)
            .filter(Plan.self, \.$planCic == planCic)
            .all()
    }
}

extension PlanFeature {
    func toDTO() -> PlanLimitDTO {
        return PlanLimitDTO(
            key: key,
            label: label,
            isWebVisible: isWebVisible,
            valueInt: valueInt,
            valueString: valueString,
            valueBool: valueBool
        )
    }
}

extension Array where Element == PlanFeature {
    func toDTOs() -> [PlanLimitDTO] {
        return compactMap { $0.toDTO() }
    }
}
