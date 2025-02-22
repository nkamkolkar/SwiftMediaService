//
//  JWTConfig.swift
//  SwiftMediaService
//
//  Created by Neelesh Kamkolkar on 2/16/25.
//


import Vapor
import JWT

struct JWTConfig {
    static let secretKey: String = Environment.get("JWT_SECRET") ?? "fallback-secure-key"

    static func setupSigners(app: Application) {
        app.jwt.signers.use(.hs256(key: secretKey))
    }
}
