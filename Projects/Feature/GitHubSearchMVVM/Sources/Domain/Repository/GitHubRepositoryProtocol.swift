import Foundation
import GitHubServiceInterface

/// GitHub Repository Protocol (Domain Layer)
public protocol GitHubRepositoryProtocol: Sendable {
    func searchRepositories(query: String, page: Int) async throws -> GitHubSearchResponse
    func getRepository(owner: String, repo: String) async throws -> GitHubRepository
}
