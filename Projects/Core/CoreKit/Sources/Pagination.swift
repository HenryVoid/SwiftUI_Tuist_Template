import SwiftUI

// MARK: - Pagination State

/// 페이지네이션 상태
public struct PaginationState: Sendable {
    public var currentPage: Int
    public var hasMorePages: Bool
    public var isLoading: Bool
    
    public init(currentPage: Int = 0, hasMorePages: Bool = true, isLoading: Bool = false) {
        self.currentPage = currentPage
        self.hasMorePages = hasMorePages
        self.isLoading = isLoading
    }
}

// MARK: - Paginated List View (SwiftUI)

/// 무한스크롤 리스트 뷰
@MainActor
public struct PaginatedListView<Item: Identifiable & Sendable, Content: View>: View {
    private let items: [Item]
    private let loadMore: () async -> Void
    private let content: (Item) -> Content
    private let threshold: Int
    
    @State private var isLoadingMore = false
    
    public init(
        items: [Item],
        threshold: Int = 3,
        loadMore: @escaping () async -> Void,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.threshold = threshold
        self.loadMore = loadMore
        self.content = content
    }
    
    public var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(items) { item in
                content(item)
                    .task {
                        // 마지막에서 threshold 번째 아이템에 도달하면 다음 페이지 로드
                        if shouldLoadMore(for: item) {
                            await loadMoreIfNeeded()
                        }
                    }
            }
            
            if isLoadingMore {
                ProgressView()
                    .frame(height: 60)
            }
        }
    }
    
    private func shouldLoadMore(for item: Item) -> Bool {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return false
        }
        return index >= items.count - threshold
    }
    
    private func loadMoreIfNeeded() async {
        guard !isLoadingMore else { return }
        
        isLoadingMore = true
        await loadMore()
        isLoadingMore = false
    }
}

// MARK: - Pagination Manager

/// 페이지네이션 매니저
@MainActor
open class PaginationManager<Item: Sendable>: ObservableObject {
    @Published public private(set) var items: [Item] = []
    @Published public private(set) var state: PaginationState
    
    private let pageSize: Int
    private let loadPage: (Int) async throws -> [Item]
    
    public init(
        pageSize: Int = 20,
        loadPage: @escaping (Int) async throws -> [Item]
    ) {
        self.pageSize = pageSize
        self.loadPage = loadPage
        self.state = PaginationState()
    }
    
    /// 첫 페이지 로드
    public func loadInitial() async {
        guard !state.isLoading else { return }
        
        state.isLoading = true
        
        do {
            let newItems = try await loadPage(0)
            items = newItems
            state.currentPage = 0
            state.hasMorePages = newItems.count >= pageSize
        } catch {
            print("Failed to load initial page: \(error)")
        }
        
        state.isLoading = false
    }
    
    /// 다음 페이지 로드
    public func loadNext() async {
        guard !state.isLoading, state.hasMorePages else { return }
        
        state.isLoading = true
        let nextPage = state.currentPage + 1
        
        do {
            let newItems = try await loadPage(nextPage)
            items.append(contentsOf: newItems)
            state.currentPage = nextPage
            state.hasMorePages = newItems.count >= pageSize
        } catch {
            print("Failed to load page \(nextPage): \(error)")
        }
        
        state.isLoading = false
    }
    
    /// 새로고침
    public func refresh() async {
        state = PaginationState()
        await loadInitial()
    }
}

