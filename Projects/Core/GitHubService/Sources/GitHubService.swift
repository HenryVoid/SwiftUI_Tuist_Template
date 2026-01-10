import Foundation
import NetworkKit
import Logger

/// GitHub Service 구현 (Actor로 Thread-safe 보장)
public actor GitHubService: GitHubServiceProtocol {
    private let networkService: NetworkService
    
    // Task를 enum으로 wrapping하여 타입 문제 해결
    private enum OngoingRequest {
        case search(Task<GitHubSearchResponse, any Error>)
        case repository(Task<GitHubRepository, any Error>)
    }
    
    private var ongoingRequests: [String: OngoingRequest] = [:]
    
    public init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
    
    public func searchRepositories(query: String, page: Int) async throws -> GitHubSearchResponse {
        let key = "search_\(query)_\(page)"
        
        // 중복 요청 방지
        if let existingRequest = ongoingRequests[key],
           case .search(let task) = existingRequest {
            Log.debug("Using existing search task for: \(query), page: \(page)")
            return try await task.value
        }
        
        let task = Task {
            defer { ongoingRequests.removeValue(forKey: key) }
            
            Log.advanced(
                "Searching repositories",
                level: .network,
                metadata: ["query": query, "page": "\(page)"]
            )
            
            let request = SearchRepositoriesRequest(query: query, page: page, perPage: 30)
            let response = try await networkService.request(request)
            
            Log.advanced(
                "Search completed",
                level: .network,
                metadata: [
                    "query": query,
                    "page": "\(page)",
                    "results": "\(response.items.count)"
                ]
            )
            
            return response
        }
        
        ongoingRequests[key] = .search(task)
        return try await task.value
    }
    
    public func getRepository(owner: String, repo: String) async throws -> GitHubRepository {
        let key = "repo_\(owner)_\(repo)"
        
        // 중복 요청 방지
        if let existingRequest = ongoingRequests[key],
           case .repository(let task) = existingRequest {
            Log.debug("Using existing repo task for: \(owner)/\(repo)")
            return try await task.value
        }
        
        let task = Task {
            defer { ongoingRequests.removeValue(forKey: key) }
            
            Log.advanced(
                "Fetching repository details",
                level: .network,
                metadata: ["owner": owner, "repo": repo]
            )
            
            let request = GetRepositoryRequest(owner: owner, repo: repo)
            let response = try await networkService.request(request)
            
            Log.advanced(
                "Repository details fetched",
                level: .network,
                metadata: ["owner": owner, "repo": repo]
            )
            
            return response
        }
        
        ongoingRequests[key] = .repository(task)
        return try await task.value
    }
}

