import Foundation
import SwiftUI
import GitHubService
import CoreKit
import AnalyticsKit
import Logger
import Utility

/// Home View State
public struct HomeState: Sendable {
    var repositories: [RepositoryEntity] = []
    var isLoading: Bool = false
    var searchQuery: String = ""
    var currentPage: Int = 1
    var hasMorePages: Bool = true
    var error: String?
}

/// Home View Action
public enum HomeAction {
    case searchQueryChanged(String)
    case search
    case loadMore
    case repositoryTapped(RepositoryEntity)
    case clearError
}

/// Home ViewModel
@MainActor
public class HomeViewModel: ObservableObject {
    @Published public var state: HomeState = HomeState()
    
    @Injected private var searchUseCase: any SearchRepositoriesUseCaseProtocol
    
    private let analyticsManager = AnalyticsManager.shared
    
    public init() {}
    
    public func send(_ action: HomeAction) {
        Task {
            await handle(action)
        }
    }
    
    private func handle(_ action: HomeAction) async {
        switch action {
        case .searchQueryChanged(let query):
            state.searchQuery = query
            
        case .search:
            await performSearch(isNewSearch: true)
            
        case .loadMore:
            guard !state.isLoading && state.hasMorePages else { return }
            await performSearch(isNewSearch: false)
            
        case .repositoryTapped(let repository):
            Log.advanced(
                "Repository tapped",
                level: .info,
                metadata: ["repo": repository.fullName]
            )
            
            await analyticsManager.logEvent(AnalyticsEvent(
                name: "repository_tapped",
                parameters: ["repo_name": repository.fullName]
            ))
            
        case .clearError:
            state.error = nil
        }
    }
    
    private func performSearch(isNewSearch: Bool) async {
        guard !state.searchQuery.isEmpty else { return }
        
        state.isLoading = true
        state.error = nil
        
        if isNewSearch {
            state.currentPage = 1
            state.repositories = []
            state.hasMorePages = true
            
            await await analyticsManager.logScreenView(screenName: "GitHubSearch_Home")
            await analyticsManager.logEvent(AnalyticsEvent(
                name: "search_repository",
                parameters: ["query": state.searchQuery]
            ))
        }
        
        Log.advanced(
            "Searching repositories",
            level: .info,
            metadata: ["query": state.searchQuery, "page": "\(state.currentPage)"]
        )
        
        do {
            let repositories = try await searchUseCase.execute(
                query: state.searchQuery,
                page: state.currentPage
            )
            
            if isNewSearch {
                state.repositories = repositories
            } else {
                state.repositories.append(contentsOf: repositories)
            }
            
            state.hasMorePages = repositories.count >= 30
            state.currentPage += 1
            
            Log.advanced(
                "Search completed",
                level: .info,
                metadata: [
                    "query": state.searchQuery,
                    "results": "\(repositories.count)",
                    "total": "\(state.repositories.count)"
                ]
            )
        } catch {
            state.error = error.localizedDescription
            
            Log.advanced(
                "Search failed",
                level: .error,
                metadata: ["query": state.searchQuery, "error": error.localizedDescription]
            )
            
            await analyticsManager.logError(error: error, context: "GitHubSearch")
        }
        
        state.isLoading = false
    }
}

