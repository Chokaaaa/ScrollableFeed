//
//  VideoCacher.swift
//  ScrollableFeed
//
//  Created by Nursultan Yelemessov on 28/02/2025.
//

import Foundation
import SwiftUI

class VideoCacheManager {
    static let shared = VideoCacheManager()
    private init() {}

    func cacheVideo(for remoteURL: URL, completion: @escaping (URL?) -> Void) {
        let fileManager = FileManager.default
        guard let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            completion(nil)
            return
        }
        let videoCacheDirectory = cachesDirectory.appendingPathComponent("VideoCache", isDirectory: true)
        let fileName = remoteURL.lastPathComponent
        let localURL = videoCacheDirectory.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: localURL.path) {
            completion(localURL)
            return
        }
        
        completion(remoteURL)
        
        if !fileManager.fileExists(atPath: videoCacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: videoCacheDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating video cache directory: \(error)")
                return
            }
        }
        
        let task = URLSession.shared.downloadTask(with: remoteURL) { tempURL, response, error in
            if let error = error {
                print("Error downloading video: \(error)")
                return
            }
            guard let tempURL = tempURL else { return }
            do {
                try fileManager.moveItem(at: tempURL, to: localURL)
                print("Video cached at: \(localURL)")
                DispatchQueue.main.async {
                    completion(localURL)
                }
            } catch {
                print("Error caching video file: \(error)")
            }
        }
        task.resume()
    }
}
