import Foundation
import FlorShopDTOs
import FlorShopNetworking

enum FlorShopBillingApiRequest {
    case getPlanByCic(planCic: String, internalToken: String)
}

extension FlorShopBillingApiRequest: NetworkRequest {
    var url: URL? {
        let baseUrl = AppConfig.florShopBillingApiURL
        let path: String
        switch self {
        case .getPlanByCic(let planCic, _):
            path = "/plans/cic?planCic=\(planCic)"
        }
        return URL(string: baseUrl + path)
    }
    
    var method: HTTPMethod {
        switch self {
        case .getPlanByCic:
                .get
        }
    }
    
    var headers: [HTTPHeader : String]? {
        var headers: [HTTPHeader: String] = [:]
        switch self {
        case .getPlanByCic(_, let internalToken):
            headers[.contentType] = ContentType.json.rawValue
            headers[.authorization] = "Bearer \(internalToken)"
        }
        return headers
    }
    
    var parameters: (any Encodable)? {
        switch self {
        case .getPlanByCic:
            return nil
        }
    }
}
