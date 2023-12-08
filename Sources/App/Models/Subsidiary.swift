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
    @OptionalParent(key: "company_id")
    var companyId: UUID?
    
    @OptionalParent(key: "imageUrl_id")
    var imageUrl: ImageUrl?
    
    init() { }
    
    init(id: UUID? = nil, name: String, companyId: UUID? = nil, imageUrl: ImageUrl? = nil) {
        self.id = id
        self.name = name
        self.companyId = companyId
        self.imageUrl = imageUrl
    }
}
