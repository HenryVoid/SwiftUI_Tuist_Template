import Foundation

/// GitHub Repository 모델
public struct GitHubRepository: Codable, Identifiable, Sendable, Hashable {
    public let id: Int
    public let name: String
    public let fullName: String
    public let owner: Owner
    public let description: String?
    public let stargazersCount: Int
    public let forksCount: Int
    public let language: String?
    public let htmlUrl: String
    public let createdAt: String
    public let updatedAt: String
    public let watchersCount: Int
    public let openIssuesCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, owner, description, language
        case fullName = "full_name"
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
        case htmlUrl = "html_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case watchersCount = "watchers_count"
        case openIssuesCount = "open_issues_count"
    }
    
    public init(
        id: Int,
        name: String,
        fullName: String,
        owner: Owner,
        description: String?,
        stargazersCount: Int,
        forksCount: Int,
        language: String?,
        htmlUrl: String,
        createdAt: String,
        updatedAt: String,
        watchersCount: Int,
        openIssuesCount: Int
    ) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.owner = owner
        self.description = description
        self.stargazersCount = stargazersCount
        self.forksCount = forksCount
        self.language = language
        self.htmlUrl = htmlUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.watchersCount = watchersCount
        self.openIssuesCount = openIssuesCount
    }
}

/// Repository Owner 모델
public struct Owner: Codable, Sendable, Hashable {
    public let login: String
    public let id: Int
    public let avatarUrl: String
    public let htmlUrl: String
    
    enum CodingKeys: String, CodingKey {
        case login, id
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
    }
    
    public init(login: String, id: Int, avatarUrl: String, htmlUrl: String) {
        self.login = login
        self.id = id
        self.avatarUrl = avatarUrl
        self.htmlUrl = htmlUrl
    }
}

/// GitHub 검색 응답
public struct GitHubSearchResponse: Codable, Sendable {
    public let totalCount: Int
    public let incompleteResults: Bool
    public let items: [GitHubRepository]
    
    enum CodingKeys: String, CodingKey {
        case items
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
    }
    
    public init(totalCount: Int, incompleteResults: Bool, items: [GitHubRepository]) {
        self.totalCount = totalCount
        self.incompleteResults = incompleteResults
        self.items = items
    }
}

