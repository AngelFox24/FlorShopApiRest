import Fluent
import Vapor

struct CustomerContoller: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let customers = routes.grouped("customers")
        customers.post("sync", use: sync)
        customers.post(use: save)
    }
    func sync(req: Request) async throws -> [CustomerDTO] {
        //Precicion de segundos solamente
        //No se requiere mas precicion ya que el objetivo es sincronizar y en caso haya repetidos esto se mitiga en la app
        let request = try req.content.decode(SyncFromCompanyParameters.self)
        
        let query = Customer.query(on: req.db)
            .filter(\.$updatedAt >= request.updatedSince)
            .sort(\.$updatedAt, .ascending)
            .with(\.$imageUrl)
            .limit(50)
        
        let customers = try await query.all()
        
        return customers.mapToListCustomerDTO()
    }
    func save(req: Request) async throws -> DefaultResponse {
        let customerDTO = try req.content.decode(CustomerDTO.self)
        if let customer = try await Customer.find(customerDTO.id, on: req.db) {
            //Update
            customer.name = customerDTO.name
            customer.lastName = customerDTO.lastName
            customer.totalDebt = customerDTO.totalDebt
            customer.creditScore = customerDTO.creditScore
            customer.creditDays = customerDTO.creditDays
            customer.isCreditLimitActive = customerDTO.isCreditLimitActive
            customer.isCreditLimit = customerDTO.isCreditLimit
            customer.isDateLimitActive = customerDTO.isDateLimitActive
            customer.isDateLimit = customerDTO.isDateLimit
            customer.dateLimit = customerDTO.dateLimit
            customer.firstDatePurchaseWithCredit = customerDTO.firstDatePurchaseWithCredit
            customer.lastDatePurchase = customerDTO.lastDatePurchase
            customer.phoneNumber = customerDTO.phoneNumber
            customer.creditLimit = customerDTO.creditLimit
//                product.$subsidiary.id = productDTO.subsidiaryId
            customer.$company.id = customerDTO.companyID
            customer.$imageUrl.id = customerDTO.imageUrlId //Solo se registra Id porque la imagen se guarda en ImageUrlController
            try await customer.update(on: req.db)
        } else {
            //Create
            let customerNew = customerDTO.toCustomer()
            try await customerNew.save(on: req.db)
        }
        return DefaultResponse(code: 200, message: "Ok")
    }
}
