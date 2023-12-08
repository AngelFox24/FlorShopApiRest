//
//  ImageUrl.swift
//
//
//  Created by Angel Curi Laurente on 7/12/23.
//

import Fluent
import Vapor

final class ImageUrl: Model, Content {
    static let schema = "imageUrls"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "imageUrl")
    var imageUrl: String
    
    // Relación uno a muchos: un autor puede tener varios libros
    
    @OptionalParent(key: "toImageUrl")
    var toProduct: Product?
    
    @OptionalParent(key: "toImageUrl")
    var toCustomer: Customer?
    
    @OptionalParent(key: "toImageUrl")
    var toEmployee: Employee?
    
    @OptionalParent(key: "toImageUrl")
    var toSaleDetail: SaleDetail?
    
    @OptionalParent(key: "toImageUrl")
    var toSubsidiary: Subsidiary?
    
    init() { }
    
    init(id: UUID? = nil, imageUrl: String) {
        self.id = id
        self.imageUrl = imageUrl
    }
}
