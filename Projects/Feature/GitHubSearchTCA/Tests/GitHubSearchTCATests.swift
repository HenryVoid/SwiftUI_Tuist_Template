import XCTest
import ComposableArchitecture
@testable import GitHubSearchTCA
import GitHubServiceInterface

@MainActor
final class GitHubSearchTCATests: XCTestCase {
    func testSearchFlow() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.githubClient = MockGitHubClient()
        }
        
        // Change query
        await store.send(.searchQueryChanged("swift")) {
            $0.searchQuery = "swift"
        }
        
        // Tap search
        await store.send(.searchButtonTapped) {
            $0.isLoading = true
            $0.currentPage = 1
            $0.repositories = []
        }
        
        // Receive response
        let mockRepos = [createMockRepository()]
        await store.receive(.searchResponse(.success(mockRepos))) {
            $0.isLoading = false
            $0.repositories = mockRepos
            $0.hasMorePages = false
            $0.currentPage = 2
        }
    }
    
    func testLoadMore() async {
        let store = TestStore(
            initialState: HomeFeature.State(
                repositories: [createMockRepository()],
                searchQuery: "swift",
                currentPage: 2,
                hasMorePages: true
            )
        ) {
            HomeFeature()
        } withDependencies: {
            $0.githubClient = MockGitHubClient()
        }
        
        await store.send(.loadMore) {
            $0.isLoading = true
        }
        
        let mockRepos = [createMockRepository(id: 456)]
        await store.receive(.searchResponse(.success(mockRepos))) {
            $0.isLoading = false
            $0.repositories.append(contentsOf: mockRepos)
            $0.currentPage = 3
        }
    }
    
    private func createMockRepository(id: Int = 123) -> GitHubRepository {
        GitHubRepository(
            id: id,
            name: "test-repo",
            fullName: "owner/test-repo",
            owner: Owner(
                login: "owner",
                id: 456,
                avatarUrl: "https://example.com/avatar.jpg",
                htmlUrl: "https://github.com/owner"
            ),
            description: "Test",
            stargazersCount: 100,
            forksCount: 20,
            language: "Swift",
            htmlUrl: "https://github.com/owner/test-repo",
            createdAt: "2024-01-01T00:00:00Z",
            updatedAt: "2024-01-02T00:00:00Z",
            watchersCount: 100,
            openIssuesCount: 5
        )
    }
}

actor MockGitHubClient: DependencyKey {
    static let liveValue = MockGitHubClient()
    
    func searchRepositories(query: String, page: Int) async throws -> [GitHubRepository] {
        [GitHubRepository(
            id: 123,
            name: "test-repo",
            fullName: "owner/test-repo",
            owner: Owner(
                login: "owner",
                id: 456,
                avatarUrl: "https://example.com/avatar.jpg",
                htmlUrl: "https://github.com/owner"
            ),
            description: "Test",
            stargazersCount: 100,
            forksCount: 20,
            language: "Swift",
            htmlUrl: "https://github.com/owner/test-repo",
            createdAt: "2024-01-01T00:00:00Z",
            updatedAt: "2024-01-02T00:00:00Z",
            watchersCount: 100,
            openIssuesCount: 5
        )]
    }
}
