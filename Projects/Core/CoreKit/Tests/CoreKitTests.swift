import XCTest
import SwiftUI
@testable import CoreKit

final class CoreKitTests: XCTestCase {
    func testPaginationStateDefaults() {
        let state = PaginationState()

        XCTAssertEqual(state.currentPage, 0)
        XCTAssertTrue(state.hasMorePages)
        XCTAssertFalse(state.isLoading)
    }

    @MainActor
    func testBasicRouterNavigation() {
        enum TestRoute: String, Route {
            case detail

            var path: String { rawValue }
        }

        let router = BasicRouter<TestRoute>()

        XCTAssertTrue(router.path.isEmpty)

        router.navigate(to: .detail)
        XCTAssertEqual(router.path.count, 1)

        router.pop()
        XCTAssertTrue(router.path.isEmpty)

        router.navigate(to: .detail)
        router.popToRoot()
        XCTAssertTrue(router.path.isEmpty)
    }

    func testCoordinatorAddsAndRemovesChild() {
        final class TestCoordinator: Coordinator {
            var childCoordinators: [any Coordinator] = []
            private(set) var didStart = false

            func start() {
                didStart = true
            }
        }

        let parent = TestCoordinator()
        let child = TestCoordinator()

        parent.coordinate(to: child)

        XCTAssertEqual(parent.childCoordinators.count, 1)
        XCTAssertTrue(child.didStart)

        parent.removeChild(child)
        XCTAssertTrue(parent.childCoordinators.isEmpty)
    }
}
