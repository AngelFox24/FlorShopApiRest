//
//  VerifySyncController.swift
//  FlorApiRestV1
//
//  Created by Angel Curi Laurente on 05/10/2024.
//
import Fluent
import Vapor

struct VerifySyncController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let saleDetails = routes.grouped("verifySync")
        saleDetails.get(use: verify)
    }
    func verify(req: Request) async throws -> VerifySyncParameters {
        return SyncTimestamp.shared.getLastSyncDate()
    }
}
