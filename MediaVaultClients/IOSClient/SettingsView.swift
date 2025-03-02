//
//  SettingsView.swift
//  MediaVaultClient
//
//  Created by Neelesh Kamkolkar on 2/25/25.
//

import SwiftUI


struct SettingsView: View {
    @State private var serverURL: String = "http://localhost"
    @State private var serverPort: String = "8080"
    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .bold()
                .padding(.all)
            
                
                VStack{
                    HStack{
                        Label("Server URL", systemImage: "server.rack")
                        
                        TextField(text: $serverURL, prompt: Text("Media Server URL")){
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocorrectionDisabled(true)
                    }
                    
                    HStack{
                        Label("Server Port", systemImage: "server.rack")
                        
                        
                        TextField("Media Server Port", text: $serverPort)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocorrectionDisabled(true)
                    }
                   
                }
                .padding(.leading)
   
            HStack (alignment: .center){
                Button("Save"){
                    UserDefaults.standard.set(serverURL, forKey: "MediaVaultServer")
                    UserDefaults.standard.set(serverPort, forKey: "Port")
                }
                .frame(maxWidth: 200)
                .padding(10)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(.capsule)
                
                
                Button("Cancel"){
                    
                }
                .frame(maxWidth: 200)
                .padding(10)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(.capsule)
                
            }
            .padding(20)
            
            
            GroupBox("DEBUG"){
                // Debug Reset Button
                Button("Reset Onboarding") {
                    UserDefaults.standard.removeObject(forKey: "hasSeenWelcome")
                    UserDefaults.standard.removeObject(forKey: "registrationDate")
                    exit(0) // Force restart app to reflect changes
                }
                .frame(maxWidth: 200)
                .padding(10)
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(.capsule)
            }
            //.foregroundStyle(.black)
            Spacer()
        }
        
    }
}


#Preview {
    SettingsView()
}
