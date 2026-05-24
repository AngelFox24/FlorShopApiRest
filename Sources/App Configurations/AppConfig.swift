import Vapor

enum AppConfig {
    static let florShopAuthApiUrl = Environment.get(EnvironmentVariables.florShopAuthApiUrl.rawValue)!
    static let florShopBillingApiURL = Environment.get(EnvironmentVariables.florShopBillingApiURL.rawValue)!
    static let internalServiceName = Environment.get(EnvironmentVariables.internalServiceName.rawValue)!
    static let internalServicePassword = Environment.get(EnvironmentVariables.internalServicePassword.rawValue)!
}
