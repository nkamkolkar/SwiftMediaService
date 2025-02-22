//
//  TokenPayload.swift
//  SwiftMediaService
//
//  Created by Neelesh Kamkolkar on 2/16/25.
//
//  We need to define the payload structure for our JWT tokens.

import Foundation
import Vapor
import JWT


struct TokenPayload: Content, Authenticatable, JWTPayload {
    var userID: UUID
    var username: String
    var exp: ExpirationClaim

    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}

