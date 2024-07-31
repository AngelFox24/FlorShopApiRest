import Foundation
import Vapor

struct CartDTO: Content {
    let id: UUID
    let cartDetails: [CartDetailDTO]
    let total: Int
}
