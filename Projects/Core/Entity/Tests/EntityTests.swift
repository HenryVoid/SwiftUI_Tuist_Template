import XCTest
import SwiftUI
@testable import Entity
import GitHubServiceInterface

final class EntityTests: XCTestCase {
    func testUICheckBoxStateCasesAreAvailable() {
        let states: [Entity.UI.CheckBoxState] = [
            .checked,
            .unchecked,
            .partial,
            .indeterminate
        ]

        XCTAssertEqual(states.count, 4)
    }

    func testUIBottomTextStoresValues() {
        let bottomText = Entity.UI.BottomText(text: "Helper", textColor: .red)

        XCTAssertEqual(bottomText.text, "Helper")
    }

    func testRepositoryEntityAliasesGitHubRepository() {
        let owner = Owner(
            login: "owner",
            id: 1,
            avatarUrl: "https://example.com/avatar.png",
            htmlUrl: "https://github.com/owner"
        )
        let repository = RepositoryEntity(
            id: 100,
            name: "repo",
            fullName: "owner/repo",
            owner: owner,
            description: "Template repository",
            stargazersCount: 10,
            forksCount: 2,
            language: "Swift",
            htmlUrl: "https://github.com/owner/repo",
            createdAt: "2026-01-01T00:00:00Z",
            updatedAt: "2026-01-02T00:00:00Z",
            watchersCount: 3,
            openIssuesCount: 1
        )

        XCTAssertEqual(repository.fullName, "owner/repo")
        XCTAssertEqual(repository.owner.login, "owner")
    }
}
