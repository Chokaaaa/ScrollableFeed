//
//  ContentView.swift
//  ScrollableFeed
//
//  Created by Nursultan Yelemessov on 27/02/2025.
//

import SwiftUI

struct ScrollableFeedView: View {
    @State var viewModel = ScrollableFeedViewModel()
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                    switch item.type {
                    case .video(let url):
                        VideoFeedItem(videoURL: url)
                            .frame(height: 300)
                            .onAppear {
                                viewModel.itemAppeared(at: index)
                            }
                            .onDisappear {
                                viewModel.itemDisappeared(at: index)
                            }
                        
                    case .image(let url):
                        ImageFeedItem(url: url)
                            .onAppear {
                                viewModel.itemAppeared(at: index)
                            }
                            .onDisappear {
                                viewModel.itemDisappeared(at: index)
                            }
                    case .combo(imageUrl: let imageUrl, videoUrl: let videoUrl):
                        ComboFeedItem(imageUrl: imageUrl,videoUrl: videoUrl)
                            .frame(height: 300)
                            .onAppear {
                                viewModel.itemAppeared(at: index)
                            }
                            .onDisappear {
                                viewModel.itemDisappeared(at: index)
                            }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    ScrollableFeedView()
}
