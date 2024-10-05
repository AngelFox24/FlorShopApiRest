import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "FlorShopApi v1.4"
    }
    try app.register(collection: SessionController())
    try app.register(collection: CompanyController())
    try app.register(collection: ImageUrlController())
    try app.register(collection: SubsidiaryController())
    try app.register(collection: ProductController())
    try app.register(collection: CustomerContoller())
    try app.register(collection: EmployeeController())
    try app.register(collection: SaleController())
}
