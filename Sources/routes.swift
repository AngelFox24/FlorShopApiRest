import Fluent
import Vapor

func routes(_ app: Application) async throws {
    let florShopAuthProvider = FlorShopAuthProvider()
    try app.register(collection: Test())
    try app.register(collection: SessionController(authProvider: florShopAuthProvider))
    try app.register(collection: CompanyController(florShopAuthProvider: florShopAuthProvider))
    try app.register(collection: SubsidiaryController(florShopAuthProvider: florShopAuthProvider))
    try app.register(collection: ProductController())
    try app.register(collection: CustomerContoller())
    try app.register(collection: EmployeeController(florShopAuthProvider: florShopAuthProvider))
    try app.register(collection: SaleController())
}
