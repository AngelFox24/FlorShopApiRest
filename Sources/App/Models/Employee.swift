//
//  Employee.swift
//
//
//  Created by Angel Curi Laurente on 7/12/23.
//

import Fluent
import Vapor

final class Employee: Model, Content {
    
    static let schema = "employees"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "user")
    var user: String
    @Field(key: "name")
    var name: String
    @Field(key: "lastName")
    var lastName: String
    @Field(key: "email")
    var email: String
    @Field(key: "phoneNumber")
    var phoneNumber: String
    @Field(key: "role")
    var role: String
    @Field(key: "active")
    var active: Bool
    
    //MARK: Relationship
    @Parent(key: "subsidiary_id")
    var subsidiary: Subsidiary
    
    //Imagen se debe pedir en el JSON
    @OptionalParent(key: "imageUrl_id")
    var imageUrl: ImageUrl?
    
    @Children(for: \.$employee)
    var toSale: [Sale]
    
    init() { }
    
    init(id: UUID? = nil, user: String, name: String, lastName: String, email: String, phoneNumber: String, role: String, active: Bool, subsidiaryID: Subsidiary.IDValue, imageUrlID: ImageUrl.IDValue?) {
        self.id = id
        self.user = user
        self.name = name
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.role = role
        self.active = active
        self.$subsidiary.id = subsidiaryID
        self.$imageUrl.id = imageUrlID
    }
}
