import Foundation
import GitHubService

/// Search Repositories UseCase
public protocol SearchRepositoriesUseCaseProtocol: Sendable {
    func execute(query: String, page: Int) async throws -> [RepositoryEntity]
}

public actor SearchRepositoriesUseCase: SearchRepositoriesUseCaseProtocol {
    private let repository: any GitHubRepositoryProtocol
    
    public init(repository: any GitHubRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(query: String, page: Int) async throws -> [RepositoryEntity] {
        let response = try await repository.searchRepositories(query: query, page: page)
        return response.items
    }
}

