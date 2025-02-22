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
    
    static func configureRoutes(_ app: Application) throws {
        //JWT Authcontroller Routes
        let authController = AuthController()
        authController.routes(app)
        
        
        let fileController = FileController()
        fileController.routes(app)
        
        
        
    }
    
}
