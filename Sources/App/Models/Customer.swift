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
    var totalDebt: Int
    @Field(key: "creditScore")
    var creditScore: Int
    @Field(key: "creditDays")
    var creditDays: Int
    @Field(key: "isCreditLimitActive")
    var isCreditLimitActive: Bool
    @Field(key: "isCreditLimit")
    var isCreditLimit: Bool
    @Field(key: "isDateLimitActive")
    var isDateLimitActive: Bool
    @Field(key: "isDateLimit")
    var isDateLimit: Bool
    @Field(key: "dateLimit")
    var dateLimit: Date
    @Field(key: "firstDatePurchaseWithCredit")
    var firstDatePurchaseWithCredit: Date?
    @Field(key: "lastDatePurchase")
    var lastDatePurchase: Date
    @Field(key: "phoneNumber")
    var phoneNumber: String
    @Field(key: "creditLimit")
    var creditLimit: Int
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    
    //MARK: Relationship
    @Parent(key: "company_id")
    var company: Company
    
    //Imagen se debe pedir en el JSON
    @OptionalParent(key: "imageUrl_id")
    var imageUrl: ImageUrl?
    
    @Children(for: \.$customer)
    var toSale: [Sale]
    
    init() { }
    
    init(
        id: UUID? = nil,
        name: String,
        lastName: String,
        totalDebt: Int,
        creditScore: Int,
        creditDays: Int,
        isCreditLimitActive: Bool,
        isCreditLimit: Bool,
        isDateLimitActive: Bool,
        isDateLimit: Bool,
        dateLimit: Date,
        firstDatePurchaseWithCredit: Date?,
        lastDatePurchase: Date,
        phoneNumber: String,
        creditLimit: Int,
        companyID: Company.IDValue,
        imageUrlID: ImageUrl.IDValue?
    ) {
        self.id = id
        self.name = name
        self.lastName = lastName
        self.totalDebt = totalDebt
        self.creditScore = creditScore
        self.creditDays = creditDays
        self.isCreditLimitActive = isCreditLimitActive
        self.isCreditLimit = isCreditLimit
        self.isDateLimitActive = isDateLimitActive
        self.isDateLimit = isDateLimit
        self.dateLimit = dateLimit
        self.firstDatePurchaseWithCredit = firstDatePurchaseWithCredit
        self.lastDatePurchase = lastDatePurchase
        self.phoneNumber = phoneNumber
        self.creditLimit = creditLimit
        self.$company.id = companyID
        self.$imageUrl.id = imageUrlID
    }
}
