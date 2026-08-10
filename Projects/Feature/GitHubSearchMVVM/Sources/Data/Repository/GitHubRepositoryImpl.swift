import Foundation
import GitHubServiceInterface

/// GitHub Repository Implementation (Data Layer)
public actor GitHubRepositoryImpl: GitHubRepositoryProtocol {
    private let gitHubService: any GitHubServiceProtocol

    public init(gitHubService: any GitHubServiceProtocol) {
        self.gitHubService = gitHubService
    }
    
    public func searchRepositories(query: String, page: Int) async throws -> GitHubSearchResponse {
        return try await gitHubService.searchRepositories(query: query, page: page)
    }
    
    public func getRepository(owner: String, repo: String) async throws -> GitHubRepository {
        return try await gitHubService.getRepository(owner: owner, repo: repo)
    }
}
