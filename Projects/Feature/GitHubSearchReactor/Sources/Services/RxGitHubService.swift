import Foundation
import RxSwift
import GitHubServiceInterface
import GitHubService

/// GitHub Service for ReactorKit
open class RxGitHubService {
    private let service: any GitHubServiceProtocol

    public init(service: any GitHubServiceProtocol = GitHubService()) {
        self.service = service
    }

    open func searchRepositories(query: String, page: Int) -> Single<[GitHubRepository]> {
        return Single.create { [service] single in
            Task {
                do {
                    let response = try await service.searchRepositories(query: query, page: page)
                    single(.success(response.items))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    open func getRepository(owner: String, repo: String) -> Single<GitHubRepository> {
        return Single.create { [service] single in
            Task {
                do {
                    let repository = try await service.getRepository(owner: owner, repo: repo)
                    single(.success(repository))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
