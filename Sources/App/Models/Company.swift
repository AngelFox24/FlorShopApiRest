//
//  Company.swift
//
//
//  Created by Angel Curi Laurente on 7/12/23.
//

import Fluent
import Vapor

final class Company: Model, Content {
    static let schema = "companies"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "companyName")
    var companyName: String
    
    @Field(key: "ruc")
    var ruc: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    //MARK: Relationship
    @Children(for: \.$company)
    var toSubsidiary: [Subsidiary]
    init() { }
    
    init(
        id: UUID? = nil,
        companyName: String,
        ruc: String
    ) {
        self.id = id
        self.companyName = companyName
        self.ruc = ruc
    }
}
