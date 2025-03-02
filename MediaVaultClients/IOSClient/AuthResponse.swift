//
//  AuthResponse.swift
//  SwiftMediaClient
//
//  Created by Neelesh Kamkolkar on 2/18/25.
//


import Foundation

struct AuthResponse: Codable {
    let token: String
}

class AuthService : ObservableObject {
    
    static let shared = AuthService()
    
    private init() {}
    
    func isLoggedIn() -> Bool {
        return (KeychainService.getToken() != nil)
    }
    
    
    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(APIConfig.baseURL)/login") else { return }
        
        let requestBody: [String: Any] = ["username": username, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let token = json["token"] as? String {
                    KeychainService.saveToken(token)
                    DispatchQueue.main.async { completion(true) }
                } else {
                    DispatchQueue.main.async { completion(false) }
                }
            } catch {
                DispatchQueue.main.async { completion(false) }
            }
        }
        task.resume()
    }
    
    
    func logout() {
        KeychainService.deleteToken()
    }
    
    
    func register(username: String, password: String) async throws -> Bool {
        let url = URL(string: "\(APIConfig.baseURL)/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "username": username,
            "password": password
        ]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("HTTP Status Code:", httpResponse.statusCode)
        print("Raw Response:", String(data: data, encoding: .utf8) ?? "No response body")
        
        if httpResponse.statusCode == 201 {
            if data.isEmpty {
                // The server returned 201 Created with no body, assume success
                return true
            }
            
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                UserDefaults.standard.set(authResponse.token, forKey: "authToken")
                return true
            } catch {
                print("Decoding Error:", error.localizedDescription)
                return true // Assume success if status is 201 but response is empty
            }
        } else {
            return false
        }
    }
    
    func getAuthToken() async -> String? {
        if isLoggedIn() {
            return KeychainService.getToken()
        } else {
            print("getAuthToken: Not logged in")
            return nil
        }
        
    }
    
    
}
