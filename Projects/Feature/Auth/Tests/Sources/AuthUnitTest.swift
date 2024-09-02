import XCTest
import Combine
import Dependencies
import LinkNavigator

@testable import Auth

final class AuthUnitTest: XCTestCase {
    struct AppDependency: DependencyType {}
    var cancellable: Set<AnyCancellable> = []
    var state: AuthModel.State!
    var intent: AuthIntent!
    
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

    func test_이메일btn활성화() {
        // Given
        let email = "0"
        
        // When
        intent.send(action: .changeEmail(email))
        
        // Then
        intent.$state
            .sink { state in
                XCTAssertEqual(state.email, email)
                XCTAssertTrue(state.isEnabledEmailBtn)
            }
            .store(in: &cancellable)
    }
    
    func test_이메일유효성검사() {
        // Given
        let email = "chicazic@gmail.com"
        
        // When
        intent.send(action: .changeEmail(email))
        
        // Then
        intent.$state
            .sink { state in
                XCTAssertEqual(state.email, email)
                XCTAssertTrue(state.isEnabledEmailBtn)
                XCTAssertTrue(state.email.isValidEmail())
            }
            .store(in: &cancellable)
    }
    
    func test_이메일유효성검사_실패() {
        // Given
        state = .init(email: "chicazic@")
        
        let bottomText = "올바른 이메일 형식으로 입력해주세요."
        
        // When
        intent.send(action: .emailBtnDidTap)
        
        // Then
        intent.$state
            .sink { state in
                XCTAssertEqual(state.bottomText, bottomText)
            }
            .store(in: &cancellable)
    }
}
