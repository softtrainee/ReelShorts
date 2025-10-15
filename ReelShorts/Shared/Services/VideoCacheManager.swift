//
//  VideoCacheManager.swift
//  ReelsApp
//
//  Created by Mohit Gupta on 14/10/25.
//
import Foundation

// Manages caching of video data to disk. Implements an LRU strategy.
class VideoCacheManager {
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let maxCacheSize: UInt64 = 200 * 1024 * 1024 // 200 MB

    init() {
        do {
            let baseDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            cacheDirectory = baseDirectory.appendingPathComponent("VideoCache")
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError("Could not create cache directory: \(error)")
        }
    }

    func get(forKey key: String) -> URL? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        if fileManager.fileExists(atPath: fileURL.path) {
            // Update the file's modification date to mark it as recently used for LRU.
            try? fileManager.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)
            return fileURL
        }
        return nil
    }

    func cacheVideo(from url: URL, forKey key: String) {
        guard get(forKey: key) == nil else { return } // Already cached

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else { return }
            
            let fileURL = self.cacheDirectory.appendingPathComponent(key)
            do {
                try data.write(to: fileURL)
                self.enforceCacheSizeLimit()
            } catch {
                print("Error saving video to cache: \(error)")
            }
        }.resume()
    }
    
    private func enforceCacheSizeLimit() {
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.contentAccessDateKey, .totalFileSizeKey], options: .skipsHiddenFiles)
            
            var files = try contents.map { url -> (url: URL, size: UInt64, lastAccess: Date) in
                let properties = try url.resourceValues(forKeys: [.totalFileSizeKey, .contentAccessDateKey])
                return (url, UInt64(properties.totalFileSize ?? 0), properties.contentAccessDate ?? .distantPast)
            }
            
            let currentSize = files.reduce(0) { $0 + $1.size }
            
            if currentSize > maxCacheSize {
                // Sort files by last access date (oldest first)
                files.sort { $0.lastAccess < $1.lastAccess }
                
                var sizeToDelete = currentSize - maxCacheSize
                for file in files {
                    if sizeToDelete <= 0 { break }
                    try fileManager.removeItem(at: file.url)
//                    sizeToDelete -= file.size
                    sizeToDelete = sizeToDelete &- file.size 
                }
            }
        } catch {
            print("Error enforcing cache size limit: \(error)")
        }
    }
}
