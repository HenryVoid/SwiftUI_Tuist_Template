import Foundation
import GitHubService

/// GitHub Client for TCA
public actor GitHubClient {
    private let service: GitHubService
    
    public init() {
        self.service = GitHubService()
    }
    
    public func searchRepositories(query: String, page: Int) async throws -> [GitHubRepository] {
        let response = try await service.searchRepositories(query: query, page: page)
        return response.items
    }
    
    public func getRepository(owner: String, repo: String) async throws -> GitHubRepository {
        return try await service.getRepository(owner: owner, repo: repo)
    }
}

