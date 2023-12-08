//
//  Customer.swift
//
//
//  Created by Angel Curi Laurente on 7/12/23.
//

import Fluent
import Vapor

final class Customer: Model, Content {
    static let schema = "customers"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    @Field(key: "lastName")
    var lastName: String
    @Field(key: "totalDebt")
    var totalDebt: Double
    @Field(key: "email")
    var dateLimit: Date
    @Field(key: "phoneNumber")
    var phoneNumber: String
    @Field(key: "creditLimit")
    var creditLimit: Double
    @Field(key: "active")
    var active: Bool
    
    
    //MARK: Relationship
    @Parent(key: "toCustomer")
    var toCompany: Company
    
    @OptionalChild(for: \.$toCustomer)
    var toImageUrl: ImageUrl?
    
    @Children(for: \.$toCustomer)
    var toSales: [Sale]
    
    init() { }
    
    init(id: UUID? = nil, name: String, lastName: String, totalDebt: Double, dateLimit: Date, phoneNumber: String, creditLimit: Double, active: Bool, toImageUrlID: UUID? = nil) {
        self.id = id
        self.name = name
        self.lastName = lastName
        self.totalDebt = totalDebt
        self.dateLimit = dateLimit
        self.phoneNumber = phoneNumber
        self.creditLimit = creditLimit
        self.active = active
        self.toImageUrl?.id = toImageUrlID
    }
}
