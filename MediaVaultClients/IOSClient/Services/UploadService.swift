//
//  UploadService.swift
//  SwiftMediaClient
//
//  Created by Neelesh Kamkolkar on 2/19/25.
//


import SwiftUI
import SwiftData

class UploadService: ObservableObject {
    @Published var uploadStatus: String?
    public static let shared = UploadService()
    
    func uploadMedia(fileURL: URL) async {
       
        guard let token = await AuthService.shared.getAuthToken() else {
            print("⚠️ No valid token found")
            uploadStatus = "Upload failed: No authentication token"
            return
        }

        var request = URLRequest(url: URL(string: "\(APIConfig.baseURL)/upload")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        request.setValue(fileURL.lastPathComponent, forHTTPHeaderField: "X-Filename")
        
        print("UploadService: Uploading \(fileURL.lastPathComponent)")
        
        let task = URLSession.shared.uploadTask(with: request, fromFile: fileURL) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("⚠️ Upload error: \(error.localizedDescription)")
                    self.uploadStatus = "Upload failed: \(error.localizedDescription)"
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self.uploadStatus = "Upload successful!"
                } else {
                    self.uploadStatus = "Upload failed: Invalid server response"
                }
            }
        }

        task.resume()
    }

}
