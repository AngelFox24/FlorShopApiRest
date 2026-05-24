import Vapor
import FluentKit
import FlorShopDTOs
import FlorShopValkey

struct AuthStreamHandler: StreamHandler {
    let streamName: ValkeyStream
    let groupName: String
    let consumerName: String
    let app: Application
    func handler(fields: [String: String]) async -> Bool {
        guard let eventType = ValkeyEventType.Auth(rawValue: fields["type"] ?? "") else {
            app.logger.info("[AuthStreamHandler] Auth recibió evento desconocido")
            return false
        }
        let payload = fields["payload"] ?? "{}"
        app.logger.info("Auth recibió evento: \(eventType) payload: \(payload)")
        do {
            let result = try await app.db.transaction { tx -> Bool in
                switch eventType {
//                case .changeSuscription:
//                    return try await self.changeSuscription(payload: payload, on: tx)
//                case .changePlan:
//                    return true
                case .newCompany:
                    return try await self.handleNewCompany(payload: payload, on: tx)
                }
            }
            return result
        } catch {
            app.logger.info("[AuthStreamHandler] Evento salio error")
            return false
        }
    }
    //MARK: Handle New Company
    private func handleNewCompany(payload: String, on tx: any Database) async throws -> Bool {
        guard let data = payload.data(using: .utf8) else {
            app.logger.error("[AuthStreamHandler] No se pudo convertir el payload a data")
            return false
        }
        let dto = try app.myJSONDecoder.decode(InitialDataDTO.self, from: data)
        if let company = try await Subsidiary.findSubsidiary(subsidiaryCic: dto.subsidiary.subsidiaryCic, on: tx) {
            if let _ = try await Subsidiary.findSubsidiary(subsidiaryCic: dto.subsidiary.subsidiaryCic, on: tx) {
                return true
            } else {//Creamos nueva subsidiaria
                let _ = try await self.createSubsidiary(companyId: company.requireID(), subsidiary: dto.subsidiary, on: tx)
            }
        } else {//Creamos nueva compañia y subsidiaria
            let companyId = try await self.createCompany(company: dto.company, on: tx)
            let _ = try await self.createSubsidiary(companyId: companyId, subsidiary: dto.subsidiary, on: tx)
        }
        return true
    }
    private func createCompany(company: CompanyClientDTO, on db: any Database) async throws -> UUID {
        let newCompany = Company(
            suscriptionID: nil,
            companyCic: company.companyCic,
            companyName: company.companyName,
            ruc: company.ruc
        )
        try await newCompany.save(on: db)
        return try newCompany.requireID()
    }
    private func createSubsidiary(companyId: UUID, subsidiary: SubsidiaryClientDTO, on db: any Database) async throws -> UUID {
        guard let company = try await Company.find(companyId, on: db) else {
            throw Abort(.internalServerError, reason: "[AuthStreamHandler] companyId no pudo ser obtenido")
        }
        let newSubsidiary = Subsidiary(
            subsidiaryCic: subsidiary.subsidiaryCic,
            name: subsidiary.name,
            imageUrl: subsidiary.imageUrl,
            companyCic: company.companyCic,
            companyID: try company.requireID()
        )
        try await newSubsidiary.save(on: db)
        return try newSubsidiary.requireID()
    }
}
