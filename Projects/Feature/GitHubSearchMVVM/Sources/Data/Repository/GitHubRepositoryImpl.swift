import Foundation
import GitHubServiceInterface
import GitHubService

/// GitHub Repository Implementation (Data Layer)
public actor GitHubRepositoryImpl: GitHubRepositoryProtocol {
    private let gitHubService: GitHubService
    
    public init(gitHubService: GitHubService) {
        self.gitHubService = gitHubService
    }
    
    public func searchRepositories(query: String, page: Int) async throws -> GitHubSearchResponse {
        return try await gitHubService.searchRepositories(query: query, page: page)
    }
    
    public func getRepository(owner: String, repo: String) async throws -> GitHubRepository {
        return try await gitHubService.getRepository(owner: owner, repo: repo)
    }
}
