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
            imageHash: imageHash,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension Company {
    func toCompanyDTO() -> CompanyDTO {
        return CompanyDTO(
            id: id!,
            companyName: companyName,
            ruc: ruc,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension Customer {
    func toCustomerDTO() -> CustomerDTO {
        return CustomerDTO(
            id: id!,
            name: name,
            lastName: lastName,
            totalDebt: totalDebt,
            creditScore: creditScore,
            creditDays: creditDays,
            isCreditLimitActive: isCreditLimitActive,
            isCreditLimit: isCreditLimit,
            isDateLimitActive: isDateLimitActive,
            isDateLimit: isDateLimit,
            dateLimit: dateLimit,
            lastDatePurchase: lastDatePurchase,
            phoneNumber: phoneNumber,
            creditLimit: creditLimit,
            companyID: self.$company.id,
            imageUrl: imageUrl?.toImageUrlDTO(),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension Sale {
    func toSaleDTO() -> SaleDTO {
        return SaleDTO(
            id: id!,
            paymentType: paymentType,
            saleDate: saleDate,
            total: total,
            subsidiaryId: self.$subsidiary.id,
            customerId: self.$customer.id,
            employeeId: self.$employee.id,
            saleDetail: self.toSaleDetail.mapToListSaleDetailDTO(),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension SaleDetail {
    func toSaleDetailDTO() -> SaleDetailDTO {
        return SaleDetailDTO(
            id: id!,
            productName: productName,
            barCode: barCode,
            quantitySold: quantitySold,
            subtotal: subtotal,
            unitType: unitType,
            unitCost: unitCost,
            unitPrice: unitPrice,
            saleID: self.$sale.id,
            imageUrl: imageUrl?.toImageUrlDTO(),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension Subsidiary {
    func toSubsidiaryDTO() -> SubsidiaryDTO {
        return SubsidiaryDTO(
            id: id!,
            name: name,
            companyID: self.$company.id,
            imageUrl: imageUrl?.toImageUrlDTO(),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension Employee {
    func toEmployeeDTO() -> EmployeeDTO {
        return EmployeeDTO(
            id: id!,
            user: user,
            name: name,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            role: role,
            active: active,
            subsidiaryID: self.$subsidiary.id,
            imageUrl: imageUrl?.toImageUrlDTO(),
            createdAt: createdAt,
            updatedAt: updatedAt
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

extension SubsidiaryDTO {
    func toSubsidiary() -> Subsidiary {
        return Subsidiary(
            id: id,
            name: name,
            companyID: companyID,
            imageUrlID: imageUrl?.id
        )
    }
}

extension CompanyDTO {
    func toCompany() -> Company {
        return Company(
            id: id,
            companyName: companyName,
            ruc: ruc
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

extension EmployeeDTO {
    func toEmployee() -> Employee {
        return Employee(
            id: id,
            user: user,
            name: name,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            role: role,
            active: active,
            subsidiaryID: subsidiaryID,
            imageUrlID: imageUrl?.id
        )
    }
}

extension CustomerDTO {
    func toCustomer() -> Customer {
        return Customer(
            id: id,
            name: name,
            lastName: lastName,
            totalDebt: totalDebt,
            creditScore: creditScore,
            creditDays: creditDays,
            isCreditLimitActive: isCreditLimitActive,
            isCreditLimit: isCreditLimit,
            isDateLimitActive: isDateLimitActive,
            isDateLimit: isDateLimit,
            dateLimit: dateLimit,
            firstDatePurchaseWithCredit: firstDatePurchaseWithCredit,
            lastDatePurchase: lastDatePurchase,
            phoneNumber: phoneNumber,
            creditLimit: creditLimit,
            companyID: companyID,
            imageUrlID: imageUrl?.id
        )
    }
}

extension SaleDTO {
    func toSale() -> Sale {
        return Sale(
            id: id,
            paymentType: paymentType,
            saleDate: saleDate,
            total: total,
            subsidiaryID: subsidiaryId,
            customerID: customerId,
            employeeID: employeeId
        )
    }
}

extension SaleDetailDTO {
    func toSaleDetail() -> SaleDetail {
        return SaleDetail(
            id: id,
            productName: productName,
            barCode: barCode,
            quantitySold: quantitySold,
            subtotal: subtotal,
            unitType: unitType,
            unitCost: unitCost,
            unitPrice: unitPrice,
            saleID: saleID,
            imageUrlID: imageUrl?.id
        )
    }
}
//MARK: Array of Model
extension Array where Element == Product {
    func mapToListProductDTO() -> [ProductDTO] {
        return self.compactMap({$0.toProductDTO()})
    }
}
extension Array where Element == SaleDetail {
    func mapToListSaleDetailDTO() -> [SaleDetailDTO] {
        return self.compactMap({$0.toSaleDetailDTO()})
    }
}
extension Array where Element == Company {
    func mapToListCompanyDTO() -> [CompanyDTO] {
        return self.compactMap({$0.toCompanyDTO()})
    }
}
extension Array where Element == Customer {
    func mapToListCustomerDTO() -> [CustomerDTO] {
        return self.compactMap({$0.toCustomerDTO()})
    }
}
extension Array where Element == Employee {
    func mapToListEmployeeDTO() -> [EmployeeDTO] {
        return self.compactMap({$0.toEmployeeDTO()})
    }
}
extension Array where Element == ImageUrl {
    func mapToListImageURLDTO() -> [ImageURLDTO] {
        return self.compactMap({$0.toImageUrlDTO()})
    }
}
extension Array where Element == Subsidiary {
    func mapToListSubsidiaryDTO() -> [SubsidiaryDTO] {
        return self.compactMap({$0.toSubsidiaryDTO()})
    }
}
extension Array where Element == Sale {
    func mapToListSaleDTO() -> [SaleDTO] {
        return self.compactMap({$0.toSaleDTO()})
    }
}
//MARK: Array of DTOs
extension Array where Element == SaleDetailDTO {
    func mapToListSaleDetail() -> [SaleDetail] {
        return self.compactMap({$0.toSaleDetail()})
    }
}
