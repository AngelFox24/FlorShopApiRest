//
//  File.swift
//  
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation
import Vapor

struct SaleDTO: Content {
    let id: UUID
    let paymentType: String
    let saleDate: Date
    let total: Int
    let subsidiaryId: UUID
    let customerId: UUID?
    let employeeId: UUID
    let saleDetail: [SaleDetailDTO]
    let createdAt: Date?
    let updatedAt: Date?
}
