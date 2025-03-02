//
//  RegistrationView.swift
//  SwiftMediaClient
//
//  Created by Neelesh Kamkolkar on 2/18/25.
//


import SwiftUI

struct RegistrationView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var showLogin:Bool = false
    @State private var errorMessage: String?

    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Register")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 20)
            
            TextField("Username", text: $username)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: register) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Sign Up")
                        .bold()
                        .frame(maxWidth: 200)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isLoading)
            .padding(.horizontal)
            
            Button("Back to Login") {
                showLogin = true
            }
            .fullScreenCover(isPresented: $showLogin) {
                LoginView()
            }

            .padding()
        }
        .padding()
    }
    
    private func register() {
        guard !username.isEmpty, !password.isEmpty, password == confirmPassword else {
            errorMessage = "Please ensure all fields are filled and passwords match."
            return
        }
        
        isLoading = true
        Task {
            
            
            do {
                let success = try await AuthService.shared.register(username: username, password: password)
                DispatchQueue.main.async {
                    if success {
                        presentationMode.wrappedValue.dismiss() // Dismiss registration
                    } else {
                        errorMessage = "Registration failed. Please try again."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Unexpected error: \(error.localizedDescription)"
                    print("Register Error:", error)
                }
            }
            
            
            isLoading = false
        }
    }
}
