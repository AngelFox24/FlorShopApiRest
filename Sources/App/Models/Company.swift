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
    
    //MARK: Relationship
    
    init() { }
    
    init(id: UUID? = nil, companyName: String, ruc: String) {
        self.id = id
        self.companyName = companyName
        self.ruc = ruc
    }
}
