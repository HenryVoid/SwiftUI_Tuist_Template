import XCTest
import Combine
import Dependencies
import LinkNavigator

@testable import Auth

final class SignupPhoneAuthUnitTest: XCTestCase {
    struct AppDependency: DependencyType {}
    var cancellable: Set<AnyCancellable> = []
    var state: SignupPhoneAuthModel.State!
    var intent: SignupPhoneAuthIntent!
    
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
    
    func test_폰번호변경_유효성검사() {
        // Given
        let phoneNumber = "01012345678"
        
        // When
        intent.send(action: .changePhoneNumber(phoneNumber))
        
        // Then
        intent.$state
            .sink { state in
                XCTAssertEqual(state.phoneNumber, phoneNumber)
                XCTAssertTrue(state.phoneNumber.isValidPhone())
            }
            .store(in: &cancellable)
    }
    
    func test_전송버튼탭_인증코드필드노출() {
        // Given
        let phoneNumber = "01056705622"
        
        // When
        intent.send(action: .changePhoneNumber(phoneNumber))
        intent.send(action: .sendAuthCodeBtnDidTap)
        
        // Then
        intent.$state
            .sink { state in
                XCTAssertTrue(state.isShowAuthCodeField)
            }
            .store(in: &cancellable)
    }
}
