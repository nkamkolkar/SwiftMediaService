//
//  MediaPreviewView.swift
//  MediaVaultClient
//
//  Created by Neelesh Kamkolkar on 2/25/25.
//

import SwiftUI
import AVFoundation
import AVKit

/// View to preview selected media.
struct MediaPreviewView: View {
    let mediaURL: URL
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let previewWidth = screenWidth - 30 // Add padding on both sides
        let previewHeight = 250.0
        ZStack{
            if mediaURL.pathExtension.lowercased() == "mov" {
                VideoPlayer(player: AVPlayer(url: mediaURL))
                    .frame(width: previewWidth, height: 250)
                    .cornerRadius(20)
                    //.border(Color.gray, width: 2)
            } else if let image = UIImage(contentsOfFile: mediaURL.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: previewWidth, height: 250)
                    .cornerRadius(20)
                    //.border(Color.gray, width: 2)
                    
            } else {
                Text("Unsupported file format")
                    .frame(width: previewWidth, height: 250)
                    .foregroundColor(.red)
            }
        }
        .frame(width: previewWidth+30, height: previewHeight+30)
        .cornerRadius(20)
        //.border(Color.red, width: 2)
        
    }
}

