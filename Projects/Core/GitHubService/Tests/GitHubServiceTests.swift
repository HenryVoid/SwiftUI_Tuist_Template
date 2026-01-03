import XCTest
@testable import GitHubService
@testable import NetworkKit

final class GitHubServiceTests: XCTestCase {
    var service: GitHubService!
    var mockNetworkService: NetworkService!
    var configuration: URLSessionConfiguration!
    
    override func setUp() async throws {
        configuration = .ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        
        mockNetworkService = NetworkService(session: session)
        service = GitHubService(networkService: mockNetworkService)
    }
    
    override func tearDown() async throws {
        service = nil
        mockNetworkService = nil
        MockURLProtocol.requestHandler = nil
    }
    
    func testSearchRepositoriesSuccess() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            let mockResponse = """
            {
                "total_count": 1,
                "incomplete_results": false,
                "items": [
                    {
                        "id": 123,
                        "name": "test-repo",
                        "full_name": "owner/test-repo",
                        "owner": {
                            "login": "owner",
                            "id": 456,
                            "avatar_url": "https://example.com/avatar.jpg",
                            "html_url": "https://github.com/owner"
                        },
                        "description": "Test repository",
                        "stargazers_count": 100,
                        "forks_count": 20,
                        "language": "Swift",
                        "html_url": "https://github.com/owner/test-repo",
                        "created_at": "2024-01-01T00:00:00Z",
                        "updated_at": "2024-01-02T00:00:00Z",
                        "watchers_count": 100,
                        "open_issues_count": 5
                    }
                ]
            }
            """.data(using: .utf8)
            
            return (response, mockResponse)
        }
        
        // When
        let result = try await service.searchRepositories(query: "swift", page: 1)
        
        // Then
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.name, "test-repo")
        XCTAssertEqual(result.items.first?.owner.login, "owner")
        XCTAssertEqual(result.items.first?.stargazersCount, 100)
    }
    
    func testSearchRepositoriesEmpty() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            let mockResponse = """
            {
                "total_count": 0,
                "incomplete_results": false,
                "items": []
            }
            """.data(using: .utf8)
            
            return (response, mockResponse)
        }
        
        // When
        let result = try await service.searchRepositories(query: "nonexistent", page: 1)
        
        // Then
        XCTAssertEqual(result.items.count, 0)
        XCTAssertEqual(result.totalCount, 0)
    }
    
    func testGetRepositorySuccess() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            let mockResponse = """
            {
                "id": 123,
                "name": "test-repo",
                "full_name": "owner/test-repo",
                "owner": {
                    "login": "owner",
                    "id": 456,
                    "avatar_url": "https://example.com/avatar.jpg",
                    "html_url": "https://github.com/owner"
                },
                "description": "Test repository",
                "stargazers_count": 100,
                "forks_count": 20,
                "language": "Swift",
                "html_url": "https://github.com/owner/test-repo",
                "created_at": "2024-01-01T00:00:00Z",
                "updated_at": "2024-01-02T00:00:00Z",
                "watchers_count": 100,
                "open_issues_count": 5
            }
            """.data(using: .utf8)
            
            return (response, mockResponse)
        }
        
        // When
        let result = try await service.getRepository(owner: "owner", repo: "test-repo")
        
        // Then
        XCTAssertEqual(result.name, "test-repo")
        XCTAssertEqual(result.owner.login, "owner")
        XCTAssertEqual(result.stargazersCount, 100)
    }
}

/// Mock URLProtocol (NetworkKit에서 재사용)
final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Handler is unavailable.")
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

