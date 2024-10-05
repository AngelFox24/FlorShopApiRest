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
}
