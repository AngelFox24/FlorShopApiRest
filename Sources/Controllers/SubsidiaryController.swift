import Vapor
import Fluent
import FlorShopDTOs
import FlorShopAuthClient
import FlorShopNetworking

struct SubsidiaryController: RouteCollection {
    let florShopAuthProvider: FlorShopAuthProvider
    func boot(routes: any RoutesBuilder) throws {
        let subsidiaries = routes.grouped("subsidiaries")
        subsidiaries.post(use: self.save)
    }
    @Sendable
    func save(req: Request) async throws -> DefaultResponse {
        guard let scopedTokenStr = req.headers.first(name: HTTPHeader.scopedToken.rawValue) else {
            throw Abort(.unauthorized, reason: "Missing user token")
        }
        let payload = try await req.jwt.florshop.verifyScopedToken(scopedTokenStr)
        let subsidiaryDTO = try req.content.decode(SubsidiaryServerDTO.self).clean()
        try self.validateInput(dto: subsidiaryDTO)
        let responseString: String = try await req.db.transaction { transaction -> String in
            let role: UserSubsidiaryRole
            if let subsidiaryCic = subsidiaryDTO.subsidiaryCic {
                guard let subsidiary = try await Subsidiary.findSubsidiary(subsidiaryCic: subsidiaryCic, on: transaction) else {
                    throw Abort(.badRequest, reason: "Subsidiaria no encontrada para ser actualizada")
                }
                guard !subsidiaryDTO.isEqual(to: subsidiary) else {
                    throw Abort(.badRequest, reason: "Not Updated, is equal")
                }
                //Update
                guard try await !Subsidiary.nameExist(name: subsidiaryDTO.name, on: transaction) else {
                    throw Abort(.badRequest, reason: "La subsidiaria con este nombre ya existe")
                }
                //TODO: Segregate this in a fucntion
                if let employeeSubsidiary = try await EmployeeSubsidiary.findEmployeeSubsidiary(employeeCic: payload.sub.value, subsisiaryCic: subsidiaryCic, on: transaction) {
                    //Primero intentamos asignar el mismo rol de la subsidiaria de destino
                    role = employeeSubsidiary.role
                } else if let employeeSubsidiary = try await EmployeeSubsidiary.findEmployeeSubsidiary(employeeCic: payload.sub.value, subsisiaryCic: payload.subsidiaryCic, on: transaction) {
                    //Si no intentamos de la misma subsidiaria donde obtuvo el ScopedToken
                    role = employeeSubsidiary.role
                } else {
                    throw Abort(.failedDependency, reason: "Empleado no encontrado para esta subsidiaria incluso teniendo el ScopedToken")
                }
                //TODO: First send a request a FlorShopAuth to update the name of company
                let request = RegisterSubsidiaryRequest(subsidiary: subsidiaryDTO, role: role)
                try await self.florShopAuthProvider.saveSubsidiary(request: request)
                subsidiary.name = subsidiaryDTO.name
                subsidiary.imageUrl = subsidiaryDTO.imageUrl
                try await subsidiary.update(on: transaction)
                return ("Updated")
            } else {//CREATE
                guard try await !Subsidiary.nameExist(name: subsidiaryDTO.name, on: transaction) else {
                    throw Abort(.badRequest, reason: "La subsidiaria con este nombre ya existe")
                }
                guard let companyEntity = try await Company.findCompany(companyCic: payload.companyCic, on: transaction),
                      let companyEntityId = companyEntity.id else {
                    throw Abort(.badRequest, reason: "La compañia no existe existe")
                }
                //TODO: Segregate this in a fucntion
                if let employeeSubsidiary = try await EmployeeSubsidiary.findEmployeeSubsidiary(employeeCic: payload.sub.value, subsisiaryCic: payload.subsidiaryCic, on: transaction) {
                    //Intentamos asignar el rol de la misma subsidiaria donde obtuvo el ScopedToken
                    role = employeeSubsidiary.role
                } else {
                    throw Abort(.failedDependency, reason: "Empleado no encontrado para esta subsidiaria incluso teniendo el ScopedToken")
                }
                //TODO: First send a request a FlorShopAuth to update the name of company
                let request = RegisterSubsidiaryRequest(subsidiary: subsidiaryDTO, role: role)
                try await self.florShopAuthProvider.saveSubsidiary(request: request)
                let subsidiaryNew = Subsidiary(
                    subsidiaryCic: UUID().uuidString,
                    name: subsidiaryDTO.name,
                    imageUrl: subsidiaryDTO.imageUrl,
                    companyCic: companyEntity.companyCic,
                    companyID: companyEntityId
                )
                try await subsidiaryNew.save(on: transaction)
                return ("Created")
            }
        }
        return DefaultResponse(message: responseString)
    }
    private func validateInput(dto: SubsidiaryServerDTO) throws {
        guard dto.name != "" else {
            throw Abort(.badRequest, reason: "El nombre de la subsidiaria no puede estar vacio")
        }
    }
    private func getSubsidiary(dto: SubsidiaryServerDTO, db: any Database) async throws -> Subsidiary? {
        return try await Subsidiary.query(on: db)
            .filter(\.$name == dto.name)
            .limit(1)
            .first()
    }
}
