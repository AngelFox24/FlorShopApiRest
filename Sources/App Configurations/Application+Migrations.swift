import Vapor
import Fluent

extension Application {
    func configureMigrations() {
        self.migrations.add(CreateCompany())
        self.migrations.add(CreateSubsidiary())
        self.migrations.add(CreateCustomer())
        self.migrations.add(CreateProduct())
        self.migrations.add(CreateProductSubsidiary())
        self.migrations.add(CreateEmployee())
        self.migrations.add(CreateEmployeeSubsidiary())
        self.migrations.add(CreateSale())
        self.migrations.add(CreateSaleDetail())
        self.migrations.add(CreatePlan())
        self.migrations.add(CreatePlanFeature())
        self.migrations.add(CreateSuscription())
        // futuras migraciones aquí
        self.migrations.add(SetNotNullRoundingFields())
        self.migrations.add(UpdateCompanyParams())
    }
}
