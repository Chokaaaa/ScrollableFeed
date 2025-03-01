//
//  ImageFeedItem.swift
//  ScrollableFeed
//
//  Created by Nursultan Yelemessov on 28/02/2025.
//

import Foundation
import SwiftUI

struct ImageFeedItem: View {
    @StateObject private var loader = ImageLoader()
    let url: URL

    init(url: URL) {
        self.url = url
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipped()
            } else {
                Rectangle()
                    .fill(.gray)
                    .frame(height: 300)
            }
        }
        .onAppear {
            loader.loadImage(from: url)
        }
    }
}
