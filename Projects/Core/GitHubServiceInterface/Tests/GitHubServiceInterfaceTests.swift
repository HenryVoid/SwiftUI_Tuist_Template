import Foundation
import Testing
@testable import GitHubServiceInterface

struct GitHubServiceInterfaceTests {
    @Test
    func decodesRepositorySearchResponse() throws {
        let json = """
        {
          "total_count": 1,
          "incomplete_results": false,
          "items": [
            {
              "id": 123,
              "name": "swift-repo",
              "full_name": "owner/swift-repo",
              "owner": {
                "login": "owner",
                "id": 456,
                "avatar_url": "https://example.com/avatar.png",
                "html_url": "https://github.com/owner"
              },
              "description": "A Swift repository",
              "stargazers_count": 100,
              "forks_count": 20,
              "language": "Swift",
              "html_url": "https://github.com/owner/swift-repo",
              "created_at": "2024-01-01T00:00:00Z",
              "updated_at": "2024-01-02T00:00:00Z",
              "watchers_count": 100,
              "open_issues_count": 5
            }
          ]
        }
        """

        let response = try JSONDecoder().decode(GitHubSearchResponse.self, from: Data(json.utf8))

        #expect(response.totalCount == 1)
        #expect(response.incompleteResults == false)
        #expect(response.items.first?.fullName == "owner/swift-repo")
        #expect(response.items.first?.owner.avatarUrl == "https://example.com/avatar.png")
    }

    @Test
    func protocolCanBeMockedByFeatureModules() async throws {
        let service: any GitHubServiceProtocol = MockGitHubService()
        let response = try await service.searchRepositories(query: "swift", page: 1)

        #expect(response.items.count == 1)
        #expect(response.items[0].name == "mock-repo")
    }
}

private actor MockGitHubService: GitHubServiceProtocol {
    func searchRepositories(query: String, page: Int) async throws -> GitHubSearchResponse {
        GitHubSearchResponse(
            totalCount: 1,
            incompleteResults: false,
            items: [repository]
        )
    }

    func getRepository(owner: String, repo: String) async throws -> GitHubRepository {
        repository
    }

    private var repository: GitHubRepository {
        GitHubRepository(
            id: 1,
            name: "mock-repo",
            fullName: "owner/mock-repo",
            owner: Owner(
                login: "owner",
                id: 2,
                avatarUrl: "https://example.com/avatar.png",
                htmlUrl: "https://github.com/owner"
            ),
            description: "Mock",
            stargazersCount: 10,
            forksCount: 2,
            language: "Swift",
            htmlUrl: "https://github.com/owner/mock-repo",
            createdAt: "2024-01-01T00:00:00Z",
            updatedAt: "2024-01-02T00:00:00Z",
            watchersCount: 10,
            openIssuesCount: 1
        )
    }
}
