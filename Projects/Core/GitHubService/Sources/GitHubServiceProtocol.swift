import Foundation

/// GitHub Service 프로토콜
public protocol GitHubServiceProtocol: Sendable {
    func searchRepositories(query: String, page: Int) async throws -> GitHubSearchResponse
    func getRepository(owner: String, repo: String) async throws -> GitHubRepository
}

