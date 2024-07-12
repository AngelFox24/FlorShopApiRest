//
//  File.swift
//  
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation
import Vapor

struct SaleDetailDTO: Content {
    let id: UUID
    let productName: String
    let barCode: String
    let quantitySold: Int
    let subtotal: Int
    let unitType: String
    let unitCost: Int
    let unitPrice: Int
    let imageUrlId: UUID
}
