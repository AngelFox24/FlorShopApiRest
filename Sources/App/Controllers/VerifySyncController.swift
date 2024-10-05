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
        let subsidiaries = routes.grouped("verifySync")
        subsidiaries.post(use: getTokens)
    }
    func getTokens(req: Request) async throws -> VerifySyncParameters {
        return SyncTimestamp.shared.getLastSyncDate()
    }
}
