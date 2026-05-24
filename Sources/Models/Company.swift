import Fluent
import Foundation
import struct Foundation.UUID

final class Company: Model, @unchecked Sendable {
    static let schema = "companies"
    
    @ID(key: .id) var id: UUID?
    
    @OptionalParent(key: "subscription_id") var subscription: Suscription?
    @Field(key: "company_cic") var companyCic: String
    @Field(key: "company_name") var companyName: String
    @Field(key: "ruc") var ruc: String
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    
    //MARK: Relationship
    @Children(for: \.$company) var toSubsidiary: [Subsidiary]
    
    init() { }
    
    init(
        suscriptionID: UUID?,
        companyCic: String,
        companyName: String,
        ruc: String
    ) {
        self.$subscription.id = suscriptionID
        self.companyCic = companyCic
        self.companyName = companyName
        self.ruc = ruc
    }
}

extension Company {
    static func findCompany(companyCic: String, on db: any Database) async throws -> Company? {
        try await Company.query(on: db)
            .filter(Company.self, \.$companyCic == companyCic)
            .first()
    }
    static func companyExist(companyCic: String, on db: any Database) async throws -> Bool {
        ((try await Company.query(on: db)
            .filter(Company.self, \.$companyCic == companyCic)
            .first()) != nil)
    }
}
