import Valkey
import Vapor
import VaporValkey

extension Application {
    func addValkey() {
        var configuration = ValkeyClientConfiguration()
        configuration.commandTimeout = .seconds(5)           // timeout para comandos normales
        configuration.blockingCommandTimeout = .seconds(5)   // timeout para comandos bloqueantes (XREAD, BLPOP, etc.)
        configuration.retryParameters = ValkeyClientConfiguration.RetryParameters(
            maxAttempts: 3                                   // máximo número de reintentos
        )
        configuration.connectionPool.circuitBreakerTripAfter = .seconds(5)
        guard let valkeyHost = Environment.get(EnvironmentVariables.valkeyHost.rawValue) else {
            fatalError("Missing \(EnvironmentVariables.valkeyHost.rawValue) in configuration")
        }
        guard let valkeyPort = Environment.get(EnvironmentVariables.valkeyPort.rawValue),
        let port = Int(valkeyPort) else {
            fatalError("Missing \(EnvironmentVariables.valkeyPort.rawValue) in configuration")
        }
        self.valkey = ValkeyClient(
            .hostname(valkeyHost, port: port),
            configuration: configuration,
            eventLoopGroup: self.eventLoopGroup,
            logger: self.logger
        )
    }
}
