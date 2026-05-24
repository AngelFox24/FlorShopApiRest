import FluentPostgresDriver
import FlorShopNetworking
import Vapor

extension Application {
    func configNetworkLog() async {
        switch self.environment {
        case .development :
            await NetworkManager.shared.enableDebugLogging()
        default:
            return
        }
    }
}
