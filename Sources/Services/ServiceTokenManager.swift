import Foundation
import FlorShopDTOs
import FlorShopNetworking
//TODO: Poner en FlorShop Auth Client se repite en todos los servicios
actor ServiceTokenManager {
    static let shared = ServiceTokenManager()
    private var internalToken: InternalToken?
    func getToken() async throws -> String {
        if let token = internalToken, !token.isExpired {
            return token.token
        }
        let newToken = try await fetchFromAuth()
        self.internalToken = newToken
        return newToken.token
    }
    private func fetchFromAuth() async throws -> InternalToken {
        let request = FlorShopAuthApiRequest.getInternalToken(
            request: InternalTokenRequest(
                service: AppConfig.internalServiceName,
                password: AppConfig.internalServicePassword
            )
        )
        let response: InternalTokenResponse = try await NetworkManager.shared.perform(request, decodeTo: InternalTokenResponse.self)
        return InternalToken(token: response.serviceToken, expiry: response.expiry)
    }
}
