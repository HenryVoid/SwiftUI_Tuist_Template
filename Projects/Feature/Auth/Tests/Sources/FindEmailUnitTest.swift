import XCTest
import Combine
import Dependencies
import LinkNavigator

@testable import Auth

final class FindEmailUnitTest: XCTestCase {
    struct AppDependency: DependencyType {}
    var cancellable: Set<AnyCancellable> = []
    var state: FindEmailModel.State!
    var intent: FindEmailIntent!
    
    override func setUp() {
        self.intializeData()
        super.setUp()
    }
    
    private func intializeData() {
        state = .init()
        let navigator: SingleLinkNavigator = .init(
            routeBuilderItemList: [SignupETCRouter.generate()],
            dependency: AppDependency()
        )
        intent = .init(initialState: state, navigator: navigator)
    }
    
    override func tearDown() {
        state = nil
        intent = nil
        super.tearDown()
    }
    
    override func tearDownWithError() throws {
        self.cancellable = []
    }
    
    func test_폰번호변경() {
        // Given
        let phoneNumber = "01056705622"
        
        // When
        intent.send(action: .changePhoneNumber(phoneNumber))
        intent.send(action: .onSubmitPhoneNumber)
        
        // Then
        intent.$state
            .sink { state in
                XCTAssertEqual(state.phoneNumber, phoneNumber)
                XCTAssertTrue(state.isEnabledFindEmailBtn)
            }
            .store(in: &cancellable)
    }
}
