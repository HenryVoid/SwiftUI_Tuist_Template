import SwiftUI
import ComposableArchitecture
import GitHubServiceInterface
import DesignSystem
import GitHubSearchShared

public struct HomeView: View {
    let store: StoreOf<HomeFeature>
    
    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        TextField("Search repositories...", text: viewStore.binding(
                            get: \.searchQuery,
                            send: HomeFeature.Action.searchQueryChanged
                        ))
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .onSubmit {
                            viewStore.send(.searchButtonTapped)
                        }
                        
                        Button("Search") {
                            viewStore.send(.searchButtonTapped)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    
                    // Content
                    if viewStore.repositories.isEmpty && !viewStore.isLoading {
                        emptyView
                    } else {
                        repositoryList(viewStore: viewStore)
                    }
                }
                .navigationTitle("GitHub Search (TCA)")
                .alert(
                    "Error",
                    isPresented: viewStore.binding(
                        get: { $0.error != nil },
                        send: .clearError
                    )
                ) {
                    Button("OK") {}
                } message: {
                    Text(viewStore.error ?? "")
                }
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.gray400)
            
            Text("Search GitHub Repositories")
                .title2(.medium)
            
            Text("TCA Architecture")
                .body2(.regular)
                .foregroundStyle(.gray500)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func repositoryList(viewStore: ViewStoreOf<HomeFeature>) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewStore.repositories) { repository in
                    GitHubRepositoryRow(repository: repository)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewStore.send(.repositoryTapped(repository))
                        }
                        .task {
                            if repository.id == viewStore.repositories.last?.id {
                                viewStore.send(.loadMore)
                            }
                        }
                }
                
                if viewStore.isLoading {
                    ProgressView()
                        .padding()
                }
            }
        }
    }
}
