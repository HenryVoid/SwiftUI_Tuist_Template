import Foundation
import RxSwift
import GitHubService

/// GitHub Service for ReactorKit
public final class RxGitHubService {
    private let service: GitHubService
    
    public init() {
        self.service = GitHubService()
    }
    
    public func searchRepositories(query: String, page: Int) -> Single<[GitHubRepository]> {
        return Single.create { single in
            Task {
                do {
                    let response = try await self.service.searchRepositories(query: query, page: page)
                    single(.success(response.items))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    public func getRepository(owner: String, repo: String) -> Single<GitHubRepository> {
        return Single.create { single in
            Task {
                do {
                    let repository = try await self.service.getRepository(owner: owner, repo: repo)
                    single(.success(repository))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}

