//
//  SaleDetail.swift
//
//
//  Created by Angel Curi Laurente on 7/12/23.
//

import Fluent
import Vapor

final class SaleDetail: Model, Content {
    static let schema = "saleDetails"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "productName")
    var productName: String
    @Field(key: "quantitySold")
    var quantitySold: Int
    @Field(key: "subtotal")
    var subtotal: Double
    @Field(key: "unitCost")
    var unitCost: Double
    @Field(key: "unitPrice")
    var unitPrice: Double
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    //MARK: Relationship
    @Parent(key: "sale_id")
    var sale: Sale
    
    //Imagen se debe pedir en el JSON
    @OptionalParent(key: "imageUrl_id")
    var imageUrl: ImageUrl?
    
    init() { }
    
    init(id: UUID? = nil, productName: String, quantitySold: Int, subtotal: Double, unitCost: Double, unitPrice: Double, saleID: Sale.IDValue, imageUrlID: ImageUrl.IDValue?) {
        self.id = id
        self.productName = productName
        self.quantitySold = quantitySold
        self.subtotal = subtotal
        self.unitCost = unitCost
        self.unitPrice = unitPrice
        self.$sale.id = saleID
        self.$imageUrl.id = imageUrlID
    }
}