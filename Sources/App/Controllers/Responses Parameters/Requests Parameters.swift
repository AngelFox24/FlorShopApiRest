//
//  Requests Parameters.swift
//  FlorApiRestV1
//
//  Created by Angel Curi Laurente on 05/10/2024.
//
import Vapor
//MARK: Session Parameters
struct LogInParameters: Content {
    let username: String
    let password: String
}
struct SessionConfig: Content {
    let companyId: UUID
    let subsidiaryId: UUID
    let employeeId: UUID
}
//MARK: Sync Parameters
struct SyncCompanyParameters: Content {
    let updatedSince: Date
    let syncIds: VerifySyncParameters
}
struct SyncImageParameters: Content {
    let updatedSince: Date
    let syncIds: VerifySyncParameters
}
struct SyncFromSubsidiaryParameters: Content {
    let subsidiaryId: UUID
    let updatedSince: Date
    let syncIds: VerifySyncParameters
}
struct SyncFromCompanyParameters: Content {
    let companyId: UUID
    let updatedSince: Date
    let syncIds: VerifySyncParameters
}
//MARK: Request Parameters
struct PayCustomerDebtParameters: Content {
    let customerId: UUID
    let amount: Int
}
struct RegisterSaleParameters: Content {
    let subsidiaryId: UUID
    let employeeId: UUID
    let customerId: UUID?
    let paymentType: String
    let cart: CartDTO
}
