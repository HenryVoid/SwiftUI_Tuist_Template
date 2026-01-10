import SwiftUI
import GitHubService
import CacheKit
import Entity

/// 공통 Repository Row 컴포넌트
/// GitHubSearchMVVM, GitHubSearchTCA에서 재사용
public struct RepositoryRow: View {
    public let repository: RepositoryEntity
    @State private var avatarImage: UIImage?
    
    public init(repository: RepositoryEntity) {
        self.repository = repository
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            AvatarView(url: repository.owner.avatarUrl, size: 50)
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
                            .foregroundStyle(Color.primary500)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

