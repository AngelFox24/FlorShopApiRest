import FluentPostgresDriver
import Vapor

extension Application {
    func getFactory() throws -> DatabaseConfigurationFactory {
        guard let portInt = Int(Environment.get(EnvironmentVariables.dataBasePort.rawValue)!),
              portInt > 0 else {
            fatalError("\(EnvironmentVariables.dataBasePort.rawValue) must be an integer in .env.\(self.environment)")
        }
        return .postgres(configuration: SQLPostgresConfiguration(
            hostname: Environment.get(EnvironmentVariables.dataBaseHost.rawValue)!,
            port: portInt,
            username: Environment.get(EnvironmentVariables.dataBaseUserName.rawValue)!,
            password: Environment.get(EnvironmentVariables.dataBasePassword.rawValue)!,
            database: Environment.get(EnvironmentVariables.dataBaseName.rawValue)!,
            tls: .disable))
    }
    func getDatabaseID() -> DatabaseID {
        switch self.environment {
        default:
            return .psql
        }
    }
}

