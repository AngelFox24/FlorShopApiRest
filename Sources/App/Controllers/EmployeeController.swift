import Fluent
import Vapor

struct EmployeeController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let employees = routes.grouped("employees")
        employees.post("sync", use: sync)
        employees.post(use: save)
    }
    func sync(req: Request) async throws -> SyncEmployeesResponse {
        let request = try req.content.decode(SyncFromSubsidiaryParameters.self)
        guard try SyncTimestamp.shared.shouldSync(clientSyncIds: request.syncIds, entity: .employee) else {
            return SyncEmployeesResponse(
                employeesDTOs: [],
                syncIds: request.syncIds
            )
        }
        let maxPerPage = 50
        let query = Employee.query(on: req.db)
            .filter(\.$updatedAt >= request.updatedSince)
            .sort(\.$updatedAt, .ascending)
            .with(\.$imageUrl)
            .limit(maxPerPage)
        let employees = try await query.all()
        return SyncEmployeesResponse(
            employeesDTOs: employees.mapToListEmployeeDTO(),
            syncIds: employees.count == maxPerPage ? request.syncIds : SyncTimestamp.shared.getUpdatedSyncTokens(entity: .employee, clientTokens: request.syncIds)
        )
    }
    func save(req: Request) async throws -> DefaultResponse {
        let employeeDTO = try req.content.decode(EmployeeDTO.self)
        if let employee = try await Employee.find(employeeDTO.id, on: req.db) {
            //Update
            if employee.user != employeeDTO.user {
                guard try await !employeeUserNameExist(employeeDTO: employeeDTO, db: req.db) else {
                    throw Abort(.badRequest, reason: "El nombre de usuario ya existe")
                }
                employee.user = employeeDTO.user
            }
            if employee.name != employeeDTO.name || employee.lastName != employeeDTO.lastName {
                guard try await !employeeFullNameExist(employeeDTO: employeeDTO, db: req.db) else {
                    throw Abort(.badRequest, reason: "El nombre y apellido del empleado ya existe")
                }
                employee.name = employeeDTO.name
                employee.lastName = employeeDTO.lastName
            }
            employee.email = employeeDTO.email
            employee.phoneNumber = employeeDTO.phoneNumber
            employee.role = employeeDTO.role
            employee.active = employeeDTO.active
            employee.$imageUrl.id = try await ImageUrl.find(employeeDTO.imageUrlId, on: req.db)?.id
            try await employee.update(on: req.db)
            SyncTimestamp.shared.updateLastSyncDate(to: .employee)
            return DefaultResponse(
                code: 200,
                message: "Updated"
            )
        } else {
            //Create
            guard let subsidiaryId = try await Subsidiary.find(employeeDTO.subsidiaryID, on: req.db)?.id else {
                throw Abort(.badRequest, reason: "La subsidiaria no existe")
            }
            guard try await !employeeUserNameExist(employeeDTO: employeeDTO, db: req.db) else {
                throw Abort(.badRequest, reason: "El nombre de usuario ya existe")
            }
            guard try await !employeeFullNameExist(employeeDTO: employeeDTO, db: req.db) else {
                throw Abort(.badRequest, reason: "El nombre y apellido del empleado ya existe")
            }
            let employeeNew = Employee(
                id: UUID(),
                user: employeeDTO.user,
                name: employeeDTO.name,
                lastName: employeeDTO.lastName,
                email: employeeDTO.email,
                phoneNumber: employeeDTO.phoneNumber,
                role: employeeDTO.role,
                active: employeeDTO.active,
                subsidiaryID: subsidiaryId,
                imageUrlID: try await ImageUrl.find(employeeDTO.imageUrlId, on: req.db)?.id
            )
            try await employeeNew.save(on: req.db)
            SyncTimestamp.shared.updateLastSyncDate(to: .employee)
            return DefaultResponse(
                code: 200,
                message: "Created"
            )
        }
    }
    private func employeeUserNameExist(employeeDTO: EmployeeDTO, db: any Database) async throws -> Bool {
        let userName = employeeDTO.user
        let query = try await Employee.query(on: db)
            .filter(\.$user >= userName)
            .first()
        if query != nil {
            return true
        } else {
            return false
        }
    }
    private func employeeFullNameExist(employeeDTO: EmployeeDTO, db: any Database) async throws -> Bool {
        let name = employeeDTO.name
        let lastName = employeeDTO.lastName
        let query = try await Employee.query(on: db)
            .filter(\.$name == name)
            .filter(\.$lastName == lastName)
            .first()
        if query != nil {
            return true
        } else {
            return false
        }
    }
}
