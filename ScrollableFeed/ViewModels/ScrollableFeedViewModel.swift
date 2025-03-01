//
//  ScrollableFeedViewModel.swift
//  ScrollableFeed
//
//  Created by Nursultan Yelemessov on 27/02/2025.
//

import Foundation
import SwiftUI
import AVKit

class ScrollableFeedViewModel: ObservableObject {
    @Published var items = [
        FeedItem(type: .image(url: URL(string: "https://i.imgur.com/GJZV6KN.jpeg")!)),
        FeedItem(type: .image(url: URL(string: "https://i.imgur.com/QK7JNQg.jpeg")!)),
        FeedItem(type: .image(url: URL(string: "https://i.imgur.com/POmPS4R.jpeg")!)),
        FeedItem(type: .image(url: URL(string: "https://i.imgur.com/12zUY38.jpeg")!)),
        FeedItem(type: .video(url: URL(string: "https://i.imgur.com/yipyn81.mp4")!)),
        FeedItem(type: .combo(imageUrl:  URL(string: "https://i.imgur.com/12zUY38.jpeg")!,
                              videoUrl: URL(string: "https://i.imgur.com/yipyn81.mp4")!))
    ]
    
    private var prefetchWindow: Int = 2
    private var visibleIndices = Set<Int>()
    
    func itemAppeared(at index: Int) {
        visibleIndices.insert(index)
        updatePrefetching()
    }
    
    func itemDisappeared(at index: Int) {
        visibleIndices.remove(index)
        updatePrefetching()
    }
    
    private func updatePrefetching() {
        guard !visibleIndices.isEmpty else { return }
        
        let maxVisibleIndex = visibleIndices.max() ?? 0
        let prefetchStartIndex = maxVisibleIndex + 1
        let prefetchEndIndex = min(prefetchStartIndex + prefetchWindow - 1, items.count - 1)
        
        guard prefetchStartIndex <= prefetchEndIndex else { return }
        
        for index in prefetchStartIndex...prefetchEndIndex {
            let item = items[index]
            switch item.type {
            
            case .video(url: let url):
                VideoCacheManager.shared.cacheVideo(for: url) { _ in
                    
                }
                
            case .combo(_, videoUrl: let url):
                VideoCacheManager.shared.cacheVideo(for: url) { _ in
                    
                }
                
            default:
                break
            }
        }
    }
}
