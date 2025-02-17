//
//  routes.swift
//  SwiftMediaService
//
//  Created by Neelesh Kamkolkar on 2/16/25.
//

import Vapor

//One place to configure and manage routes

struct routes {
    
    /// Configures API routes.
    ///
    ///
    ///
    
    
    /**
     static func configureRoutes(_ app: Application) {
     AppLogger.shared.logInfo("Configuring routes...")  // Add this for debugging
     app.get("health") { req in
     return "Media server is running!"
     }
     
     //Test Route for JWT
     app.get("jwt-test") { req -> String in
     return "JWT signing is configured!"
     }
     
     let authMiddleware = User.authenticator()
     let guardMiddleware = User.guardMiddleware()
     
     let protected = app.grouped(authMiddleware, guardMiddleware)
     
     //JWT Authcontroller Routes
     let authController = AuthController()
     authController.routes(app)
     
     
     let fileController = FileController()
     fileController.routes(app)
     }
     
     */
    
    
    static func configureRoutes(_ app: Application) throws {
        //JWT Authcontroller Routes
        let authController = AuthController()
        authController.routes(app)
        
        
        let fileController = FileController()
        fileController.routes(app)
  
    }
    
}
