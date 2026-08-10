import SwiftUI
import GitHubServiceInterface
import DesignSystem
import GitHubSearchShared

/// Detail View
public struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    
    public init(repository: RepositoryEntity) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(repository: repository))
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Owner Section
                ownerSection
                
                Divider()
                
                // Repository Info
                repositoryInfo
                
                Divider()
                
                // Statistics
                statisticsSection
                
                // Open in Browser Button
                Button {
                    viewModel.send(.openInBrowser)
                } label: {
                    Label("Open in GitHub", systemImage: "safari")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle(viewModel.state.repository.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.send(.refresh)
                } label: {
                    if viewModel.state.isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.state.error != nil)) {
            Button("OK") {
                viewModel.send(.clearError)
            }
        } message: {
            Text(viewModel.state.error ?? "")
        }
        .task {
            viewModel.onAppear()
        }
    }
    
    private var ownerSection: some View {
        HStack(spacing: 16) {
            AvatarView(url: viewModel.state.repository.owner.avatarUrl, size: 80)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.state.repository.owner.login)
                    .title3(.bold)
                    .foregroundStyle(Color.gray900)
                
                Text("Repository Owner")
                    .body3()
                    .foregroundStyle(Color.gray600)
            }
            
            Spacer()
        }
    }
    
    private var repositoryInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .title3(.bold)
                .foregroundStyle(Color.gray900)
            
            if let description = viewModel.state.repository.description {
                Text(description)
                    .body2()
                    .foregroundStyle(Color.gray700)
            } else {
                Text("No description available")
                    .body2()
                    .foregroundStyle(Color.gray500)
                    .italic()
            }
            
            if let language = viewModel.state.repository.language {
                HStack {
                    Text("Language:")
                        .body2()
                    Text(language)
                        .body2()
                        .foregroundStyle(Color.primary500)
                }
            }
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .title3(.bold)
                .foregroundStyle(Color.gray900)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(title: "Stars", value: "\(viewModel.state.repository.stargazersCount)", icon: "star.fill", color: .yellow)
                StatCard(title: "Forks", value: "\(viewModel.state.repository.forksCount)", icon: "tuningfork", color: .blue)
                StatCard(title: "Watchers", value: "\(viewModel.state.repository.watchersCount)", icon: "eye.fill", color: .green)
                StatCard(title: "Issues", value: "\(viewModel.state.repository.openIssuesCount)", icon: "exclamationmark.circle.fill", color: .red)
            }
        }
    }
}
