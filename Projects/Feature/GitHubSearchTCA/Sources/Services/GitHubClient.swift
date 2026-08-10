import Foundation
import GitHubServiceInterface
import GitHubService

/// GitHub Client for TCA
public struct GitHubClient: Sendable {
    public var searchRepositories: @Sendable (_ query: String, _ page: Int) async throws -> [GitHubRepository]
    public var getRepository: @Sendable (_ owner: String, _ repo: String) async throws -> GitHubRepository

    public init(
        searchRepositories: @escaping @Sendable (_ query: String, _ page: Int) async throws -> [GitHubRepository],
        getRepository: @escaping @Sendable (_ owner: String, _ repo: String) async throws -> GitHubRepository
    ) {
        self.searchRepositories = searchRepositories
        self.getRepository = getRepository
    }

    public init(service: any GitHubServiceProtocol = GitHubService()) {
        self.searchRepositories = { query, page in
            let response = try await service.searchRepositories(query: query, page: page)
            return response.items
        }

        self.getRepository = { owner, repo in
            try await service.getRepository(owner: owner, repo: repo)
        }
    }
}
