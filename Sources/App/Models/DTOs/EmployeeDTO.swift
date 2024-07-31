import Foundation
import Vapor

struct EmployeeDTO: Content {
    let id: UUID
    let user: String
    let name: String
    let lastName: String
    let email: String
    let phoneNumber: String
    let role: String
    let active: Bool
    let subsidiaryID: UUID
    let imageUrl: ImageURLDTO?
    let createdAt: Date?
    let updatedAt: Date?
}
