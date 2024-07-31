import Foundation
import Vapor

struct ProductDTO: Content {
    let id: UUID
    let productName: String
    let barCode: String
    let active: Bool
    let expirationDate: Date?
    let quantityStock: Int
    let unitType: String
    let unitCost: Int
    let unitPrice: Int
    let subsidiaryId: UUID
    let imageUrl: ImageURLDTO?
    let createdAt: Date?
    let updatedAt: Date?
}
