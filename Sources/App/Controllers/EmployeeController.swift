import Fluent
import Vapor

struct EmployeeController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let employees = routes.grouped("employees")
        employees.post("sync", use: sync)
        employees.post(use: save)
    }
    func sync(req: Request) async throws -> [EmployeeDTO] {
        //Precicion de segundos solamente
        //No se requiere mas precicion ya que el objetivo es sincronizar y en caso haya repetidos esto se mitiga en la app
        let request = try req.content.decode(SyncFromSubsidiaryParameters.self)
        
        let query = Employee.query(on: req.db)
            .filter(\.$updatedAt >= request.updatedSince)
            .sort(\.$updatedAt, .ascending)
            .with(\.$imageUrl)
            .limit(50)
        
        let employees = try await query.all()
        
        return employees.mapToListEmployeeDTO()
    }
    func save(req: Request) async throws -> DefaultResponse {
        let employeeDTO = try req.content.decode(EmployeeDTO.self)
        if let employee = try await Employee.find(employeeDTO.id, on: req.db) {
            //Update
            employee.user = employeeDTO.user
            employee.name = employeeDTO.name
            employee.lastName = employeeDTO.lastName
            employee.email = employeeDTO.email
            employee.phoneNumber = employeeDTO.phoneNumber
            employee.role = employeeDTO.role
            employee.active = employeeDTO.active
//                employee.$subsidiary.id = productDTO.subsidiaryId
            employee.$imageUrl.id = employeeDTO.imageUrlId //Solo se registra Id porque la imagen se guarda en ImageUrlController
            try await employee.update(on: req.db)
        } else {
            //Create
            let employeeNew = employeeDTO.toEmployee()
            try await employeeNew.save(on: req.db)
        }
        return DefaultResponse(code: 200, message: "Ok")
    }
}
