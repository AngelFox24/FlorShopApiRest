import Vapor
import Fluent
import FlorShopDTOs
import FlorShopAuthClient
import FlorShopNetworking

struct SessionController: RouteCollection {
    let authProvider: FlorShopAuthProvider
    func boot(routes: any RoutesBuilder) throws {
        let session = routes.grouped("session")
//        session.post("logIn", use: self.logIn)
        session.post("register", use: self.register)
    }
    //MARK: POST: /session/register
    @Sendable
    func register(req: Request) async throws -> DefaultResponse {
        let payload = try await req.jwt.florshop.verifyScopedToken()
        //Obtenemos los datos de FlorShopAuth
        let initialData = try await self.authProvider.getInitialData(subsidiaryCic: payload.subsidiaryCic)
        try await req.db.transaction { transaction in
            guard try await !Subsidiary.subsidiaryExist(subsidiaryCic: initialData.subsidiary.subsidiaryCic, on: transaction) else {
                return
            }
            guard try await !Company.companyExist(companyCic: initialData.company.companyCic, on: transaction) else {
                return
            }
            print("[register] - Se han verificado que no existe la empresa y la subsidiaria")
            let companyCic = payload.companyCic
            let subsidiaryCic = payload.subsidiaryCic
            //Registramos la compañia
            let newCompany = Company(
                suscriptionID: nil,
                companyCic: companyCic,
                companyName: initialData.company.companyName,
                ruc: initialData.company.ruc
            )
            try await newCompany.save(on: transaction)
            guard let companyId = newCompany.id else {
                throw Abort(.internalServerError, reason: "companyId no pudo ser obtenido")
            }
            //Registramos la subsidiaria
            let newSubsidiary = Subsidiary(
                subsidiaryCic: subsidiaryCic,
                name: initialData.subsidiary.name,
                imageUrl: initialData.subsidiary.imageUrl,
                companyCic: companyCic,
                companyID: companyId
            )
            try await newSubsidiary.save(on: transaction)
        }
        return DefaultResponse(code: 200, message: "ok")
    }
}
