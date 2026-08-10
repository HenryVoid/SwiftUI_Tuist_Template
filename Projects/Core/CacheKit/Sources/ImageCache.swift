import Foundation
#if canImport(UIKit)
import UIKit

/// 이미지 캐시 (메모리 + 디스크)
public actor ImageCache {
    public struct CacheStatistics: Sendable {
        public let cacheSize: Int
        public let hitRate: Double
        public let totalCachedImages: Int
        public let cacheHits: Int
        public let cacheMisses: Int

        public init(
            cacheSize: Int,
            hitRate: Double,
            totalCachedImages: Int,
            cacheHits: Int,
            cacheMisses: Int
        ) {
            self.cacheSize = cacheSize
            self.hitRate = hitRate
            self.totalCachedImages = totalCachedImages
            self.cacheHits = cacheHits
            self.cacheMisses = cacheMisses
        }
    }

    private let memoryCache: MemoryCache<String, Data>
    private let diskCache: DiskCache<String, Data>?
    private var cachedImageDataSizes: [String: Int] = [:]
    private var cacheHits = 0
    private var cacheMisses = 0

    public static let shared = ImageCache()

    public init() {
        self.memoryCache = MemoryCache<String, Data>(
            countLimit: 100,
            totalCostLimit: 100 * 1024 * 1024, // 100MB
            defaultExpiration: 3600 // 1시간
        )

        self.diskCache = try? DiskCache<String, Data>(
            defaultExpiration: 604800 // 7일
        )
    }

    /// 이미지 캐시에서 가져오기
    public func image(for url: String) async -> UIImage? {
        // 메모리 캐시 확인
        if let data = try? await memoryCache.get(url),
           let image = UIImage(data: data) {
            cacheHits += 1
            cachedImageDataSizes[url] = data.count
            return image
        }

        // 디스크 캐시 확인
        if let data = try? await diskCache?.get(url),
           let image = UIImage(data: data) {
            // 메모리 캐시에도 저장
            cacheHits += 1
            cachedImageDataSizes[url] = data.count
            try? await memoryCache.set(data, forKey: url, expiration: nil)
            return image
        }

        cacheMisses += 1
        return nil
    }

    /// 이미지 캐시에 저장
    public func setImage(_ image: UIImage, for url: String) async {
        guard let data = image.pngData() else { return }

        cachedImageDataSizes[url] = data.count

        // 메모리와 디스크 모두에 저장
        try? await memoryCache.set(data, forKey: url, expiration: nil)
        try? await diskCache?.set(data, forKey: url, expiration: nil)
    }

    /// URL로부터 이미지 다운로드 및 캐싱
    public func loadImage(from urlString: String) async throws -> UIImage {
        // 캐시 확인
        if let cachedImage = await image(for: urlString) {
            return cachedImage
        }

        // 다운로드
        guard let url = URL(string: urlString) else {
            throw CacheError.invalidData
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode),
              let image = UIImage(data: data) else {
            throw CacheError.invalidData
        }

        // 캐시 저장
        await setImage(image, for: urlString)

        return image
    }

    /// 이미지 캐시 제거
    public func removeImage(for url: String) async {
        cachedImageDataSizes.removeValue(forKey: url)
        try? await memoryCache.remove(url)
        try? await diskCache?.remove(url)
    }

    /// 모든 이미지 캐시 제거
    public func removeAllImages() async {
        cachedImageDataSizes.removeAll()
        cacheHits = 0
        cacheMisses = 0
        try? await memoryCache.removeAll()
        try? await diskCache?.removeAll()
    }

    /// 디스크 캐시 정리
    public func cleanDiskCache() async {
        try? await diskCache?.cleanExpiredCache()
    }

    /// 대시보드 표시용 캐시 통계
    public func getCacheStatistics() -> CacheStatistics {
        let requestCount = cacheHits + cacheMisses
        let hitRate = requestCount > 0 ? Double(cacheHits) / Double(requestCount) : 0.0

        return CacheStatistics(
            cacheSize: cachedImageDataSizes.values.reduce(0, +),
            hitRate: hitRate,
            totalCachedImages: cachedImageDataSizes.count,
            cacheHits: cacheHits,
            cacheMisses: cacheMisses
        )
    }
}

// MARK: - SwiftUI Support

#if canImport(SwiftUI)
import SwiftUI

/// 비동기 이미지 로더
@MainActor
public class AsyncImageLoader: ObservableObject {
    @Published public private(set) var image: UIImage?
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: (any Error)?

    private let imageCache = ImageCache.shared

    public init() {}

    public func load(from urlString: String) async {
        isLoading = true
        error = nil

        do {
            let loadedImage = try await imageCache.loadImage(from: urlString)
            image = loadedImage
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }

    public func cancel() {
        isLoading = false
    }
}
#endif

#endif
