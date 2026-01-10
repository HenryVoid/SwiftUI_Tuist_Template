#if canImport(UIKit)
import UIKit

// MARK: - UICollectionView Prefetching

/// UICollectionView 페이지네이션 헬퍼
open class CollectionViewPaginationHelper: NSObject, UICollectionViewDataSourcePrefetching {
    private let threshold: Int
    private let loadMore: () async -> Void
    private var isLoading = false
    
    public init(threshold: Int = 5, loadMore: @escaping () async -> Void) {
        self.threshold = threshold
        self.loadMore = loadMore
        super.init()
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let maxIndex = indexPaths.map({ $0.item }).max() else { return }
        
        let totalItems = collectionView.numberOfItems(inSection: 0)
        
        // threshold에 도달하면 다음 페이지 로드
        if maxIndex >= totalItems - threshold, !isLoading {
            Task { @MainActor in
                isLoading = true
                await loadMore()
                isLoading = false
            }
        }
    }
}

// MARK: - DiffableDataSource 헬퍼

/// Diffable Data Source 페이지네이션 매니저
@MainActor
open class DiffableDataSourceManager<Section: Hashable & Sendable, Item: Hashable & Sendable> {
    public typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    public typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private let dataSource: DataSource
    private let section: Section
    
    public init(dataSource: DataSource, section: Section) {
        self.dataSource = dataSource
        self.section = section
    }
    
    /// 초기 데이터 적용
    public func apply(items: [Item], animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([section])
        snapshot.appendItems(items, toSection: section)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    /// 아이템 추가 (페이지네이션)
    public func appendItems(_ items: [Item], animatingDifferences: Bool = true) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(items, toSection: section)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    /// 데이터 새로고침
    public func refresh(items: [Item], animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([section])
        snapshot.appendItems(items, toSection: section)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

#endif

