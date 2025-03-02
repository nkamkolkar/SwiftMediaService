//
//  LoginView.swift
//  SwiftMediaClient
//
//  Created by Neelesh Kamkolkar on 2/18/25.
//

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var loginFailed = false
    @State private var showRegistration: Bool = false
    @State private var isUserLoggedIn: Bool = false
    @StateObject private var authService = AuthService.shared  // Use central auth service

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Login") {
                authService.login(username: username, password: password) { success in
                    if !success {
                        loginFailed = true
                        isUserLoggedIn = false
                    }else{
                        isUserLoggedIn = true
                        loginFailed = false
                    }
                }
            }
            .padding()

            Button(action: {
                showRegistration = true
            }) {
                Text("Register")
                    .bold()
                    .frame(maxWidth: 200)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            if loginFailed {
                Text("Login failed. Please try again.")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .fullScreenCover(isPresented: $showRegistration) {
            RegistrationView()
        }
        .fullScreenCover(isPresented: $isUserLoggedIn) {  
            MainTabView()  
        }
    }
}
