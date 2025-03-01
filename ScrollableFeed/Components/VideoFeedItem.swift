//
//  VideoFeedItem.swift
//  ScrollableFeed
//
//  Created by Nursultan Yelemessov on 27/02/2025.
//

import SwiftUI
import AVKit

struct VideoFeedItem: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            }
            
            if isLoading {
                ProgressView()
            }
        }
        .frame(height: 300)
        .onAppear {
            loadVideo()
        }
    }
    
    private func loadVideo() {
        isLoading = true
        VideoCacheManager.shared.cacheVideo(for: videoURL) { returnedURL in
            guard let returnedURL = returnedURL else { return }
            
            if let currentPlayer = self.player,
               let currentAsset = currentPlayer.currentItem?.asset as? AVURLAsset,
               currentAsset.url != returnedURL {
                let newItem = AVPlayerItem(url: returnedURL)
                currentPlayer.replaceCurrentItem(with: newItem)
            } else if self.player == nil {
                let newPlayer = AVPlayer(url: returnedURL)
                newPlayer.automaticallyWaitsToMinimizeStalling = true
                self.player = newPlayer
            }
            if returnedURL != self.videoURL {
                self.isLoading = false
            }
        }
    }
}
