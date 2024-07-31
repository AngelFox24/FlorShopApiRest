//
//  File.swift
//  
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation
import Vapor

struct CustomerDTO: Content {
    let id: UUID
    let name: String
    let lastName: String
    let totalDebt: Int
    let creditScore: Int
    let creditDays: Int
    let isCreditLimitActive: Bool
    let isCreditLimit: Bool
    let isDateLimitActive: Bool
    let isDateLimit: Bool
    let dateLimit: Date
    var firstDatePurchaseWithCredit: Date?
    let lastDatePurchase: Date
    let phoneNumber: String
    let creditLimit: Int
    let companyID: UUID
    let imageUrl: ImageURLDTO?
    let createdAt: Date?
    let updatedAt: Date?
}
