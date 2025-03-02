//
//  VaultHomeView.swift
//  MediaVaultClient
//
//  Created by Neelesh Kamkolkar on 2/28/25.
//

import SwiftUI


struct VaultHomeView: View {
    @State var selection: Tabs = .demo
    @State var userLoggedIn: Bool = false
    @AppStorage("TabCustomizations") private var customization: TabViewCustomization
    
    enum Tabs: String {
        case home
        case demo
        case camera
        case vault
        case settings
        
        var customizationID: String{
            "com.amoha.MediaVault.\(rawValue)"
        }
    }
    
    
    var body: some View {
  
            NavigationSplitView{

                    TabView(selection: $selection){
                        
                        Tab("Home", systemImage: "house", value: Tabs.home){
                            VStack{
                                WelcomeView(showWelcome: $userLoggedIn, showRegistration: $userLoggedIn)
                                Button("Try It Now"){
                                    selection = .demo
                                }
                            }
                            
                        }
                        .customizationID(Tabs.home.customizationID)
                        
                        Tab("TryIt", systemImage: "figure.dance.circle.fill", value: Tabs.demo){
                            VStack{
                                TrialView()
                                Button("Register!"){
                                    selection = .home
                                }
                            }
                            
                        }
                        .customizationID(Tabs.demo.customizationID)
                        
                        
                        Tab("Vault", systemImage: "lock.circle.fill", value: Tabs.vault) {
                            VStack{
                                HomeView()
                                Button("Go to Camera"){
                                    selection = .camera
                                }
                            }
                        }
                        .customizationID(Tabs.vault.customizationID)
                        
                        Tab("Camera", systemImage: "camera.circle.fill", value: Tabs.camera) {
                            VStack{
                                Text("Camera")
                                Button("Go to Settings"){
                                    selection = .settings
                                }
                            }
                        }
                        .customizationID(Tabs.camera.customizationID)
                        
                        
                        Tab("Settings", systemImage: "gear.circle.fill", value: Tabs.settings) {
                            VStack{
                                SettingsView()
                                Button("Go to Home"){
                                    selection = .home
                                }
                            }
                        }
                        .customizationID(Tabs.settings.customizationID)
                        //.tabPlacement(.automatic)
                        .customizationBehavior(.disabled, for: .sidebar)
                    } // TabView
                
     
                 
                 
                .toolbar {
                    ToolbarItem (placement: .navigationBarTrailing){
                        Button() {
                            userLoggedIn = AuthService.shared.isLoggedIn()
                            if(userLoggedIn){
                                AuthService.shared.logout()// For debugging
                                userLoggedIn = false
                                Swift.print("VaultHomeView: userLoggedIn \(userLoggedIn)")
                            }else{
                                userLoggedIn = true
                                Swift.print("VaultHomeView: userLoggedIn \(userLoggedIn)")
                            }
                            
                        } label: {
                            Image(systemName: (!userLoggedIn) ? "person.badge.shield.exclamationmark" : "person.badge.shield.checkmark.fill")
                                .imageScale(.large)
                        }
                        
                    }
                }
                .sheet(isPresented: $userLoggedIn, content: {
                    LoginView()
                        .presentationDetents([.medium])
                })
            } detail: {
                Text("Welcome to Media Vault")
            }

        }
    
}

#Preview {
    VaultHomeView()
}
