import SwiftUI
import GitHubServiceInterface
import CacheKit
import DesignSystem

/// 공통 Repository Row 컴포넌트
public struct GitHubRepositoryRow: View {
    public let repository: GitHubRepository
    @State private var avatarImage: UIImage?
    
    public init(repository: GitHubRepository) {
        self.repository = repository
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            avatarView
                .frame(width: 50, height: 50)
                .cornerRadius(8)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(repository.name)
                    .subtitle2(.bold)
                    .foregroundStyle(Color.gray900)
                
                Text(repository.owner.login)
                    .body3()
                    .foregroundStyle(Color.gray600)
                
                if let description = repository.description {
                    Text(description)
                        .body3()
                        .foregroundStyle(Color.gray700)
                        .lineLimit(2)
                }
                
                HStack(spacing: 16) {
                    Label("\(repository.stargazersCount)", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundStyle(Color.gray600)
                    
                    Label("\(repository.forksCount)", systemImage: "tuningfork")
                        .font(.caption)
                        .foregroundStyle(Color.gray600)
                    
                    if let language = repository.language {
                        Text(language)
                            .font(.caption)
                            .foregroundStyle(Color.blue)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var avatarView: some View {
        Group {
            if let image = avatarImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray.opacity(0.2)
                    .overlay {
                        ProgressView()
                    }
            }
        }
        .task {
            await loadAvatar()
        }
    }
    
    private func loadAvatar() async {
        do {
            let image = try await ImageCache.shared.loadImage(from: repository.owner.avatarUrl)
            avatarImage = image
        } catch {
            // Fallback to placeholder
        }
    }
}
