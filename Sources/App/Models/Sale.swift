//
//  Sale.swift
//
//
//  Created by Angel Curi Laurente on 7/12/23.
//

import Fluent
import Vapor

final class Sale: Model, Content {
    static let schema = "sales"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "paid")
    var paid: Bool
    @Field(key: "paymentType")
    var paymentType: String
    @Field(key: "saleDate")
    var saleDate: Date
    @Field(key: "total")
    var total: Double
    
    //MARK: Relationship
    @Parent(key: "toSale")
    var toCustomer: Customer
    
    @Parent(key: "toSale")
    var toEmployee: Employee
    
    @Parent(key: "toSale")
    var toSubsidiary: Subsidiary
    
    @Children(for: \.$toSale)
    var toSaleDetail: [SaleDetail]
    
    init() { }
    
    init(id: UUID? = nil, paid: Bool, paymentType: String, saleDate: Date, total: Double, toCustomer: Customer, toEmployee: Employee, toSubsidiary: Subsidiary) {
        self.id = id
        self.paid = paid
        self.paymentType = paymentType
        self.saleDate = saleDate
        self.total = total
        self.$toCustomer.id = try! toCustomer.requireID()
        self.$toEmployee.id = try! toEmployee.requireID()
        self.$toSubsidiary.id = try! toSubsidiary.requireID()
    }
}
