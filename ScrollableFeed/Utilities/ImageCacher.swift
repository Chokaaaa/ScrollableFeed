//
//  ImageCacher.swift
//  ScrollableFeed
//
//  Created by Nursultan Yelemessov on 28/02/2025.
//

import Foundation
import SwiftUI
import Combine
import CryptoKit

class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let memoryCache = NSCache<NSURL, UIImage>()
    
    private let fileManager = FileManager.default
    
    private var cacheDirectory: URL? {
        return fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("ImageCache")
    }
    
    private init() {
        memoryCache.countLimit = 100
        
        createCacheDirectoryIfNeeded()
    }
    
    private func createCacheDirectoryIfNeeded() {
        guard let cacheDirectory = cacheDirectory else { return }
        
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            do {
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
            } catch {
                print("Error creating cache directory: \(error)")
            }
        }
    }
    
    private func filename(for url: URL) -> String {
        let urlString = url.absoluteString
        let hash = SHA256.hash(data: urlString.data(using: .utf8) ?? Data())
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func fileURL(for url: URL) -> URL? {
        return cacheDirectory?.appendingPathComponent(filename(for: url))
    }
    
    func setObject(_ image: UIImage, forKey key: NSURL) {
        memoryCache.setObject(image, forKey: key)
        
        guard let url = key.absoluteURL, let fileURL = fileURL(for: url) else { return }
        
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        DispatchQueue.global(qos: .background).async {
            do {
                try data.write(to: fileURL)
            } catch {
                print("Error writing image to disk: \(error)")
            }
        }
    }
    
    func object(forKey key: NSURL) -> UIImage? {
        if let cachedImage = memoryCache.object(forKey: key) {
            return cachedImage
        }
        
        guard let url = key.absoluteURL, let fileURL = fileURL(for: url) else { return nil }
        
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                if let diskImage = UIImage(data: data) {
                    memoryCache.setObject(diskImage, forKey: key)
                    return diskImage
                }
            } catch {
                print("Error reading image from disk: \(error)")
            }
        }
        
        return nil
    }
    
    func clearCache() {
        memoryCache.removeAllObjects()
        
        guard let cacheDirectory = cacheDirectory else { return }
        
        do {
            try fileManager.removeItem(at: cacheDirectory)
            createCacheDirectoryIfNeeded()
        } catch {
            print("Error clearing disk cache: \(error)")
        }
    }
}

final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private var cancellable: AnyCancellable?
    
    func loadImage(from url: URL) {
        if let cachedImage = ImageCacheManager.shared.object(forKey: url as NSURL) {
            self.image = cachedImage
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { image in
                if let image = image {
                    ImageCacheManager.shared.setObject(image, forKey: url as NSURL)
                }
            })
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
    
    deinit {
        cancellable?.cancel()
    }
}
