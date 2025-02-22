//
//  Scratch.swift
//  SwiftMediaClient
//
//  Created by Neelesh Kamkolkar on 2/19/25.
//
import SwiftUI

struct Scratch: View {
    @State private var username = ""
    @State private var password = ""
    @State private var loginFailed = false
    @State private var isLoggedIn = false
    @State private var showRegistration: Bool = false
    
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
                AuthService.shared.login(username: username, password: password) { success in
                    if success {
                        isLoggedIn = true
                    } else {
                        loginFailed = true
                    }
                }
            }
            
            Button(action: {
                showRegistration = true
            }) {
                Text("Register")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
            
            .fullScreenCover(isPresented: $isLoggedIn) {
                HomeView()
            }
            .fullScreenCover(isPresented: $showRegistration) {
                RegistrationView()
            }
            .padding()
            
            if loginFailed {
                Text("Login failed. Please try again.")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .fullScreenCover(isPresented: $isLoggedIn) {
            HomeView() // Navigate to home screen on successful login
        }
    }
}


