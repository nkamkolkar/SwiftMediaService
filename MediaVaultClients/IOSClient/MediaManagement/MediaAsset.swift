//
//  MediaAsset.swift
//  SwiftMediaClient
//
//  Created by Neelesh Kamkolkar on 2/19/25.
//


import SwiftUI
import AVKit

/**
struct MediaAsset: Identifiable {
    let id = UUID()
    let url: URL
    let isVideo: Bool

    var image: UIImage? {
        guard !isVideo else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    var videoPlayer: AVPlayer? {
        guard isVideo else { return nil }
        return AVPlayer(url: url)
    }
}

*/

import SwiftUI
import AVKit

struct MediaAsset {
    let imageName: String?
    let videoName: String?
    let isVideo: Bool
    
    var image: Image? {
        guard let imageName = imageName, !isVideo else { return nil }
        return Image(imageName)
    }
    
    var videoURL: URL? {
        guard let videoName = videoName, isVideo else { return nil }
        return Bundle.main.url(forResource: videoName, withExtension: "mov")
    }
    
    var videoPlayer: AVPlayer? {
        guard let url = videoURL else { return nil }
        return AVPlayer(url: url)
    }
}

