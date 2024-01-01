import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "FlorCloudBDv1",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    app.migrations.add(CreateCompany())
    app.migrations.add(CreateImageUrl())
    app.migrations.add(CreateSubsidiary())
    app.migrations.add(CreateCustomer())
    app.migrations.add(CreateProduct())
    app.migrations.add(CreateEmployee())
    print("Migrate")
    app.migrations.add(CreateSale())
    app.migrations.add(CreateSaleDetail())
    //No espera a que la migracion se haga
    //try await app.autoMigrate().get()
    //Espera a que la migracion se haga
    try app.autoMigrate().wait()
    // register routes
    try routes(app)
}
