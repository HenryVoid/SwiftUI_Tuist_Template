import XCTest
import Combine
import Dependencies
import LinkNavigator

@testable import Auth

final class SignupETCUnitTest: XCTestCase {
    struct AppDependency: DependencyType {}
    var cancellable: Set<AnyCancellable> = []
    var state: SignupETCModel.State!
    var intent: SignupETCIntent!
    
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
        
        intent.navigator = navigator
    }
    
    override func tearDown() {
        state = nil
        intent = nil
        super.tearDown()
    }
    
    override func tearDownWithError() throws {
        self.cancellable = []
    }
    
    func test_이름입력_성공() {
        // Given
        let name = "우기"
        let errorTest = ""
        
        // When
        intent.send(action: .changeName(name))
        intent.send(action: .onSubmitName)
        
        // Then
        intent.$state
            .sink { state in
                XCTAssert(state.name == name)
                XCTAssertTrue(state.name.isValidName())
                XCTAssertEqual(state.nameBottomText, errorTest)
                XCTAssert(state.isShowBirthDayField == true)
                XCTAssert(state.isShowNicknameField == false)
                XCTAssert(state.isEnabledNextBtn == false)
            }
            .store(in: &cancellable)
    }
    
    func test_이름입력_실패() {
        // Given
        let name = " 123우기"
        let errorTest = "올바른 이름을 입력해주세요"
        
        // When
        intent.send(action: .changeName(name))
        intent.send(action: .onSubmitName)
        
        // Then
        intent.$state
            .sink { state in
                XCTAssertEqual(state.name, name)
                XCTAssertFalse(state.name.isValidName())
                XCTAssertEqual(state.nameBottomText, errorTest)
                XCTAssertTrue(state.isShowBirthDayField)
                XCTAssertFalse(state.isShowNicknameField)
                XCTAssertFalse(state.isEnabledNextBtn)
            }
            .store(in: &cancellable)
    }
    
    func test_생일입력() {
        // Given
        let name = "우기"
        let birthDay = Date()
        
        // When
        intent.send(action: .changeName(name))
        intent.send(action: .onSubmitName)
        intent.send(action: .changeBirthDay(birthDay))
        intent.send(action: .onSubmitBirthDay)
        
        // Then
        intent.$state
            .sink { state in
                XCTAssertEqual(state.birthDay, birthDay)
                XCTAssertTrue(state.isShowBirthDayField)
                XCTAssertTrue(state.isShowNicknameField)
                XCTAssertFalse(state.isEnabledNextBtn)
            }
            .store(in: &cancellable)
    }
    
    func test_닉네임입력_성공() {
        // Given
        let name = "우기"
        let birthDay = Date()
        let nickname = "우기"
        
        let errorText = ""
        
        // When
        intent.send(action: .changeName(name))
        intent.send(action: .onSubmitName)
        intent.send(action: .changeBirthDay(birthDay))
        intent.send(action: .onSubmitBirthDay)
        intent.send(action: .changeNickname(nickname))
        intent.send(action: .onSubmitNickname)
        
        // Then
        intent.$state
            .sink { state in
                XCTAssertEqual(state.nickname, nickname)
                XCTAssertTrue(state.nickname.isValidNickname())
                XCTAssertEqual(state.nickNameBottomText, errorText)
                XCTAssertTrue(state.isShowBirthDayField)
                XCTAssertTrue(state.isShowNicknameField)
                XCTAssertTrue(state.isEnabledNextBtn)
            }
            .store(in: &cancellable)
    }
    
    func test_닉네임입력_실패() {
        // Given
        let name = "우기"
        let birthDay = Date()
        let nickname = " 우기"
        
        let errorText = "올바른 별명을 입력해주세요"
        
        // When
        intent.send(action: .changeName(name))
        intent.send(action: .onSubmitName)
        intent.send(action: .changeBirthDay(birthDay))
        intent.send(action: .onSubmitBirthDay)
        intent.send(action: .changeNickname(nickname))
        intent.send(action: .onSubmitNickname)
        
        // Then
        intent.$state
            .sink { state in
                XCTAssertEqual(state.nickname, nickname)
                XCTAssertFalse(state.nickname.isValidNickname())
                XCTAssertEqual(state.nickNameBottomText, errorText)
                XCTAssertTrue(state.isShowBirthDayField)
                XCTAssertTrue(state.isShowNicknameField)
                XCTAssertTrue(state.isEnabledNextBtn)
            }
            .store(in: &cancellable)
    }
    
    func test_다음버튼Tap_이름유효성검사_실패() {
        // Given
        let name = " 우기"
        let birthDay = Date()
        let nickname = "우기"
        
        let nameErrorText = "올바른 이름을 입력해주세요"
        
        // When
        intent.send(action: .changeName(name))
        intent.send(action: .onSubmitName)
        intent.send(action: .changeBirthDay(birthDay))
        intent.send(action: .onSubmitBirthDay)
        intent.send(action: .changeNickname(nickname))
        intent.send(action: .onSubmitNickname)
        intent.send(action: .nextBtnDidTap)
        
        // Then
        intent.$state
            .sink { state in
                XCTAssertEqual(state.nameBottomText, nameErrorText)
            }
            .store(in: &cancellable)
    }
    
    func test_다음버튼Tap_별명유효성검사_실패() {
        // Given
        let name = "우기"
        let birthDay = Date()
        let nickname = " 우기"
        
        let nickNameErrorText = "올바른 별명을 입력해주세요"
        
        // When
        intent.send(action: .changeName(name))
        intent.send(action: .onSubmitName)
        intent.send(action: .changeBirthDay(birthDay))
        intent.send(action: .onSubmitBirthDay)
        intent.send(action: .changeNickname(nickname))
        intent.send(action: .onSubmitNickname)
        intent.send(action: .nextBtnDidTap)
        
        // Then
        intent.$state
            .sink { state in
                XCTAssertEqual(state.nickNameBottomText, nickNameErrorText)
            }
            .store(in: &cancellable)
    }
}
