//
//  ImageUrl.swift
//
//
//  Created by Angel Curi Laurente on 7/12/23.
//

import Fluent
import Vapor

final class ImageUrl: Model, Content {
    static let schema = "imageUrl"
    
    @ID(key: .id)
    var id: UUID
    
    @Field(key: "imageUrl")
    var imageUrl: String
    
    // Relación uno a muchos: un autor puede tener varios libros
    @Parent(key: "product_id")
    var toImageUrl: ImageUrl
    
    //init() { }

    init(id: UUID, productName: String, active: Bool, expirationDate: Date? = nil, quantityStock: Int, unitCost: Double, unitPrice: Double, toCartDetail: CartDetail.IDValue, toSubsidiary: Subsidiary.IDValue) {
        self.id = id
        self.productName = productName
        self.active = active
        self.expirationDate = expirationDate
        self.quantityStock = quantityStock
        self.unitCost = unitCost
        self.unitPrice = unitPrice
        self.$toCartDetail.id = toCartDetail
        self.$toSubsidiary.id = toSubsidiary
    }
}
