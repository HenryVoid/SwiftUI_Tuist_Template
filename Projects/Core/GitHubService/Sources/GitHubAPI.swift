import Foundation
import GitHubServiceInterface
import NetworkKit

/// GitHub API 요청
public enum GitHubAPI {
    case searchRepositories(query: String, page: Int, perPage: Int)
    case getRepository(owner: String, repo: String)
}

extension GitHubAPI {
    var baseURL: String {
        "https://api.github.com"
    }
    
    var path: String {
        switch self {
        case .searchRepositories:
            return "/search/repositories"
        case .getRepository(let owner, let repo):
            return "/repos/\(owner)/\(repo)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .searchRepositories, .getRepository:
            return .get
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .searchRepositories(let query, let page, let perPage):
            return [
                "q": query,
                "page": page,
                "per_page": perPage,
                "sort": "stars",
                "order": "desc"
            ]
        case .getRepository:
            return nil
        }
    }
}

/// 검색 요청
public struct SearchRepositoriesRequest: NetworkRequest {
    public typealias Response = GitHubSearchResponse
    
    public let baseURL: String
    public let path: String
    public let method: HTTPMethod
    public let parameters: [String: Any]?
    public let headers: [String: String]?
    
    public init(query: String, page: Int = 1, perPage: Int = 30) {
        let api = GitHubAPI.searchRepositories(query: query, page: page, perPage: perPage)
        self.baseURL = api.baseURL
        self.path = api.path
        self.method = api.method
        self.parameters = api.parameters
        self.headers = [
            "Accept": "application/vnd.github.v3+json"
        ]
    }
}

/// Repository 상세 요청
public struct GetRepositoryRequest: NetworkRequest {
    public typealias Response = GitHubRepository
    
    public let baseURL: String
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]?
    
    public init(owner: String, repo: String) {
        let api = GitHubAPI.getRepository(owner: owner, repo: repo)
        self.baseURL = api.baseURL
        self.path = api.path
        self.method = api.method
        self.headers = [
            "Accept": "application/vnd.github.v3+json"
        ]
    }
}
