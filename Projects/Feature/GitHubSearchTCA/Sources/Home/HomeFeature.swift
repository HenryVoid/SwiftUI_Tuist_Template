import Foundation
import ComposableArchitecture
import GitHubService
import Logger
import AnalyticsKit

@Reducer
public struct HomeFeature {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public var repositories: [GitHubRepository] = []
        public var searchQuery: String = ""
        public var isLoading: Bool = false
        public var currentPage: Int = 1
        public var hasMorePages: Bool = true
        public var error: String?
        
        public init() {}
    }
    
    public enum Action: Sendable {
        case searchQueryChanged(String)
        case searchButtonTapped
        case loadMore
        case searchResponse(TaskResult<[GitHubRepository]>)
        case repositoryTapped(GitHubRepository)
        case clearError
    }
    
    @Dependency(\.githubClient) var githubClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .searchQueryChanged(let query):
                state.searchQuery = query
                return .none
                
            case .searchButtonTapped:
                guard !state.searchQuery.isEmpty else { return .none }
                
                state.isLoading = true
                state.error = nil
                state.currentPage = 1
                state.repositories = []
                state.hasMorePages = true
                
                // Analytics
                Task {
                    await AnalyticsManager.shared.logScreenView(screenName: "GitHubSearch_TCA_Home")
                    AnalyticsManager.shared.logEvent(AnalyticsEvent(
                        name: "search_repository_tca",
                        parameters: ["query": state.searchQuery]
                    ))
                }
                
                // Logging
                Log.advanced(
                    "TCA: Searching repositories",
                    level: .info,
                    metadata: ["query": state.searchQuery]
                )
                
                return .run { [query = state.searchQuery, page = state.currentPage] send in
                    await send(.searchResponse(
                        TaskResult { try await githubClient.searchRepositories(query: query, page: page) }
                    ))
                }
                
            case .loadMore:
                guard !state.isLoading && state.hasMorePages else { return .none }
                
                state.isLoading = true
                
                return .run { [query = state.searchQuery, page = state.currentPage] send in
                    await send(.searchResponse(
                        TaskResult { try await githubClient.searchRepositories(query: query, page: page) }
                    ))
                }
                
            case .searchResponse(.success(let repositories)):
                state.isLoading = false
                
                if state.currentPage == 1 {
                    state.repositories = repositories
                } else {
                    state.repositories.append(contentsOf: repositories)
                }
                
                state.hasMorePages = repositories.count >= 30
                state.currentPage += 1
                
                Log.advanced(
                    "TCA: Search completed",
                    level: .info,
                    metadata: [
                        "results": "\(repositories.count)",
                        "total": "\(state.repositories.count)"
                    ]
                )
                
                return .none
                
            case .searchResponse(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                
                Log.advanced(
                    "TCA: Search failed",
                    level: .error,
                    metadata: ["error": error.localizedDescription]
                )
                
                Task {
                    await AnalyticsManager.shared.logError(error: error, context: "GitHubSearch_TCA")
                }
                
                return .none
                
            case .repositoryTapped(let repository):
                Log.advanced(
                    "TCA: Repository tapped",
                    level: .info,
                    metadata: ["repo": repository.fullName]
                )
                
                Task {
                    AnalyticsManager.shared.logEvent(AnalyticsEvent(
                        name: "repository_tapped_tca",
                        parameters: ["repo_name": repository.fullName]
                    ))
                }
                
                return .none
                
            case .clearError:
                state.error = nil
                return .none
            }
        }
    }
}

// MARK: - Dependency

extension GitHubClient: DependencyKey {
    public static let liveValue = GitHubClient()
}

extension DependencyValues {
    var githubClient: GitHubClient {
        get { self[GitHubClient.self] }
        set { self[GitHubClient.self] = newValue }
    }
}

