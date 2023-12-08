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
    
    init() { }
    
    init(id: UUID? = nil, imageUrl: String) {
        self.id = id
        self.imageUrl = imageUrl
    }
}
