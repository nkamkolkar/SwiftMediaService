import Vapor
import JWT

/**
 Auth Flow:
    Login Endpoint (/login)
        Accepts username/password.
        Validates user credentials.
        Issues a JWT using TokenPayload.
    Protected Route Middleware
        A middleware to verify JWTs before granting access.
    Logout (Optional, but usually client-side handled)
        JWTs are stateless, so logout is usually handled by the client discarding the token.
 
 */

/// Handles authentication-related API endpoints.
struct AuthController {
    
    /// Handles user login and issues a JWT token.
    
    func login(req: Request) throws -> TokenResponse {
        let credentials = try req.content.decode(LoginRequest.self)
        
        // Find the user
        guard let user = testUsers.first(where: { $0.username == credentials.username && $0.password == credentials.password }) else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }

        // Generate JWT token
        let payload = TokenPayload(userID: user.id, exp: .init(value: Date().addingTimeInterval(3600))) // 1-hour expiry
        let token = try req.jwt.sign(payload)

        return TokenResponse(token: token)
    }

    
    
    
    /// Protected route example
    func protectedEndpoint(req: Request) async throws -> String {
        let payload = try req.jwt.verify(as: TokenPayload.self)
        return "Access granted for user ID: \(payload.userID)"
    }
    
    //Build routes for JWT login and securing protected resources
    func routes(_ app: RoutesBuilder) {
            app.post("login", use: login)
            app.get("protected", use: protectedEndpoint)
    }
    
}

/// Middleware for JWT verification
struct JWTMiddleware: AsyncMiddleware {
    func respond(to req: Request, chainingTo next: AsyncResponder) async throws -> Response {
        do {
            _ = try req.jwt.verify(as: TokenPayload.self)
            return try await next.respond(to: req)
        } catch {
            throw Abort(.unauthorized, reason: "Invalid or missing token")
        }
    }
}



/// Login request payload
struct LoginRequest: Content {
    let username: String
    let password: String
}

/// Token response structure
struct TokenResponse: Content {
    let token: String
}


//For TestinG
struct User {
    let id: UUID
    let username: String
    let password: String // For simplicity, storing plaintext. (We should hash this in production!)
}

// Temporary in-memory user store
let testUsers: [User] = [
    User(id: UUID(), username: "testuser", password: "password123")
]


