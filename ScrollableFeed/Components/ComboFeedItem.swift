//
//  ComboFeedItem.swift
//  ScrollableFeed
//
//  Created by Nursultan Yelemessov on 01/03/2025.
//

import SwiftUI

struct ComboFeedItem: View {
    let imageUrl: URL
    let videoUrl: URL
    var body: some View {
        VStack {
            TabView {
                ImageFeedItem(url: imageUrl)
                VideoFeedItem(videoURL: videoUrl)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .frame(height: 300)
        }
    }
}
