import Vapor
import Fluent
import FlorShopDTOs
import FlorShopAuthClient
import FlorShopNetworking

struct CompanyController: RouteCollection {
    let florShopAuthProvider: FlorShopAuthProvider
    func boot(routes: any RoutesBuilder) throws {
        let companies = routes.grouped("companies")
        companies.get(use: self.test)
        companies.post(use: self.save)
    }
    @Sendable
    func test(req: Request) async throws -> Response {
        return Response(status: .ok, body: "Ok")
    }
    @Sendable
    func save(req: Request) async throws -> DefaultResponse {
        guard let scopedTokenStr = req.headers.first(name: HTTPHeader.scopedToken.rawValue) else {
            throw Abort(.unauthorized, reason: "Missing user token")
        }
        let payload = try await req.jwt.florshop.verifyScopedToken(scopedTokenStr)
        let companyDTO = try req.content.decode(CompanyServerDTO.self).clean()
        try companyDTO.validate()
        let responseText: String
        if let company = try await Company.findCompany(companyCic: payload.companyCic, on: req.db) {
            guard !companyDTO.isEqual(to: company) else {
                return DefaultResponse(message: "Not Updated, is equal")
            }
            //TODO: Segregate this in a function
            try await self.florShopAuthProvider.updateCompany(request: companyDTO)
            company.companyName = companyDTO.companyName
            company.ruc = companyDTO.ruc
            try await company.update(on: req.db)
            responseText = "Updated"
        } else {
            responseText = "Only one company per server"
        }
        return DefaultResponse(message: responseText)
    }
}

extension CompanyServerDTO {
    func validate() throws {
        guard self.companyName != "" else {
            throw Abort(.badRequest, reason: "El nombre de la compañia no puede estar vacio")
        }
        guard self.ruc != "" else {
            throw Abort(.badRequest, reason: "El RUC de la compañia no puede estar vacio")
        }
    }
}
