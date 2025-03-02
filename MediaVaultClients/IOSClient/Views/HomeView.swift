//
//  HomeView.swift
//  SwiftMediaClient
//
//  Created by Neelesh Kamkolkar on 2/19/25.
//
import SwiftUI
import AVKit
import AVFoundation
import UIKit
import PhotosUI

struct HomeView: View {
    @StateObject private var downloadService = DownloadService.shared
    @StateObject private var uploadService = UploadService.shared
    @StateObject private var authService = AuthService.shared
    
    @State private var mediaFiles: [URL] = []
    @State private var selectedMedia: URL?
    @State private var isFileInputPresented = false
    @State private var newFileName = ""
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        if !authService.isLoggedIn() {
            LoginView()
        }else{
            
            VStack {
                if let selectedMedia = selectedMedia {
                    MediaPreviewView(mediaURL: selectedMedia)
                    
                    AIGeneratedCaptionView()
    
                    MediaCarouselView(mediaFiles: mediaFiles, onSelect: { selected in
                        self.selectedMedia = selected
                    })
                    //.frame(height: 200)
                    
                    HStack(spacing: 8){
                        Button(action: {
                            Task {
                                await uploadService.uploadMedia(fileURL: selectedMedia)
                            }
                        }) {
                            Label("Upload", systemImage: "square.and.arrow.up.fill")
                                .frame(width: 140, height: 45)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Capsule()) // Rounded button shape
                                .cornerRadius(8)
                                .padding()
                        }
                        .padding(8)
                        .disabled(selectedMedia == nil)
                        
                        if let uploadStatus = uploadService.uploadStatus {
                            Text(uploadStatus)
                                .font(.caption)
                                .foregroundColor(uploadStatus.contains("failed") ? Color.red : Color.green)
                        } else {
                            Text("No media available. Fetch a file to get started.")
                                .padding()
                                .foregroundColor(Color.black)
                        }
                        
                        
                        Button(action: {
                            isFileInputPresented = true
                        }) {
                            Label("Download", systemImage: "square.and.arrow.down.fill")
                                .frame(width: 140, height: 45)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Capsule()) // Rounded button shape
                                .cornerRadius(8)
                                .padding()
                        }
                        .padding(8)
                        .sheet(isPresented: $isFileInputPresented) {
                            FileInputModal(
                                fileName: $newFileName,
                                isPresented: $isFileInputPresented,
                                onDownload: {
                                    Task {
                                        let success = await fetchRemoteFile(fileName: newFileName)
                                        if success {
                                            DispatchQueue.main.async {
                                                isFileInputPresented = false // Close modal on success
                                            }
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
               
            }
            .onAppear(perform: loadCachedMedia)
        }
        
        
    }
    
    private func loadCachedMedia() {
        let cachedFiles = MediaCacheManager.shared.getAllCachedFiles()
        
        if let firstFile = cachedFiles.first {
            selectedMedia = firstFile
        }
        mediaFiles = cachedFiles
    }
    
    private func fetchRemoteFile(fileName: String) async -> Bool {
        let trimmedFileName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedFileName.isEmpty else { return false }
        
        await downloadService.downloadMediaFile(fileName: trimmedFileName)
        loadCachedMedia()
        
        return true
    }
}





/// View to display a vertical scrolling media carousel.
///
struct MediaCarouselView: View {
    let mediaFiles: [URL]
    let onSelect: (URL) -> Void
    let img_width : CGFloat = 21
    let img_height : CGFloat = 21
    @State private var videoThumbnails: [URL: UIImage] = [:]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) { // Horizontal scrolling
            LazyHStack(spacing: 2) { // Horizontal layout
                ForEach(mediaFiles, id: \.self) { media in
                    Button(action: { onSelect(media) }) {
                        ZStack(alignment: .bottomTrailing) {
                            if media.pathExtension.lowercased() == "mov" {
                                if let thumbnail = videoThumbnails[media] {
                                    //Convert to use the SwiftUI Image Thumbnail
                                    let swiftImage = Image(uiImage: thumbnail).renderingMode(.original)
                                    ThumbnailView(image: swiftImage)
                                } else {
                                    Color.black
                                        .frame(width: img_width, height: img_height)
                                        .onAppear { generateThumbnail(for: media) }
                                }
                            } else if let image = UIImage(contentsOfFile: media.path) {
                                //Convert to use the SwiftUI Image Thumbnail
                                let swiftImage = Image(uiImage: image).renderingMode(.original)
                                ThumbnailView(image: swiftImage)
                                
                            } else {
                                Color.gray
                                    .frame(width: img_width, height: img_height)
                            }
                            
                            Image(systemName: media.pathExtension.lowercased() == "mov" ? "video" : "photo")
                                .foregroundColor(.white)
                                .padding(1)
                                .scaleEffect(0.7)
                        }
                        //This is the entire button frame that include a smaller thumbnail above of size descrived in Thumbnail
                        .frame(width: 80, height: 80)
                        //.border(Color.white, width: 1)
                    }
                }
            }
            .padding(.horizontal) // Adds some padding on the sides
        }
    }


    
    private func generateThumbnail(for url: URL) {
        DispatchQueue.global(qos: .background).async {
            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 1, preferredTimescale: 600)
            
            if #available(iOS 18.0, *) {
                imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, actualTime, error in
                    guard let cgImage = cgImage, error == nil else { return }
                    let thumbnail = UIImage(cgImage: cgImage)
                    DispatchQueue.main.async {
                        videoThumbnails[url] = thumbnail
                    }
                }
            } else {
                do {
                    let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    DispatchQueue.main.async {
                        videoThumbnails[url] = thumbnail
                    }
                } catch {
                    print("Failed to generate thumbnail for \(url.lastPathComponent): \(error.localizedDescription)")
                }
            }
        }
    }
}

/// Modal for user to input a file name for download.
struct FileInputModal: View {
    @Binding var fileName: String
    @Binding var isPresented: Bool
    let onDownload: () -> Void
    
    var body: some View {
        VStack {
            Text("Enter File Name")
                .font(.headline)
            
            TextField("File name", text: $fileName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .padding()
                
                Button("Download") {
                    onDownload()
                }
                .padding()
            }
        }
        .padding()
    }
}

