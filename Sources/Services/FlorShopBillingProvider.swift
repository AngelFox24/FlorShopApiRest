import FlorShopDTOs
import FlorShopNetworking
import Vapor

struct FlorShopBillingProvider {
    func getPlanByCic(planCic: String, app: Application) async throws -> PlanDTO {
        let internalToken = try await ServiceTokenManager.shared.getToken()
        let request = FlorShopBillingApiRequest.getPlanByCic(planCic: planCic, internalToken: internalToken)
        let response: PlanDTO = try await NetworkManager.shared.perform(request, decodeTo: PlanDTO.self)
        return response
    }
}
