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

struct HomeView: View {
    @StateObject private var downloadService = DownloadService.shared
    @StateObject private var uploadService = UploadService.shared
    
    @State private var mediaFiles: [URL] = []
    @State private var selectedMedia: URL?
    @State private var isFileInputPresented = false
    @State private var newFileName = ""
    
    var body: some View {
        VStack {
            if let selectedMedia = selectedMedia {
                MediaPreviewView(mediaURL: selectedMedia)
                
                Button("Upload to Vault") {
                    Task {
                        await uploadService.uploadMedia(fileURL: selectedMedia)
                    }
                }
                .padding()
                .disabled(selectedMedia == nil)
                
                if let uploadStatus = uploadService.uploadStatus {
                    Text(uploadStatus)
                        .font(.caption)
                        .foregroundColor(uploadStatus.contains("failed") ? .red : .green)
                }
            } else {
                Text("No media available. Fetch a file to get started.")
                    .padding()
            }
            
            MediaCarouselView(mediaFiles: mediaFiles, onSelect: { selected in
                selectedMedia = selected
            })
            .frame(height: 200)
            
            Button("Fetch Remote File") {
                isFileInputPresented = true
            }
            .padding()
            .sheet(isPresented: $isFileInputPresented) {
                FileInputModal(fileName: $newFileName, isPresented: $isFileInputPresented, onDownload: fetchRemoteFile)
            }
        }
        .onAppear(perform: loadCachedMedia)
    }
    
    /// Loads media files from local cache.
    private func loadCachedMedia() {
        let cachedFiles = MediaCacheManager.shared.getAllCachedFiles()
        
        if let firstFile = cachedFiles.first {
            selectedMedia = firstFile
        }
        mediaFiles = cachedFiles
    }
    
    /// Initiates a remote file download and updates the UI upon completion.
    private func fetchRemoteFile() {
        guard !newFileName.isEmpty else { return }
        
        Task {
            await downloadService.downloadMediaFile(fileName: newFileName)
            loadCachedMedia() // Reload UI with updated cache
        }
    }
}

/// View to preview selected media.
struct MediaPreviewView: View {
    let mediaURL: URL
    
    var body: some View {
        if mediaURL.pathExtension.lowercased() == "mov" {
            VideoPlayer(player: AVPlayer(url: mediaURL))
                .frame(height: 250)
        } else if let image = UIImage(contentsOfFile: mediaURL.path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 250)
        } else {
            Text("Unsupported file format")
                .foregroundColor(.red)
        }
    }
}

/// View to display a vertical scrolling media carousel.
struct MediaCarouselView: View {
    let mediaFiles: [URL]
    let onSelect: (URL) -> Void
    @State private var videoThumbnails: [URL: UIImage] = [:]
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                ForEach(mediaFiles, id: \.self) { media in
                    Button(action: { onSelect(media) }) {
                        ZStack(alignment: .bottomTrailing) {
                            if media.pathExtension.lowercased() == "mov" {
                                if let thumbnail = videoThumbnails[media] {
                                    Image(uiImage: thumbnail)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipped()
                                } else {
                                    Color.black
                                        .frame(width: 80, height: 80)
                                        .onAppear { generateThumbnail(for: media) }
                                }
                            } else if let image = UIImage(contentsOfFile: media.path) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                            } else {
                                Color.gray
                                    .frame(width: 80, height: 80)
                            }
                            
                            Image(systemName: media.pathExtension.lowercased() == "mov" ? "video" : "photo")
                                .foregroundColor(.white)
                                .padding(5)
                        }
                        .frame(width: 80, height: 80)
                    }
                }
            }
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

