import XCTest
import RxSwift
import RxTest
@testable import GitHubSearchReactor
@testable import GitHubService

final class GitHubSearchReactorTests: XCTestCase {
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }
    
    override func tearDownWithError() throws {
        scheduler = nil
        disposeBag = nil
    }
    
    func testSearchAction() {
        // Given
        let mockService = MockRxGitHubService()
        let reactor = HomeReactor(service: mockService)
        
        // When
        reactor.action.onNext(.updateSearchQuery("swift"))
        reactor.action.onNext(.search)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertFalse(reactor.currentState.isLoading)
            XCTAssertEqual(reactor.currentState.repositories.count, 1)
            XCTAssertEqual(reactor.currentState.repositories.first?.name, "test-repo")
        }
    }
    
    func testLoadMoreAction() {
        // Given
        let mockService = MockRxGitHubService()
        let reactor = HomeReactor(service: mockService)
        
        // Set initial state
        reactor.action.onNext(.updateSearchQuery("swift"))
        reactor.action.onNext(.search)
        
        // Wait for initial search to complete
        Thread.sleep(forTimeInterval: 1.0)
        
        // When
        reactor.action.onNext(.loadMore)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertGreaterThan(reactor.currentState.repositories.count, 1)
        }
    }
}

// MARK: - Mock Service

class MockRxGitHubService: RxGitHubService {
    override func searchRepositories(query: String, page: Int) -> Single<[GitHubRepository]> {
        let mockRepo = GitHubRepository(
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
        )
        
        return .just([mockRepo])
    }
}

