import Foundation
import FlorShopDTOs
import FlorShopNetworking

enum FlorShopAuthApiRequest {
    case getInternalToken(request: InternalTokenRequest)
    case updateCompany(request: CompanyServerDTO, internalToken: String)
    case saveSubsidiary(request: RegisterSubsidiaryRequest, internalToken: String)
    case updateUserSubsidiary(request: UpdateUserSubsidiaryRequest, internalToken: String)
    case getInitalData(subsidiaryCic: String, internalToken: String)
}

extension FlorShopAuthApiRequest: NetworkRequest {
    var url: URL? {
        let baseUrl = AppConfig.florShopAuthApiUrl
        let path: String
        switch self {
        case .getInternalToken:
            path = "/auth/service-token"
        case .updateCompany:
            path = "/company"
        case .saveSubsidiary:
            path = "/subsidiary"
        case .updateUserSubsidiary:
            path = "/usersubsidiary"
        case .getInitalData(let subsidiaryCic, _):
            path = "/initialData?subsidiaryCic=\(subsidiaryCic)"
        }
        return URL(string: baseUrl + path)
    }
    
    var method: HTTPMethod {
        switch self {
        case .getInternalToken, .updateCompany, .saveSubsidiary, .updateUserSubsidiary:
                .post
        case .getInitalData:
                .get
        }
    }
    
    var headers: [HTTPHeader : String]? {
        var headers: [HTTPHeader: String] = [:]
        switch self {
        case .getInternalToken:
            headers[.contentType] = ContentType.json.rawValue
        case .updateCompany(_, let internalToken):
            headers[.contentType] = ContentType.json.rawValue
            headers[.authorization] = "Bearer \(internalToken)"
        case .saveSubsidiary(_, let internalToken):
            headers[.contentType] = ContentType.json.rawValue
            headers[.authorization] = "Bearer \(internalToken)"
        case .updateUserSubsidiary(_, let internalToken):
            headers[.contentType] = ContentType.json.rawValue
            headers[.authorization] = "Bearer \(internalToken)"
        case .getInitalData(_, let internalToken):
            headers[.contentType] = ContentType.json.rawValue
            headers[.authorization] = "Bearer \(internalToken)"
        }
        return headers
    }
    
    var parameters: (any Encodable)? {
        switch self {
        case .getInternalToken(let request):
            return request
        case .updateCompany(let request, _):
            return request
        case .saveSubsidiary(let request, _):
            return request
        case .updateUserSubsidiary(let request, _):
            return request
        case .getInitalData:
            return nil
        }
    }
}
