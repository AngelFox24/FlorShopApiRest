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
    @Parent(key: "subsidiary_id")
    var subsidiary: Subsidiary
    
    @Parent(key: "customer_id")
    var customer: Customer
    
    @Parent(key: "employee_id")
    var employee: Employee
    
    @Children(for: \.$sale)
    var toSaleDetail: [SaleDetail]
    
    init() { }
    
    init(id: UUID? = nil, paid: Bool, paymentType: String, saleDate: Date, total: Double, subsidiaryID: Subsidiary.IDValue, customerID: Customer.IDValue, employeeID: Employee.IDValue) {
        self.id = id
        self.paid = paid
        self.paymentType = paymentType
        self.saleDate = saleDate
        self.total = total
        self.$subsidiary.id = subsidiaryID
        self.$customer.id = customerID
        self.$employee.id = employeeID
    }
}
