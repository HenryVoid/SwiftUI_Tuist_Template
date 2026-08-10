import Foundation
import GitHubServiceInterface

/// Get Repository Detail UseCase
public protocol GetRepositoryDetailUseCaseProtocol: Sendable {
    func execute(owner: String, repo: String) async throws -> RepositoryEntity
}

public actor GetRepositoryDetailUseCase: GetRepositoryDetailUseCaseProtocol {
    private let repository: any GitHubRepositoryProtocol
    
    public init(repository: any GitHubRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(owner: String, repo: String) async throws -> RepositoryEntity {
        return try await repository.getRepository(owner: owner, repo: repo)
    }
}
