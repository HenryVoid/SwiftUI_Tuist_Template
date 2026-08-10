import SwiftUI
import GitHubServiceInterface
import CoreKit
import CacheKit
import DesignSystem

/// Home View
public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedRepository: RepositoryEntity?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Content
                if viewModel.state.repositories.isEmpty && !viewModel.state.isLoading {
                    emptyView
                } else {
                    repositoryList
                }
            }
            .navigationTitle("GitHub Search")
            .navigationDestination(item: $selectedRepository) { repository in
                DetailView(repository: repository)
            }
            .alert("Error", isPresented: .constant(viewModel.state.error != nil)) {
                Button("OK") {
                    viewModel.send(.clearError)
                }
            } message: {
                Text(viewModel.state.error ?? "")
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            TextField("Search repositories...", text: Binding(
                get: { viewModel.state.searchQuery },
                set: { viewModel.send(.searchQueryChanged($0)) }
            ))
            .textFieldStyle(.roundedBorder)
            .autocapitalization(.none)
            .onSubmit {
                viewModel.send(.search)
            }
            
            Button("Search") {
                viewModel.send(.search)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var repositoryList: some View {
        PaginatedListView(
            items: viewModel.state.repositories,
            threshold: 3,
            loadMore: {
                viewModel.send(.loadMore)
            }
        ) { repository in
            RepositoryRow(repository: repository)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedRepository = repository
                    viewModel.send(.repositoryTapped(repository))
                }
        }
        .overlay {
            if viewModel.state.isLoading && viewModel.state.repositories.isEmpty {
                ProgressView("Searching...")
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(Color.gray400)
            
            Text("Search GitHub Repositories")
                .title2(.medium)
                .foregroundStyle(Color.gray700)
            
            Text("Enter a search query to find repositories")
                .body2()
                .foregroundStyle(Color.gray500)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Repository Row
struct RepositoryRow: View {
    let repository: RepositoryEntity
    @State private var avatarImage: UIImage?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            avatarView
                .frame(width: 50, height: 50)
                .cornerRadius(8)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(repository.name)
                    .subtitle2(.medium)
                    .foregroundStyle(Color.gray900)
                
                Text(repository.owner.login)
                    .body3()
                    .foregroundStyle(Color.gray600)
                
                if let description = repository.description {
                    Text(description)
                        .body3()
                        .foregroundStyle(Color.gray700)
                        .lineLimit(2)
                }
                
                HStack(spacing: 16) {
                    Label("\(repository.stargazersCount)", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundStyle(Color.gray600)
                    
                    Label("\(repository.forksCount)", systemImage: "tuningfork")
                        .font(.caption)
                        .foregroundStyle(Color.gray600)
                    
                    if let language = repository.language {
                        Text(language)
                            .font(.caption)
                            .foregroundStyle(Color.primary500)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .task {
            await loadAvatar()
        }
    }
    
    private var avatarView: some View {
        Group {
            if let image = avatarImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray200
                    .overlay {
                        ProgressView()
                    }
            }
        }
    }
    
    private func loadAvatar() async {
        let cache = ImageCache.shared
        
        do {
            let image = try await cache.loadImage(from: repository.owner.avatarUrl)
            avatarImage = image
        } catch {
            // Fallback to placeholder
        }
    }
}
