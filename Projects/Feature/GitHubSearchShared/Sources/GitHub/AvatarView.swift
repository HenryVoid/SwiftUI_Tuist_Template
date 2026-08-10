import SwiftUI
import CacheKit
import DesignSystem

/// 비동기 이미지 로딩 Avatar 컴포넌트
public struct AvatarView: View {
    public let url: String
    public let size: CGFloat
    @State private var image: UIImage?
    
    public init(url: String, size: CGFloat = 50) {
        self.url = url
        self.size = size
    }
    
    public var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray200
                    .overlay {
                        ProgressView()
                    }
            }
        }
        .frame(width: size, height: size)
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        do {
            let loadedImage = try await ImageCache.shared.loadImage(from: url)
            image = loadedImage
        } catch {
            // Fallback to placeholder
        }
    }
}
