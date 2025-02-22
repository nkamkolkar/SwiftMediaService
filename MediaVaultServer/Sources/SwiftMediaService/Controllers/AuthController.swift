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
    
    func login(req: Request) async throws -> TokenResponse {
    
        
        let credentials = try req.content.decode(LoginRequest.self)

        // Fetch user from database
        guard let user = try await User.query(on: req.db)
                .filter(\User.$username, .equal, credentials.username)
                .first()
        else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }

        // Verify password
        guard try Bcrypt.verify(credentials.password, created: user.passwordHash) else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }

        let inputPassword = credentials.password
        let storedPassword = user.passwordHash

        AppLogger.shared.logInfo("Logging in user: \(user.username) with stored hashed password: \(storedPassword)")
        //print("**********Input Password: \(inputPassword)")
        //print("**********Stored Hash: \(storedPassword)")
        //print("**********Verification Result: \(try? Bcrypt.verify(inputPassword, created: storedPassword))")
        
        // Generate JWT token (assuming you have a function for this)
        //let token = try generateJWT(for: user, req: req)

        let payload = TokenPayload(
            userID: user.id!,
            username: user.username,
            exp: .init(value: Date().addingTimeInterval(3600)) // 1-hour expiration
        )
        let token = try req.jwt.sign(payload)
        //return ["token": token]

        
        return TokenResponse(token: token)
    }

    
    
    
    /// Protected route example
    func protectedEndpoint(req: Request) async throws -> String {
        
        let payload = try req.jwt.verify(as: TokenPayload.self)
        guard let user = try await User.find(payload.userID, on: req.db) else {
            throw Abort(.unauthorized, reason: "User not found")
        }
        return user.username

    }
    
    //Build routes for JWT login and securing protected resources
    func routes(_ app: RoutesBuilder) {
            // Auth routes
            app.post("login", use: login)
            app.get("protected", use: protectedEndpoint)
            app.post("register", use: register)

    }
    

    func register(req: Request) async throws -> HTTPStatus {
        let registerData = try req.content.decode(RegisterRequest.self)

        // Check if username already exists
        let existingUser = try await User.query(on: req.db)
            .filter(\User.$username, .equal, registerData.username) // Correct Fluent syntax
            .first()
        
        guard existingUser == nil else {
            req.logger.warning("Registration failed: Username '\(registerData.username)' already exists.")
            throw Abort(.badRequest, reason: "Username already exists")
        }

        // Hash the password securely
        let passwordHash = try Bcrypt.hash(registerData.password)

        // Create and save the new user
        let user = User(username: registerData.username, passwordHash: passwordHash)
        try await user.save(on: req.db)

        AppLogger.shared.logInfo("New user \(registerData.username) registered on \(Date())")
        return .created
    }
    
}

/// Middleware for JWT verification
struct JWTMiddleware: AsyncMiddleware {
    func respond(to request: Vapor.Request, chainingTo next: any Vapor.AsyncResponder) async throws -> Vapor.Response {
        guard let token = request.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Missing or invalid token.")
        }

        let payload = try request.jwt.verify(token, as: TokenPayload.self)
        AppLogger.shared.logDebug("✅ Decoded Token Payload: \(payload)")
        //print("✅ Decoded Token Payload: \(payload)")  // DEBUG: Verify token contents
        
        request.auth.login(payload)
        return try await next.respond(to: request)
    }
   
}


// Generate a new JWT token with a one hour expiration
func generateJWT(for user: User, req: Request) throws -> String {
    let duration = AppConfig.default.JWTTokenExpiration
    let exp = ExpirationClaim(value: Date().addingTimeInterval(duration)) // Token valid for 1 hour
    let payload = TokenPayload(userID: user.id!, username: user.username, exp: exp)
    return try req.jwt.sign(payload)
}



//Register user payload
struct RegisterRequest: Content {
    let username: String
    let password: String
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

// Temporary in-memory user store
// Temporary in-memory user store with hashed password
let testUsers: [User] = [
    User(id: UUID(), username: "testuser", passwordHash: try! Bcrypt.hash("password123"))
]


