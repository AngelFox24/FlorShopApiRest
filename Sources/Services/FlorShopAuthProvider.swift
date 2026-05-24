import Vapor
import FlorShopDTOs
import FlorShopNetworking

struct FlorShopAuthProvider {
    func updateCompany(request: CompanyServerDTO) async throws {
        let internalToken = try await ServiceTokenManager.shared.getToken()
        let request = FlorShopAuthApiRequest.updateCompany(request: request, internalToken: internalToken)
        let response: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
        guard response.isValid() else {
            throw Abort(.badRequest, reason: "Error al actualizar la compañia en FlorShopAuth")
        }
    }
    func saveSubsidiary(request: RegisterSubsidiaryRequest) async throws {
        let internalToken = try await ServiceTokenManager.shared.getToken()
        let request = FlorShopAuthApiRequest.saveSubsidiary(request: request, internalToken: internalToken)
        let response: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
        guard response.isValid() else {
            throw Abort(.badRequest, reason: "Error al actualizar la subsidiaria en FlorShopAuth")
        }
    }
    func updateUserSubsidiary(request: UpdateUserSubsidiaryRequest) async throws {
        let internalToken = try await ServiceTokenManager.shared.getToken()
        let request = FlorShopAuthApiRequest.updateUserSubsidiary(request: request, internalToken: internalToken)
        let response: DefaultResponse = try await NetworkManager.shared.perform(request, decodeTo: DefaultResponse.self)
        guard response.isValid() else {
            throw Abort(.badRequest, reason: "Error al actualizar UserSubsidiary en FlorShopAuth")
        }
    }
    func getInitialData(subsidiaryCic: String) async throws -> InitialDataDTO {
        let internalToken = try await ServiceTokenManager.shared.getToken()
        let request = FlorShopAuthApiRequest.getInitalData(subsidiaryCic: subsidiaryCic, internalToken: internalToken)
        let response: InitialDataDTO = try await NetworkManager.shared.perform(request, decodeTo: InitialDataDTO.self)
        return response
    }
}
