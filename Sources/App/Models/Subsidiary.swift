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
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    //MARK: Relationship
    @Parent(key: "company_id")
    var company: Company
    
    @OptionalParent(key: "imageUrl_id")
    var imageUrl: ImageUrl?
    
    init() { }
    
    init(id: UUID? = nil, name: String, companyID: Company.IDValue, imageUrlID: ImageUrl.IDValue?) {
        self.id = id
        self.name = name
        self.$company.id = companyID
        self.$imageUrl.id = imageUrlID
    }
}
