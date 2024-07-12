//
//  File.swift
//  
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation
import Vapor

struct ImageURLDTO: Content {
    let id: UUID
    let imageUrl: String
    let imageHash: String
    let createdAt: Date?
    let updatedAt: Date?
}
