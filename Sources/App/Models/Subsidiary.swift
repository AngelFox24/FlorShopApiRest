//
//  Subsidiary.swift
//
//
//  Created by Angel Curi Laurente on 7/12/23.
//

import Fluent
import Vapor

final class Subsidiary: Model, Content {
    
    static let schema = "subsidiaries"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    //MARK: Relationship
    @Parent(key: "company_id")
    var toCompany: Company
    
    @Children(for: \.$toSubsidiary)
    var toEmployee: [Employee]
    
    @OptionalChild(for: \.$toSubsidiary)
    var toImageUrl: ImageUrl?
    
    @Children(for: \.$toSubsidiary)
    var toProduct: [Product]
    
    @Children(for: \.$toSubsidiary)
    var toSale: [Sale]
    
    init() { }
    
    init(id: UUID? = nil, name: String, toImageUrlID: UUID? = nil) {
        self.id = id
        self.name = name
        self.toImageUrl?.id = toImageUrlID
    }
}
