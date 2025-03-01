//
//  ContentView.swift
//  ScrollableFeed
//
//  Created by Nursultan Yelemessov on 27/02/2025.
//

import SwiftUI

/*
 Task Explanation
 
 I've completed a task by implementing a scrollable feed of posts that are fetched from the website https://imgur.com The image posts or ImageFeedItem use a caching solution I made that persists an image locally according to its remote URL and that uses cache management to purge the cache after a certain period of time. This is handled by the ImageLoader class in each ImageFeedItem post. The video posts or VideoFeedItem use prefetching and video caching. Prefetching attempts to load the video just before it is seen so that users do not have to wait for the video to load. The video caching persist the video locally to ensure videos load quicker the next time when they are seen. This is handled by the VideoCacheManager class. Combination posts are simply a combination of the same image and video posts and a ComboFeedItem view.
 
 ScrollableFeedView uses a LazyVStack because this is optimal and performant for dynamic data. Altough the example here uses static data, in a real world feed, data would be pulled dynamicly from a server.
 
 This implementation uses a MVVM architecture. The main model is the FeedItem which wraps around the FeedItemType and ensures that an id is present which is a core requirement of the ForEach loop. The FeedItemType distignuishes the 3 different types of posts: a single photo, a single video, and a combination of one photo and one video. The viewModel ScrollableFeedViewModel holds on to an array of posts and does all the logic behind video prefetching.
 
 I added a custom modifier called VisibleModifier to detect if a post is about to become visible. This is an important part of video prefetching solution. Only when a post about to become visible does the prefetch happen.
 
 */

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
