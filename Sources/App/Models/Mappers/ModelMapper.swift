//
//  File.swift
//  
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation
//MARK: Model to DTO
extension Product {
    func toProductDTO() -> ProductDTO {
        return ProductDTO(
            id: id!,
            productName: productName,
            barCode: barCode,
            active: active,
            expirationDate: expirationDate,
            quantityStock: quantityStock,
            unitType: unitType,
            unitCost: unitCost,
            unitPrice: unitPrice,
            subsidiaryId: self.$subsidiary.id,
            imageUrl: imageUrl?.toImageUrlDTO(),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension ImageUrl {
    func toImageUrlDTO() -> ImageURLDTO {
        return ImageURLDTO(
            id: id!,
            imageUrl: imageUrl,
            imageHash: imageHash
        )
    }
}
//MARK: DTO to Model
extension ProductDTO {
    func toProduct() -> Product {
        return Product(
            id: id,
            productName: productName,
            barCode: barCode,
            active: active,
            expirationDate: expirationDate,
            unitType: unitType,
            quantityStock: quantityStock,
            unitCost: unitCost,
            unitPrice: unitPrice,
            subsidiaryID: subsidiaryId,
            imageUrlID: imageUrl?.id
        )
    }
}

extension ImageURLDTO {
    func toImageUrl() -> ImageUrl {
        return ImageUrl(
            id: id,
            imageUrl: imageUrl,
            imageHash: imageHash
        )
    }
}
//MARK: Array of Model
extension Array where Element == Product {
    func mapToListProductDTO() -> [ProductDTO] {
        return self.compactMap({$0.toProductDTO()})
    }
}
