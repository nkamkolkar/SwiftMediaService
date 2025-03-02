//
//  TrialView.swift
//  IOSClient
//
//  Created by Neelesh Kamkolkar on 3/1/25.
//

import SwiftUI
import PhotosUI

struct TrialView: View {
    
    @State private var mediaFiles: [URL] = []
    @State private var selectedMedia: URL?
    @State private var isFileInputPresented = false
    @State private var newFileName = ""
    @State private var selectedItem: PhotosPickerItem?
    //@State private var cachedFiles: [URL] = []
    
    var body: some View {
        
        
        
        VStack {
            if let selectedMedia = selectedMedia {
                MediaPreviewView(mediaURL: selectedMedia)
                
                AIGeneratedCaptionView()
                
                MediaCarouselView(mediaFiles: mediaFiles, onSelect: { selected in
                    self.selectedMedia = selected
                })
                //.frame(height: 200)
            }else{
                Text("Trial Unavailable")
            }
            
        }
        .onAppear(perform: loadDemoMedia)
        
    }
    
    private func loadDemoMedia() {
        
        var cachedFiles : [URL]
        cachedFiles = MediaCacheManager.shared.getDemoMediaFiles()
        
        if let firstFile = cachedFiles.first {
            selectedMedia = firstFile
        }
        mediaFiles = cachedFiles
    }
}

#Preview {
    TrialView()
}
