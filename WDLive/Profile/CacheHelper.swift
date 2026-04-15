//
//  CacheHelper.swift
//  WDLive
//

import Foundation

final class CacheHelper {

    static let shared = CacheHelper()

    private init() {}

    // Calculate cache size asynchronously (bytes)
    func calculateCacheSize(completion: @escaping (UInt64) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            var size: UInt64 = 0

            // URLCache
            let urlCache = URLCache.shared
            size += UInt64(urlCache.currentDiskUsage)

            // Caches directory
            let fm = FileManager.default
            if let cachesURL = fm.urls(for: .cachesDirectory, in: .userDomainMask).first {
                size += self.folderSize(at: cachesURL)
            }

            DispatchQueue.main.async { completion(size) }
        }
    }

    // Clear cache
    func clearCache(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            var success = true

            // Clear URLCache
            let urlCache = URLCache.shared
            urlCache.removeAllCachedResponses()

            // Clear Caches directory contents (not the directory itself)
            let fm = FileManager.default
            if let cachesURL = fm.urls(for: .cachesDirectory, in: .userDomainMask).first {
                do {
                    let contents = try fm.contentsOfDirectory(at: cachesURL, includingPropertiesForKeys: nil)
                    for item in contents {
                        do { try fm.removeItem(at: item) } catch { success = false }
                    }
                } catch {
                    success = false
                }
            }

            DispatchQueue.main.async { completion(success) }
        }
    }

    // Helper to compute folder size
    private func folderSize(at url: URL) -> UInt64 {
        let fm = FileManager.default
        var size: UInt64 = 0
        if let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: [], errorHandler: nil) {
            for case let fileURL as URL in enumerator {
                if let attr = try? fileURL.resourceValues(forKeys: [.fileSizeKey]), let fileSize = attr.fileSize {
                    size += UInt64(fileSize)
                }
            }
        }
        return size
    }

    // Format bytes to human-readable string
    func humanReadableSize(_ bytes: UInt64) -> String {
        let kb = Double(bytes) / 1024.0
        if kb < 1024 { return String(format: "%.1f KB", kb) }
        let mb = kb / 1024.0
        return String(format: "%.2f MB", mb)
    }
}
