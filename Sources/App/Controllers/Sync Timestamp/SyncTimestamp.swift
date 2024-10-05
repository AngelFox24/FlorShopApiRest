//
//  SyncTimestamp.swift
//  FlorApiRestV1
//
//  Created by Angel Curi Laurente on 05/10/2024.
//
import Fluent
import Vapor

enum SyncEntities {
    case image
    case company
    case subsidiary
    case customer
    case product
    case employee
    case sale
}

final class SyncTimestamp {
    static let shared = SyncTimestamp()  // Singleton
    private init() {}  // Evitar instanciación externa
    
    private var lastSyncImage = UUID()
    private var lastSyncCompany = UUID()
    private var lastSyncSubsidiary = UUID()
    private var lastSyncCustomer = UUID()
    private var lastSyncProduct = UUID()
    private var lastSyncEmployee = UUID()
    private var lastSyncSale = UUID()
    
    // Método para actualizar la última fecha de sincronización
    func updateLastSyncDate(to entity: SyncEntities) {
        switch entity {
        case .image:
            lastSyncImage = UUID()
        case .company:
            lastSyncCompany = UUID()
        case .subsidiary:
            lastSyncSubsidiary = UUID()
        case .customer:
            lastSyncCustomer = UUID()
        case .product:
            lastSyncProduct = UUID()
        case .employee:
            lastSyncEmployee = UUID()
        case .sale:
            lastSyncSale = UUID()
        }
    }
    // Método para obtener la última fecha de sincronización
    func getLastSyncDate() -> VerifySyncParameters {
        return VerifySyncParameters(
            imageLastUpdate: self.lastSyncImage,
            companyLastUpdate: self.lastSyncCompany,
            subsidiaryLastUpdate: self.lastSyncSubsidiary,
            customerLastUpdate: self.lastSyncCustomer,
            productLastUpdate: self.lastSyncProduct,
            employeeLastUpdate: self.lastSyncEmployee,
            saleLastUpdate: self.lastSyncSale
        )
    }
    func getUpdatedSyncTokens(entity: SyncEntities, clientTokens: VerifySyncParameters) -> VerifySyncParameters {
        var lastSyncImageLocal = clientTokens.imageLastUpdate
        var lastSyncCompanyLocal = clientTokens.companyLastUpdate
        var lastSyncSubsidiaryLocal = clientTokens.subsidiaryLastUpdate
        var lastSyncCustomerLocal = clientTokens.customerLastUpdate
        var lastSyncProductLocal = clientTokens.productLastUpdate
        var lastSyncEmployeeLocal = clientTokens.employeeLastUpdate
        var lastSyncSaleLocal = clientTokens.saleLastUpdate
        switch entity {
        case .image:
            lastSyncImageLocal = self.lastSyncImage
        case .company:
            lastSyncCompanyLocal = self.lastSyncCompany
        case .subsidiary:
            lastSyncSubsidiaryLocal = self.lastSyncSubsidiary
        case .customer:
            lastSyncCustomerLocal = self.lastSyncCustomer
        case .product:
            lastSyncProductLocal = self.lastSyncProduct
        case .employee:
            lastSyncEmployeeLocal = self.lastSyncEmployee
        case .sale:
            lastSyncSaleLocal = self.lastSyncSale
        }
        return VerifySyncParameters(
            imageLastUpdate: lastSyncImageLocal,
            companyLastUpdate: lastSyncCompanyLocal,
            subsidiaryLastUpdate: lastSyncSubsidiaryLocal,
            customerLastUpdate: lastSyncCustomerLocal,
            productLastUpdate: lastSyncProductLocal,
            employeeLastUpdate: lastSyncEmployeeLocal,
            saleLastUpdate: lastSyncSaleLocal
        )
    }
    func shouldSync(clientSyncIds: VerifySyncParameters, entity: SyncEntities) throws -> Bool {
        var parentUpToDate: Bool = true
        switch entity {
        case .image:
            return self.lastSyncImage != clientSyncIds.imageLastUpdate
        case .company:
            return self.lastSyncCompany != clientSyncIds.companyLastUpdate
        case .subsidiary:
            parentUpToDate = self.lastSyncCompany == clientSyncIds.companyLastUpdate
            parentUpToDate = parentUpToDate ? self.lastSyncImage == clientSyncIds.imageLastUpdate : false
            guard parentUpToDate else {
                throw Abort(.badRequest, reason: "Parents are not up to date")
            }
            return self.lastSyncSubsidiary != clientSyncIds.subsidiaryLastUpdate
        case .customer:
            parentUpToDate = self.lastSyncCompany == clientSyncIds.companyLastUpdate
            parentUpToDate = parentUpToDate ? self.lastSyncImage == clientSyncIds.imageLastUpdate : false
            parentUpToDate = parentUpToDate ? self.lastSyncSubsidiary == clientSyncIds.subsidiaryLastUpdate : false
            guard parentUpToDate else {
                throw Abort(.badRequest, reason: "Parents are not up to date")
            }
            return self.lastSyncCustomer != clientSyncIds.customerLastUpdate
        case .employee:
            parentUpToDate = self.lastSyncCompany == clientSyncIds.companyLastUpdate
            parentUpToDate = parentUpToDate ? self.lastSyncImage == clientSyncIds.imageLastUpdate : false
            parentUpToDate = parentUpToDate ? self.lastSyncSubsidiary == clientSyncIds.subsidiaryLastUpdate : false
            guard parentUpToDate else {
                throw Abort(.badRequest, reason: "Parents are not up to date")
            }
            return self.lastSyncEmployee != clientSyncIds.employeeLastUpdate
        case .product:
            parentUpToDate = self.lastSyncCompany == clientSyncIds.companyLastUpdate
            parentUpToDate = parentUpToDate ? self.lastSyncImage == clientSyncIds.imageLastUpdate : false
            parentUpToDate = parentUpToDate ? self.lastSyncSubsidiary == clientSyncIds.subsidiaryLastUpdate : false
            guard parentUpToDate else {
                throw Abort(.badRequest, reason: "Parents are not up to date")
            }
            return self.lastSyncProduct != clientSyncIds.productLastUpdate
        case .sale:
            parentUpToDate = self.lastSyncCompany == clientSyncIds.companyLastUpdate
            parentUpToDate = parentUpToDate ? self.lastSyncImage == clientSyncIds.imageLastUpdate : false
            parentUpToDate = parentUpToDate ? self.lastSyncSubsidiary == clientSyncIds.subsidiaryLastUpdate : false
            parentUpToDate = parentUpToDate ? self.lastSyncEmployee == clientSyncIds.employeeLastUpdate : false
            parentUpToDate = parentUpToDate ? self.lastSyncCustomer == clientSyncIds.customerLastUpdate : false
            guard parentUpToDate else {
                throw Abort(.badRequest, reason: "Parents are not up to date")
            }
            return self.lastSyncSale != clientSyncIds.saleLastUpdate
        }
    }
}
