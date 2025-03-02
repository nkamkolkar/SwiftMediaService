//
//  WelcomeView.swift
//  MediaVaultClient
//
//  Created by Neelesh Kamkolkar on 2/25/25.
//

import Foundation
import SwiftUI

struct WelcomeView: View {
    @Binding var showWelcome: Bool
    @Binding var showRegistration: Bool
    
    var body: some View {
        VStack {
            Text("Welcome to Media Vault")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Text("Get started by setting up your Media Vault account.")
                .padding()
            
            Button("Get Started") {
                UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
                UserDefaults.standard.set(Date(), forKey: "registrationDate")
                showWelcome = false
                showRegistration = true // Trigger fullScreenCover in MainTabView
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
