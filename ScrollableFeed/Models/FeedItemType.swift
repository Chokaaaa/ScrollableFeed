//
//  FeedItemType.swift
//  ScrollableFeed
//
//  Created by Nursultan Yelemessov on 27/02/2025.
//

import Foundation
import SwiftUI

enum FeedItemType {
    case video(url: URL)
    case image(url: URL)
    case combo(imageUrl: URL, videoUrl: URL)
}
