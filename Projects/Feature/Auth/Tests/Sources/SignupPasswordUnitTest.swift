import XCTest
import Combine
import Dependencies
import LinkNavigator

@testable import Auth

final class SignupPasswordUnitTest: XCTestCase {
    struct AppDependency: DependencyType {}
    var cancellable: Set<AnyCancellable> = []
    var state: SignupPasswordModel.State!
    var intent: SignupPasswordIntent!
    
    override func setUp() {
        self.intializeData()
        super.setUp()
    }
    
    private func intializeData() {
        state = .init()
        let navigator: SingleLinkNavigator = .init(
            routeBuilderItemList: [SignupPasswordRouter.generate()],
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

    func test_다음btn활성화() {
        // Given
        let pw = "1"
        let pwAgain = "1"
        
        // When
        intent.send(action: .changePassword(pw))
        intent.send(action: .changePasswordAgain(pwAgain))
        
        // Then
        intent.$state
            .sink { state in
                XCTAssertEqual(state.password, pw)
                XCTAssertEqual(state.passwordAgain, pwAgain)
                XCTAssertTrue(state.isEnabledNextBtn)
            }
            .store(in: &cancellable)
    }
    
    func test_다음btn클릭() {
        // Given
        let pw = "qwerqwerR1!"
        let pwAgain = "qwerqwerR1!"
        
        // When
        intent.send(action: .changePassword(pw))
        intent.send(action: .changePasswordAgain(pwAgain))
        intent.send(action: .nextBtnDidTap)
        
        // Then
        intent.$state
            .sink { state in
                XCTAssertTrue(state.password.isValidPassword())
                XCTAssertTrue(state.password == state.passwordAgain)
            }
            .store(in: &cancellable)
    }
    
    func test_다음btn클릭_실패() {
        // Given
        let pw = "1q2w3e!"
        let pwAgain = "1q2w3e"
        
        let pwBottomText = "영문 대소문자, 숫자, 특수문자 포함 8자 이상"
        let pwAgainBottomText = "비밀번호가 일치하지 않습니다."
        
        // When
        intent.send(action: .changePassword(pw))
        intent.send(action: .changePasswordAgain(pwAgain))
        intent.send(action: .nextBtnDidTap)
        
        // Then
        intent.$state
            .sink { state in
                XCTAssertFalse(state.password.isValidPassword(), state.password)
                XCTAssertFalse(state.password == state.passwordAgain)
                
                XCTAssertEqual(state.pwBottomText, pwBottomText)
                XCTAssertEqual(state.pwAgainBottomText, pwAgainBottomText)
            }
            .store(in: &cancellable)
    }
}
