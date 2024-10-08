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
    
    @Field(key: "paymentType")
    var paymentType: String
    @Field(key: "saleDate")
    var saleDate: Date
    @Field(key: "total")
    var total: Int
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    //MARK: Relationship
    @Parent(key: "subsidiary_id")
    var subsidiary: Subsidiary
    
    @OptionalParent(key: "customer_id")
    var customer: Customer?
    
    @Parent(key: "employee_id")
    var employee: Employee
    
    @Children(for: \.$sale)
    var toSaleDetail: [SaleDetail]
    
    init() { }
    
    init(
        id: UUID? = nil,
        paymentType: String,
        saleDate: Date,
        total: Int,
        subsidiaryID: Subsidiary.IDValue,
        customerID: Customer.IDValue?,
        employeeID: Employee.IDValue
    ) {
        self.id = id
        self.paymentType = paymentType
        self.saleDate = saleDate
        self.total = total
        self.$subsidiary.id = subsidiaryID
        self.$customer.id = customerID
        self.$employee.id = employeeID
    }
}
