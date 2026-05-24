import Fluent
import Foundation
import struct Foundation.UUID

final class Subsidiary: Model, @unchecked Sendable {
    static let schema = "subsidiaries"
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "subsidiary_cic") var subsidiaryCic: String
    @Field(key: "name") var name: String
    @Field(key: "image_url") var imageUrl: String?
    @Field(key: "company_cic") var companyCic: String
    
    //MARK: Timestamps
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    
    //MARK: Relationship
    @Parent(key: "company_id") var company: Company
    
    init() { }
    
    init(
        subsidiaryCic: String,
        name: String,
        imageUrl: String?,
        companyCic: String,
        companyID: Company.IDValue
    ) {
        self.subsidiaryCic = subsidiaryCic
        self.name = name
        self.imageUrl = imageUrl
        self.companyCic = companyCic
        self.$company.id = companyID
    }
}

extension Subsidiary {
    static func findSubsidiary(subsidiaryCic: String, on db: any Database) async throws -> Subsidiary? {
        return try await Subsidiary.query(on: db)
            .filter(Subsidiary.self, \.$subsidiaryCic == subsidiaryCic)
            .first()
    }
    static func subsidiaryExist(subsidiaryCic: String, on db: any Database) async throws -> Bool {
        ((try await Subsidiary.query(on: db)
            .filter(Subsidiary.self, \.$subsidiaryCic == subsidiaryCic)
            .first()) != nil)
    }
    static func nameExist(name: String, on db: any Database) async throws -> Bool {
        if let _ = try await Subsidiary.query(on: db)
            .filter(Subsidiary.self, \.$name == name)
            .first() {
            return true
        } else {
            return false
        }
    }
}
