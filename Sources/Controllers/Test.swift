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
        guard let scopedToken = req.headers.first(name: HTTPHeader.scopedToken.rawValue) else {
            throw Abort(.unauthorized, reason: "Missing user token")
        }
        let payload = try await req.jwt.florshop.verifyScopedToken(scopedToken)
        print("✅ Token válido para \(payload.companyCic), userCic: \(payload.sub.value)")
        return Response(status: .ok, body: .init(stringLiteral: "✅ Token válido para \(payload.companyCic), userCic: \(payload.sub.value)"))
    }
}
