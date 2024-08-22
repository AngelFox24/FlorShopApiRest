import Foundation
import Vapor

struct CartDetailDTO: Content {
//    let id: UUID
    let quantity: Int
    let subtotal: Int
    let productId: UUID
//    let product: ProductDTO
}
