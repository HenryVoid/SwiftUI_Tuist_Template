import Foundation
import ReactorKit
import RxSwift
import RxCocoa
import GitHubService
import Logger
import AnalyticsKit

public final class HomeReactor: Reactor {
    public enum Action {
        case updateSearchQuery(String)
        case search
        case loadMore
        case refresh
    }
    
    public enum Mutation {
        case setSearchQuery(String)
        case setLoading(Bool)
        case setRepositories([GitHubRepository], append: Bool)
        case setError(String?)
        case incrementPage
        case resetPage
        case setHasMorePages(Bool)
    }
    
    public struct State {
        public var searchQuery: String = ""
        public var repositories: [GitHubRepository] = []
        public var isLoading: Bool = false
        public var currentPage: Int = 1
        public var hasMorePages: Bool = true
        public var error: String?
        
        public init() {}
    }
    
    public let initialState: State
    private let service: RxGitHubService
    private let analyticsManager = AnalyticsManager.shared
    
    public init(service: RxGitHubService = RxGitHubService()) {
        self.initialState = State()
        self.service = service
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateSearchQuery(let query):
            return .just(.setSearchQuery(query))
            
        case .search:
            guard !currentState.searchQuery.isEmpty else {
                return .empty()
            }
            
            // Analytics
            Task {
                await analyticsManager.logScreenView(screenName: "GitHubSearch_Reactor_Home")
                analyticsManager.logEvent(AnalyticsEvent(
                    name: "search_repository_reactor",
                    parameters: ["query": currentState.searchQuery]
                ))
            }
            
            Log.advanced(
                "Reactor: Searching repositories",
                level: .info,
                metadata: ["query": currentState.searchQuery]
            )
            
            let searchMutations = Observable.concat([
                Observable.just(.resetPage),
                Observable.just(.setLoading(true)),
                service.searchRepositories(query: currentState.searchQuery, page: 1)
                    .asObservable()
                    .flatMap { repositories -> Observable<Mutation> in
                        Log.advanced(
                            "Reactor: Search completed",
                            level: .info,
                            metadata: ["results": "\(repositories.count)"]
                        )
                        
                        return Observable.concat([
                            .just(.setRepositories(repositories, append: false)),
                            .just(.setHasMorePages(repositories.count >= 30)),
                            .just(.incrementPage),
                            .just(.setLoading(false)),
                            .just(.setError(nil))
                        ])
                    }
                    .catch { error in
                        Log.advanced(
                            "Reactor: Search failed",
                            level: .error,
                            metadata: ["error": error.localizedDescription]
                        )
                        
                        Task {
                            await self.analyticsManager.logError(error: error, context: "GitHubSearch_Reactor")
                        }
                        
                        return Observable.concat([
                            .just(.setLoading(false)),
                            .just(.setError(error.localizedDescription))
                        ])
                    }
            ])
            
            return searchMutations
            
        case .loadMore:
            guard !currentState.isLoading && currentState.hasMorePages else {
                return .empty()
            }
            
            return Observable.concat([
                Observable.just(.setLoading(true)),
                service.searchRepositories(query: currentState.searchQuery, page: currentState.currentPage)
                    .asObservable()
                    .flatMap { repositories -> Observable<Mutation> in
                        return Observable.concat([
                            .just(.setRepositories(repositories, append: true)),
                            .just(.setHasMorePages(repositories.count >= 30)),
                            .just(.incrementPage),
                            .just(.setLoading(false))
                        ])
                    }
                    .catch { error in
                        return Observable.concat([
                            .just(.setLoading(false)),
                            .just(.setError(error.localizedDescription))
                        ])
                    }
            ])
            
        case .refresh:
            return mutate(action: .search)
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setSearchQuery(let query):
            newState.searchQuery = query
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setRepositories(let repositories, let append):
            if append {
                newState.repositories.append(contentsOf: repositories)
            } else {
                newState.repositories = repositories
            }
            
        case .setError(let error):
            newState.error = error
            
        case .incrementPage:
            newState.currentPage += 1
            
        case .resetPage:
            newState.currentPage = 1
            newState.repositories = []
            
        case .setHasMorePages(let hasMore):
            newState.hasMorePages = hasMore
        }
        
        return newState
    }
}

