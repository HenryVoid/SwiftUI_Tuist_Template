import Foundation
import Utility
import GitHubService

/// DI Container for GitHubSearchMVVM
public final class GitHubSearchDIContainer {
    public static let shared = GitHubSearchDIContainer()
    
    private let container = ManualDIContainer.shared
    
    private init() {}
    
    public func setup() {
        // GitHubService
        container.registerSingleton(GitHubService.self) {
            GitHubService()
        }
        
        // Repository
        container.registerSingleton((any GitHubRepositoryProtocol).self) {
            let service = self.container.resolve(GitHubService.self)!
            return GitHubRepositoryImpl(gitHubService: service)
        }
        
        // UseCases
        container.register((any SearchRepositoriesUseCaseProtocol).self) {
            let repo = self.container.resolve((any GitHubRepositoryProtocol).self)!
            return SearchRepositoriesUseCase(repository: repo)
        }
        
        container.register((any GetRepositoryDetailUseCaseProtocol).self) {
            let repo = self.container.resolve((any GitHubRepositoryProtocol).self)!
            return GetRepositoryDetailUseCase(repository: repo)
        }
    }
}

