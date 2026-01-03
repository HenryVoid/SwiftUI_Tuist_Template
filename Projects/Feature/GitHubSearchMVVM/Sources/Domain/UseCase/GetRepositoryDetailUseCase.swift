import Foundation
import GitHubService

/// Get Repository Detail UseCase
public protocol GetRepositoryDetailUseCaseProtocol: Sendable {
    func execute(owner: String, repo: String) async throws -> RepositoryEntity
}

public actor GetRepositoryDetailUseCase: GetRepositoryDetailUseCaseProtocol {
    private let repository: GitHubRepositoryProtocol
    
    public init(repository: GitHubRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(owner: String, repo: String) async throws -> RepositoryEntity {
        return try await repository.getRepository(owner: owner, repo: repo)
    }
}

