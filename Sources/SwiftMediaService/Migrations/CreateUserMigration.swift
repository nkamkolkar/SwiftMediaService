//
//  CreateUserMigration.swift
//  SwiftMediaService
//
//  Created by Neelesh Kamkolkar on 2/16/25.
//



import Fluent


struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id() // Adds UUID primary key
            .field("username", .string, .required)
            .field("password_hash", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "username") // Ensure uniqueness of username
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}


