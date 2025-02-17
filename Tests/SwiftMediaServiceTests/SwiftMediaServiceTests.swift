
import XCTest
import Vapor
import XCTVapor

@testable import SwiftMediaService

/**
 final class SwiftMediaServiceTests: XCTestCase {
 var app: Application!
 
 override func setUp() async throws {
 app = try await Application.make(.testing)
 //try configure(app)
 }
 
 override func tearDown() async throws {
 try await app.asyncShutdown()
 }
 
 func testUserRegistration() async throws {
 try await app.test(.POST, "/register", beforeRequest: { req in
 try req.content.encode(["username": "testuser", "password": "password123"])
 }, afterResponse: { res in
 XCTAssertEqual(res.status, .ok)
 })
 }
 
 
 func testLoginUser() async throws {
 let loginPayload = ["username": "testuser", "password": "password123"]
 
 let requestBody = try JSONEncoder().encode(loginPayload)
 let requestBuffer = ByteBuffer(data: requestBody)
 
 let response = try await app.test(.POST, "/login") { req in
 req.headers.contentType = .json
 req.body = .init(buffer: requestBuffer)
 }
 
 XCTAssertEqual(response.status, .ok)
 
 let json = try response.content.decode([String: String].self)
 XCTAssertNotNil(json["token"], "Token should be returned")
 }
 
 
 
 
 func testListFiles() async throws {
 let loginPayload = ["username": "testuser", "password": "password123"]
 let loginRequest = try app.testable().performRequest(
 method: .POST,
 path: "/login",
 body: loginPayload
 )
 
 let json = try loginRequest.content.decode([String: String].self)
 guard let token = json["token"] else {
 XCTFail("Token should be available after login")
 return
 }
 
 let request = try app.testable().performRequest(
 method: .GET,
 path: "/files",
 headers: ["Authorization": "Bearer \(token)"]
 )
 
 XCTAssertEqual(request.status, .ok)
 }
 }
 */

