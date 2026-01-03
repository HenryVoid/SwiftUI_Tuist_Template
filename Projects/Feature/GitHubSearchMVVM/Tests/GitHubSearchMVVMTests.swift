import XCTest
@testable import GitHubSearchMVVM
@testable import GitHubService

final class GitHubSearchMVVMTests: XCTestCase {
    
    func testSearchRepositoriesUseCase() async throws {
        // Given
        let mockRepo = MockGitHubRepository()
        let useCase = SearchRepositoriesUseCase(repository: mockRepo)
        
        // When
        let result = try await useCase.execute(query: "swift", page: 1)
        
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "test-repo")
    }
    
    func testGetRepositoryDetailUseCase() async throws {
        // Given
        let mockRepo = MockGitHubRepository()
        let useCase = GetRepositoryDetailUseCase(repository: mockRepo)
        
        // When
        let result = try await useCase.execute(owner: "owner", repo: "test-repo")
        
        // Then
        XCTAssertEqual(result.name, "test-repo")
        XCTAssertEqual(result.owner.login, "owner")
    }
}

// MARK: - Mock Repository

actor MockGitHubRepository: GitHubRepositoryProtocol {
    func searchRepositories(query: String, page: Int) async throws -> GitHubSearchResponse {
        let mockOwner = Owner(
            login: "owner",
            id: 456,
            avatarUrl: "https://example.com/avatar.jpg",
            htmlUrl: "https://github.com/owner"
        )
        
        let mockRepo = GitHubRepository(
            id: 123,
            name: "test-repo",
            fullName: "owner/test-repo",
            owner: mockOwner,
            description: "Test repository",
            stargazersCount: 100,
            forksCount: 20,
            language: "Swift",
            htmlUrl: "https://github.com/owner/test-repo",
            createdAt: "2024-01-01T00:00:00Z",
            updatedAt: "2024-01-02T00:00:00Z",
            watchersCount: 100,
            openIssuesCount: 5
        )
        
        return GitHubSearchResponse(
            totalCount: 1,
            incompleteResults: false,
            items: [mockRepo]
        )
    }
    
    func getRepository(owner: String, repo: String) async throws -> GitHubRepository {
        let mockOwner = Owner(
            login: owner,
            id: 456,
            avatarUrl: "https://example.com/avatar.jpg",
            htmlUrl: "https://github.com/\(owner)"
        )
        
        return GitHubRepository(
            id: 123,
            name: repo,
            fullName: "\(owner)/\(repo)",
            owner: mockOwner,
            description: "Test repository",
            stargazersCount: 100,
            forksCount: 20,
            language: "Swift",
            htmlUrl: "https://github.com/\(owner)/\(repo)",
            createdAt: "2024-01-01T00:00:00Z",
            updatedAt: "2024-01-02T00:00:00Z",
            watchersCount: 100,
            openIssuesCount: 5
        )
    }
}

