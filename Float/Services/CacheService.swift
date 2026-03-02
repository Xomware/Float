// CacheService.swift
// Float

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.xomware.float", category: "Cache")

// MARK: - Cache Keys
enum CacheKey {
    static let dealsNearby = "deals.nearby"
    static let venuesAll = "venues.all"
    static func bookmarks(userId: String) -> String { "bookmarks.\(userId)" }
}

// MARK: - Cache Entry Wrapper
struct CacheEntry<T: Codable>: Codable {
    let data: T
    let expiresAt: Date?  // nil = never expires
    let cachedAt: Date

    var isExpired: Bool {
        guard let expiresAt else { return false }
        return Date() > expiresAt
    }
}

// MARK: - CacheService
actor CacheService {
    static let shared = CacheService()

    private var memCache = NSCache<NSString, AnyObject>()
    private let cacheDir: URL

    init() {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDir = base.appendingPathComponent("com.xomware.float.cache", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        memCache.countLimit = 50
    }

    // MARK: - Store

    /// Store a value with optional TTL. Pass `ttl: nil` for permanent cache.
    func store<T: Codable>(_ value: T, key: String, ttl: TimeInterval? = nil) {
        let entry = CacheEntry(
            data: value,
            expiresAt: ttl.map { Date().addingTimeInterval($0) },
            cachedAt: Date()
        )

        // Memory cache
        if let data = try? JSONEncoder().encode(entry) {
            memCache.setObject(data as NSData, forKey: key as NSString)

            // Disk cache
            let fileURL = cacheDir.appendingPathComponent(key.safeFileName)
            do {
                try data.write(to: fileURL, options: .atomic)
                logger.debug("Cached \(key) to disk (\(data.count) bytes)")
            } catch {
                logger.error("Failed to write cache for \(key): \(error)")
            }
        }
    }

    // MARK: - Fetch

    func fetch<T: Codable>(key: String, type: T.Type) -> T? {
        // Try memory first
        if let nsData = memCache.object(forKey: key as NSString) as? NSData,
           let entry = try? JSONDecoder().decode(CacheEntry<T>.self, from: nsData as Data) {
            if entry.isExpired {
                invalidate(key: key)
                return nil
            }
            return entry.data
        }

        // Try disk
        let fileURL = cacheDir.appendingPathComponent(key.safeFileName)
        guard let data = try? Data(contentsOf: fileURL),
              let entry = try? JSONDecoder().decode(CacheEntry<T>.self, from: data) else {
            return nil
        }

        if entry.isExpired {
            invalidate(key: key)
            return nil
        }

        // Promote to memory
        memCache.setObject(data as NSData, forKey: key as NSString)
        return entry.data
    }

    // MARK: - Cache Age

    func cacheAge(key: String) -> Date? {
        // Check disk for metadata
        let fileURL = cacheDir.appendingPathComponent(key.safeFileName)
        guard let data = try? Data(contentsOf: fileURL),
              let json = try? JSONDecoder().decode(CacheEntry<[String]>.self, from: data) else {
            // Try reading just the cachedAt from raw JSON
            guard let data = try? Data(contentsOf: fileURL),
                  let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let ts = dict["cachedAt"] as? String else {
                return nil
            }
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter.date(from: ts)
        }
        return json.cachedAt
    }

    // MARK: - Invalidate

    func invalidate(key: String) {
        memCache.removeObject(forKey: key as NSString)
        let fileURL = cacheDir.appendingPathComponent(key.safeFileName)
        try? FileManager.default.removeItem(at: fileURL)
        logger.debug("Invalidated cache: \(key)")
    }

    func invalidateAll() {
        memCache.removeAllObjects()
        if let files = try? FileManager.default.contentsOfDirectory(at: cacheDir, includingPropertiesForKeys: nil) {
            for file in files {
                try? FileManager.default.removeItem(at: file)
            }
        }
        logger.info("All cache invalidated")
    }
}

// MARK: - Helpers
private extension String {
    /// Sanitize cache key for use as a filename
    var safeFileName: String {
        self.replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ".", with: "_") + ".json"
    }
}
