import Fluent
import Vapor
struct CustomerContoller: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let customers = routes.grouped("customers")
        customers.post("sync", use: sync)
        customers.post(use: save)
        customers.post("payDebt", use: payDebt)
    }
    func sync(req: Request) async throws -> SyncCustomersResponse {
        let request = try req.content.decode(SyncFromCompanyParameters.self)
        let customerClientLastSyncId = request.syncIds.customerLastUpdate
        let customerBackendLastSyncId = SyncTimestamp.shared.getLastSyncDate().customerLastUpdate
        guard customerClientLastSyncId != customerBackendLastSyncId else {
            return SyncCustomersResponse(
                customersDTOs: [],
                syncIds: SyncTimestamp.shared.getLastSyncDate()
            )
        }
        let maxPerPage = 50
        let query = Customer.query(on: req.db)
            .filter(\.$updatedAt >= request.updatedSince)
            .sort(\.$updatedAt, .ascending)
            .with(\.$imageUrl)
            .limit(maxPerPage)
        let customers = try await query.all()
        return SyncCustomersResponse(
            customersDTOs: customers.mapToListCustomerDTO(),
            syncIds: customers.count == maxPerPage ? SyncTimestamp.shared.getLastSyncDateTemp(entity: .customer) : SyncTimestamp.shared.getLastSyncDate()
        )
    }
    func save(req: Request) async throws -> DefaultResponse {
        let customerDTO = try req.content.decode(CustomerDTO.self)
        if let customer = try await Customer.find(customerDTO.id, on: req.db) {
            //Update
            if customer.name != customerDTO.name || customer.lastName != customerDTO.lastName {
                guard try await !customerFullNameExist(customerDTO: customerDTO, db: req.db) else {
                    throw Abort(.badRequest, reason: "El nombre y apellido del cliente ya existe")
                }
                customer.name = customerDTO.name
                customer.lastName = customerDTO.lastName
            }
            customer.creditDays = customerDTO.creditDays
            customer.creditLimit = customerDTO.creditLimit
            customer.isCreditLimitActive = customerDTO.isCreditLimitActive
            customer.isDateLimitActive = customerDTO.isDateLimitActive
            customer.phoneNumber = customerDTO.phoneNumber
            customer.$imageUrl.id = try await ImageUrl.find(customerDTO.imageUrlId, on: req.db)?.id //Solo se registra Id porque la imagen se guarda en ImageUrlController
            if customerDTO.isDateLimitActive && customer.totalDebt > 0, let firstDatePurchaseWithCredit = customer.firstDatePurchaseWithCredit {
                var calendar = Calendar.current
                calendar.timeZone = TimeZone(identifier: "UTC")!
                customer.dateLimit = calendar.date(byAdding: .day, value: customer.creditDays, to: firstDatePurchaseWithCredit)!
                let finalDelDia = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
                customer.isDateLimit = customer.dateLimit < finalDelDia
            }
            customer.isCreditLimit = customer.isCreditLimitActive ? customer.totalDebt >= customer.creditLimit : false
            try await customer.update(on: req.db)
            SyncTimestamp.shared.updateLastSyncDate(to: .customer)
            return DefaultResponse(
                code: 200,
                message: "Updated",
                syncIds: SyncTimestamp.shared.getLastSyncDate()
            )
        } else {
            //Create
            guard let companyID = try await Company.find(customerDTO.companyID, on: req.db)?.id else {
                throw Abort(.badRequest, reason: "La compañia no existe")
            }
            guard try await !customerFullNameExist(customerDTO: customerDTO, db: req.db) else {
                throw Abort(.badRequest, reason: "El nombre y apellido del cliente ya existe")
            }
            let customerNew = Customer(
                id: customerDTO.id,
                name: customerDTO.name,
                lastName: customerDTO.lastName,
                totalDebt: 0,
                creditScore: 0,
                creditDays: customerDTO.creditDays,
                isCreditLimitActive: customerDTO.isCreditLimitActive,
                isCreditLimit: false,
                isDateLimitActive: customerDTO.isDateLimitActive,
                isDateLimit: false,
                dateLimit: customerDTO.dateLimit,
                firstDatePurchaseWithCredit: nil,
                lastDatePurchase: customerDTO.lastDatePurchase,
                phoneNumber: customerDTO.phoneNumber,
                creditLimit: customerDTO.creditLimit,
                companyID: companyID,
                imageUrlID: try await ImageUrl.find(customerDTO.imageUrlId, on: req.db)?.id
            )
            try await customerNew.save(on: req.db)
            SyncTimestamp.shared.updateLastSyncDate(to: .customer)
            return DefaultResponse(
                code: 200,
                message: "Created",
                syncIds: SyncTimestamp.shared.getLastSyncDate()
            )
        }
    }
    func payDebt(req: Request) async throws -> PayCustomerDebtResponse {
        let payCustomerDebtParameters = try req.content.decode(PayCustomerDebtParameters.self)
        guard payCustomerDebtParameters.amount > 0 else {
            throw Abort(.badRequest, reason: "El monto debe ser mayor a 0")
        }
        if let customer = try await Customer.find(payCustomerDebtParameters.customerId, on: req.db) {
            let remainingMoney = try await req.db.transaction { transaction -> Int in
                var customerTotalDebt = customer.totalDebt
                var remainingMoney = payCustomerDebtParameters.amount
                let sales = try await getSalesWithDebt(customerId: payCustomerDebtParameters.customerId, db: transaction)
                for sale in sales {
                    let subtotal = sale.toSaleDetail.reduce(0) {$0 + ($1.unitPrice * $1.quantitySold)}
                    if remainingMoney >= subtotal && customerTotalDebt >= subtotal  { //Si alcanza para pagar esta deuda y deuda del cliente debe ser mayor a subtotal
                        remainingMoney -= subtotal
                        sale.paymentType = PaymentType.cash.description
                        customerTotalDebt -= subtotal
                        try await sale.update(on: transaction)
                    }
                }
                customer.totalDebt = customerTotalDebt
                customer.isCreditLimit = customer.isCreditLimitActive ? customer.totalDebt > customer.creditLimit : false
                customer.isDateLimit = customer.isDateLimitActive ? Date() > customer.dateLimit : false
                try await customer.update(on: transaction)
                return remainingMoney
            }
            SyncTimestamp.shared.updateLastSyncDate(to: .sale)
            SyncTimestamp.shared.updateLastSyncDate(to: .customer)
            return PayCustomerDebtResponse(
                customerId: payCustomerDebtParameters.customerId,
                change: remainingMoney,
                syncIds: SyncTimestamp.shared.getLastSyncDate()
            )
        } else {
            print("El cliente no existe")
            throw Abort(.badRequest, reason: "El cliente no existe")
        }
    }
    private func getSalesWithDebt(customerId: UUID, db: any Database) async throws -> [Sale] {
        return try await Sale.query(on: db)
            .filter(\.$customer.$id == customerId)
            .filter(\.$paymentType == PaymentType.loan.description)
            .with(\.$toSaleDetail)
            .sort(\.$createdAt, .ascending)
            .all()
    }
    private func customerFullNameExist(customerDTO: CustomerDTO, db: any Database) async throws -> Bool {
        let name = customerDTO.name
        let lastName = customerDTO.lastName
        let query = try await Customer.query(on: db)
            .filter(\.$name == name)
            .filter(\.$lastName == lastName)
            .first()
        if query != nil {
            return true
        } else {
            return false
        }
    }
}
