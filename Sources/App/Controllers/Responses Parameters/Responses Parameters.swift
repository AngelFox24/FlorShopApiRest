//
//  File.swift
//  
//
//  Created by Angel Curi Laurente on 15/08/2024.
//
import Vapor
//MARK: Response Parameters
struct DefaultResponse: Content {
    let code: Int
    let message: String
    let syncIds: VerifySyncParameters
}
struct PayCustomerDebtResponse: Content {
    let customerId: UUID
    let change: Int
    let syncIds: VerifySyncParameters
}
struct SaveImageResponse: Content {
    let imageUrlDTO: ImageURLDTO
    let syncIds: VerifySyncParameters
}
//MARK: Sync Response Parameters
struct SyncCompanyResponse: Content {
    let companyDTO: CompanyDTO?
    let syncIds: VerifySyncParameters
}
struct SyncCustomersResponse: Content {
    let customersDTOs: [CustomerDTO]
    let syncIds: VerifySyncParameters
}
struct SyncEmployeesResponse: Content {
    let employeesDTOs: [EmployeeDTO]
    let syncIds: VerifySyncParameters
}
struct SyncImageUrlResponse: Content {
    let imagesUrlDTOs: [ImageURLDTO]
    let syncIds: VerifySyncParameters
}
struct SyncProductsResponse: Content {
    let productsDTOs: [ProductDTO]
    let syncIds: VerifySyncParameters
}
struct SyncSalesResponse: Content {
    let salesDTOs: [SaleDTO]
    let syncIds: VerifySyncParameters
}
struct SyncSubsidiariesResponse: Content {
    let subsidiariesDTOs: [SubsidiaryDTO]
    let syncIds: VerifySyncParameters
}
//MARK: SubResponse Parameters
struct VerifySyncParameters: Content {
    let imageLastUpdate: UUID
    let companyLastUpdate: UUID
    let subsidiaryLastUpdate: UUID
    let customerLastUpdate: UUID
    let productLastUpdate: UUID
    let employeeLastUpdate: UUID
    let saleLastUpdate: UUID
}
