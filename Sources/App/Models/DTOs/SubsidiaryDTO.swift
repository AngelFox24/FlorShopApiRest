//
//  File.swift
//  
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation
import Vapor

struct SubsidiaryDTO: Content {
    let id: UUID
    let name: String
    let companyID: UUID
    let imageUrl: ImageURLDTO?
    let createdAt: Date?
    let updatedAt: Date?
}
