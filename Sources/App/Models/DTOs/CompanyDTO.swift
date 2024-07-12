//
//  File.swift
//  
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation
import Vapor

struct CompanyDTO: Content {
    let id: UUID
    let companyName: String
    let ruc: String
    let createdAt: Date?
    let updatedAt: Date?
}
