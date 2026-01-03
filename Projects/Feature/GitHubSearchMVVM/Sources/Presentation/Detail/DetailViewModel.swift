import Foundation
import SwiftUI
import GitHubService
import Logger
import AnalyticsKit
import Utility

/// Detail View State
public struct DetailState: Sendable {
    var repository: RepositoryEntity
    var isLoading: Bool = false
    var error: String?
}

/// Detail View Action
public enum DetailAction {
    case refresh
    case openInBrowser
    case clearError
}

/// Detail ViewModel
@MainActor
public class DetailViewModel: ObservableObject {
    @Published public var state: DetailState
    
    @Injected private var getDetailUseCase: GetRepositoryDetailUseCaseProtocol
    
    private let analyticsManager = AnalyticsManager.shared
    
    public init(repository: RepositoryEntity) {
        self.state = DetailState(repository: repository)
    }
    
    public func send(_ action: DetailAction) {
        Task {
            await handle(action)
        }
    }
    
    private func handle(_ action: DetailAction) async {
        switch action {
        case .refresh:
            await refreshRepository()
            
        case .openInBrowser:
            if let url = URL(string: state.repository.htmlUrl) {
                await UIApplication.shared.open(url)
            }
            
            analyticsManager.logEvent(AnalyticsEvent(
                name: "repository_opened_in_browser",
                parameters: ["repo_name": state.repository.fullName]
            ))
            
        case .clearError:
            state.error = nil
        }
    }
    
    private func refreshRepository() async {
        state.isLoading = true
        state.error = nil
        
        let components = state.repository.fullName.split(separator: "/")
        guard components.count == 2 else {
            state.error = "Invalid repository name"
            state.isLoading = false
            return
        }
        
        let owner = String(components[0])
        let repo = String(components[1])
        
        do {
            let repository = try await getDetailUseCase.execute(owner: owner, repo: repo)
            state.repository = repository
            
            Log.advanced(
                "Repository detail refreshed",
                level: .info,
                metadata: ["repo": repository.fullName]
            )
        } catch {
            state.error = error.localizedDescription
            
            Log.advanced(
                "Repository detail refresh failed",
                level: .error,
                metadata: ["repo": state.repository.fullName, "error": error.localizedDescription]
            )
        }
        
        state.isLoading = false
    }
    
    func onAppear() {
        Task {
            await analyticsManager.logScreenView(screenName: "GitHubSearch_Detail")
            
            analyticsManager.logEvent(AnalyticsEvent(
                name: "repository_detail_viewed",
                parameters: ["repo_name": state.repository.fullName]
            ))
        }
    }
}

