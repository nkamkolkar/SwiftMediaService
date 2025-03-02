//
//  VaultHomeView.swift
//  MediaVaultClient
//
//  Created by Neelesh Kamkolkar on 2/28/25.
//

import SwiftUI


struct VaultHomeView: View {
    @State var selection: Tabs = .vault
    @State var userLoggedIn: Bool = false
    @AppStorage("TabCustomizations") private var customization: TabViewCustomization
    
    enum Tabs: String {
        case home
        case camera
        case vault
        case settings
        
        var customizationID: String{
            "com.amoha.MediaVault.\(rawValue)"
        }
    }
    
    
    var body: some View {
        
       
     
      
      
            //Spacer()
            //NavigationSplitView{
            
            

        
                    TabView(selection: $selection){
                        
                        Tab("Home", systemImage: "house", value: Tabs.home){
                            VStack{
                                Text(" Home View ")
                                Button("Go Vault"){
                                    selection = .vault
                                }
                            }
                            
                        }
                        .customizationID(Tabs.home.customizationID)
                        
                        
                        Tab("Vault", systemImage: "lock.circle.fill", value: Tabs.vault) {
                            VStack{
                                Text("Vault")
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
                                Text("Settings")
                                Button("Go to Home"){
                                    selection = .home
                                }
                            }
                        }
                        .customizationID(Tabs.settings.customizationID)
                        .tabPlacement(.automatic)
                        .customizationBehavior(.disabled, for: .sidebar)
                    } // TabView
                
                /**
                 
                 
                .toolbar {
                    ToolbarItem (placement: .navigationBarTrailing){
                        Button() {
                            userLoggedIn = AuthService.shared.isLoggedIn()
                        } label: {
                            Image(systemName: userLoggedIn ? "person.badge.shield.exclamationmark" : "person.badge.shield.checkmark.fill")
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
                 */
        }
        //.ignoresSafeArea(.all)
        //.border(.white)
       
        //.frame(height: .greatestFiniteMagnitude)
        //.border(.red)
    
}

#Preview {
    VaultHomeView()
}
