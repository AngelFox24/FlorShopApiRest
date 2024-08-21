//
//  File.swift
//  
//
//  Created by Angel Curi Laurente on 15/08/2024.
//

import Fluent
import Vapor

struct LogInParameters: Content {
    let username: String
    let password: String
}

struct SessionConfig: Content {
    let companyId: UUID
    let subsidiaryId: UUID
    let employeeId: UUID
}

struct SyncCompanyParameters: Content {
    let updatedSince: Date
}

struct SyncImageParameters: Content {
    let updatedSince: Date
}

struct SyncFromSubsidiaryParameters: Content {
    let subsidiaryId: UUID
    let updatedSince: Date
}

struct SyncFromCompanyParameters: Content {
    let companyId: UUID
    let updatedSince: Date
}

struct DefaultResponse: Content {
    let code: Int
    let message: String
}
