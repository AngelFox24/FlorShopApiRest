import Fluent
import Vapor
import FlorShopAuthClient
import FlorShopNetworking

struct Test: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let test = routes.grouped("test")
        test.post(use: self.test)
    }
    @Sendable
    func test(req: Request) async throws -> Response {
        let payload = try await req.jwt.florshop.verifyScopedToken()
        print("✅ Token válido para \(payload.companyCic), userCic: \(payload.sub.value)")
        return Response(status: .ok, body: .init(stringLiteral: "✅ Token válido para \(payload.companyCic), userCic: \(payload.sub.value)"))
    }
}
