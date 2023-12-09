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
    
    //MARK: Relationship
    @Children(for: \.$imageUrl)
    var toSubsidiary: [Subsidiary]
    
    @Children(for: \.$imageUrl)
    var toSaleDetail: [SaleDetail]
    
    @Children(for: \.$imageUrl)
    var toCustomer: [Customer]
    
    @Children(for: \.$imageUrl)
    var toEmployee: [Employee]
    
    @Children(for: \.$imageUrl)
    var toProduct: [Product]
    
    init() { }
    
    init(id: UUID? = nil, imageUrl: String) {
        self.id = id
        self.imageUrl = imageUrl
    }
}
