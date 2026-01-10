import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import GitHubService
import CacheKit
import DesignSystem
import AnalyticsKit
import Logger

public final class HomeViewController: UIViewController, View {
    public var disposeBag = DisposeBag()
    
    // UI Components
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search repositories..."
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: "RepositoryCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        return tableView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Search GitHub Repositories\n(ReactorKit)"
        label.textAlignment = .center
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private let refreshControl = UIRefreshControl()
    
    public init(reactor: HomeReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "GitHub Search (Reactor)"
        view.backgroundColor = .systemBackground
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(activityIndicator)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        tableView.refreshControl = refreshControl
    }
    
    public func bind(reactor: HomeReactor) {
        // Action
        searchBar.rx.text.orEmpty
            .distinctUntilChanged()
            .map { HomeReactor.Action.updateSearchQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked
            .map { HomeReactor.Action.search }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map { HomeReactor.Action.refresh }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .filter { [weak self] offset in
                guard let self = self,
                      !reactor.currentState.isLoading,
                      reactor.currentState.hasMorePages else {
                    return false
                }
                
                let contentHeight = self.tableView.contentSize.height
                let scrollViewHeight = self.tableView.frame.size.height
                let threshold = contentHeight - scrollViewHeight - 200
                
                return offset.y > threshold
            }
            .map { _ in HomeReactor.Action.loadMore }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        reactor.state.map { $0.repositories }
            .bind(to: tableView.rx.items(cellIdentifier: "RepositoryCell", cellType: RepositoryCell.self)) { _, repository, cell in
                cell.configure(with: repository)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading && $0.repositories.isEmpty }
            .distinctUntilChanged()
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.repositories.isEmpty && !$0.isLoading }
            .distinctUntilChanged()
            .bind(to: emptyLabel.rx.isVisible)
            .disposed(by: disposeBag)
        
        reactor.state.map { !$0.isLoading }
            .bind(to: refreshControl.rx.isRefreshing.mapObserver { !$0 })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.error }
            .compactMap { $0 }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] error in
                self?.showError(error)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(GitHubRepository.self)
            .subscribe(onNext: { repository in
                Log.advanced(
                    "Reactor: Repository tapped",
                    level: .info,
                    metadata: ["repo": repository.fullName]
                )
                
                AnalyticsManager.shared.logEvent(AnalyticsEvent(
                    name: "repository_tapped_reactor",
                    parameters: ["repo_name": repository.fullName]
                ))
                
                // Navigate to detail (implementation omitted for brevity)
            })
            .disposed(by: disposeBag)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Repository Cell

class RepositoryCell: UITableViewCell {
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray5
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2
        return label
    }()
    
    private let starsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    private var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        disposeBag = DisposeBag()
    }
    
    private func setupUI() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(ownerLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(starsLabel)
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        ownerLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        starsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            ownerLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            ownerLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            ownerLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: ownerLabel.bottomAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            starsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            starsLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            starsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with repository: GitHubRepository) {
        nameLabel.text = repository.name
        ownerLabel.text = repository.owner.login
        descriptionLabel.text = repository.description ?? "No description"
        starsLabel.text = "⭐ \(repository.stargazersCount) 🍴 \(repository.forksCount)"
        
        Task {
            do {
                let image = try await ImageCache.shared.loadImage(from: repository.owner.avatarUrl)
                await MainActor.run {
                    self.avatarImageView.image = image
                }
            } catch {}
        }
    }
}

// MARK: - Rx Extensions

extension Reactive where Base: UILabel {
    var isVisible: Binder<Bool> {
        return Binder(base) { label, isVisible in
            label.isHidden = !isVisible
        }
    }
}

