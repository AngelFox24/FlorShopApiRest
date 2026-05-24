import Vapor
import Fluent
import FlorShopDTOs
import FlorShopAuthClient
import FlorShopNetworking

struct CustomerContoller: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let customers = routes.grouped("customers")
        customers.post(use: self.save)
        customers.post("payDebt", use: self.payDebt)
    }
    @Sendable
    func save(req: Request) async throws -> DefaultResponse {
        guard let scopedTokenStr = req.headers.first(name: HTTPHeader.scopedToken.rawValue) else {
            throw Abort(.unauthorized, reason: "Missing user token")
        }
        let payload = try await req.jwt.florshop.verifyScopedToken(scopedTokenStr)
        let customerDTO = try req.content.decode(CustomerServerDTO.self)
        let responseString: String = try await req.db.transaction { transaction -> String in
            if let customerCic = customerDTO.customerCic {//tiene la intencion de actualizar
                guard let customer = try await Customer.findCustomer(customerCic: customerCic, on: transaction) else {
                    throw Abort(.badRequest, reason: "El cliente no existe para ser actualizado")
                }
                if customer.name != customerDTO.name || customer.lastName != customerDTO.lastName {
                    guard try await !customerFullNameExist(customerDTO: customerDTO, db: transaction) else {
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
                customer.imageUrl = customerDTO.imageUrl
                //TODO: Use calculated variables
                if customerDTO.isDateLimitActive && customer.totalDebt > 0,
                   let firstDatePurchaseWithCredit = customer.firstDatePurchaseWithCredit {
                    var calendar = Calendar.current
                    calendar.timeZone = TimeZone(identifier: "UTC")!
                    customer.dateLimit = calendar.date(byAdding: .day, value: customer.creditDays, to: firstDatePurchaseWithCredit)!
                    let finalDelDia = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
                    customer.isDateLimit = customer.dateLimit < finalDelDia
                }
                customer.isCreditLimit = customer.isCreditLimitActive ? customer.totalDebt >= customer.creditLimit : false
                try await customer.update(on: transaction)
                return ("Updated")
            } else {
                //Create
                guard let companyEntity = try await Company.findCompany(companyCic: payload.companyCic, on: transaction),
                      let companyEntityId = companyEntity.id else {
                    throw Abort(.badRequest, reason: "La compañia no existe")
                }
                guard try await !customerFullNameExist(customerDTO: customerDTO, db: transaction) else {
                    throw Abort(.badRequest, reason: "El nombre y apellido del cliente ya existe")
                }
                let customerNew = Customer(
                    customerCic: UUID().uuidString,
                    name: customerDTO.name,
                    lastName: customerDTO.lastName,
                    totalDebt: 0,
                    creditScore: 0,
                    creditDays: customerDTO.creditDays,
                    isCreditLimitActive: customerDTO.isCreditLimitActive,
                    isCreditLimit: false,//TODO: Delete this atribute
                    isDateLimitActive: customerDTO.isDateLimitActive,
                    isDateLimit: false,
                    dateLimit: customerDTO.dateLimit,
                    firstDatePurchaseWithCredit: nil,
                    lastDatePurchase: customerDTO.lastDatePurchase,
                    phoneNumber: customerDTO.phoneNumber,
                    creditLimit: customerDTO.creditLimit,
                    imageUrl: customerDTO.imageUrl,
                    companyCic: companyEntity.companyCic,
                    companyID: companyEntityId
                )
                try await customerNew.save(on: transaction)
                return ("Created")
            }
        }
        return DefaultResponse(message: responseString)
    }
    @Sendable
    func payDebt(req: Request) async throws -> PayCustomerDebtClientDTO {
        guard let scopedTokenStr = req.headers.first(name: HTTPHeader.scopedToken.rawValue) else {
            throw Abort(.unauthorized, reason: "Missing user token")
        }
        let _ = try await req.jwt.florshop.verifyScopedToken(scopedTokenStr)
        let payCustomerDebtParameters = try req.content.decode(PayCustomerDebtServerDTO.self)
        guard let customer = try await Customer.findCustomer(customerCic: payCustomerDebtParameters.customerCic, on: req.db) else {
            throw Abort(.badRequest, reason: "El cliente no existe")
        }
        guard payCustomerDebtParameters.amount > 0 else {
            throw Abort(.badRequest, reason: "El monto debe ser mayor a 0")
        }
        let remainingMoney = try await req.db.transaction { transaction -> Int in
            var customerTotalDebt = customer.totalDebt
            var remainingMoney = payCustomerDebtParameters.amount
            let sales = try await getSalesWithDebt(customerCic: payCustomerDebtParameters.customerCic, db: transaction)
            for sale in sales {
                let subtotal = sale.toSaleDetail.reduce(0) {$0 + ($1.unitPrice * $1.quantitySold)}
                if remainingMoney >= subtotal && customerTotalDebt >= subtotal  { //Si alcanza para pagar esta deuda y deuda del cliente debe ser mayor a subtotal
                    remainingMoney -= subtotal
                    sale.paymentType = PaymentType.cash
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
        return PayCustomerDebtClientDTO(
            customerCic: payCustomerDebtParameters.customerCic,
            change: remainingMoney
        )
    }
    //TODO: Optimize this with pagination
    private func getSalesWithDebt(customerCic: String, db: any Database) async throws -> [Sale] {
        return try await Sale.query(on: db)
            .join(Customer.self, on: \Customer.$id == \Sale.$id)
            .filter(Customer.self ,\.$customerCic == customerCic)
            .filter(Sale.self, \.$paymentType == PaymentType.loan)
            .with(\.$toSaleDetail)
            .sort(\.$createdAt, .ascending)
            .all()
    }
    private func customerFullNameExist(customerDTO: CustomerServerDTO, db: any Database) async throws -> Bool {
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
