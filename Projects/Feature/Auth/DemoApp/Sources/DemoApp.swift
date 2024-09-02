import SwiftUI
import Auth
import KakaoSDKCommon
import KakaoSDKAuth
import LinkNavigator
import Entity
import DesignSystem
import Base
import NaverThirdPartyLogin

@main
struct AuthApp: App {
    var navigator: SingleLinkNavigator = .init(
        routeBuilderItemList: AuthRouterGroup().routers,
        dependency: AuthDependency()
    )
    init() {
        KakaoSDK.initSDK(appKey: Env.KAKAO_APP_KEY)
        DesignSystemFontFamily.registerAllCustomFonts()
        
        initNaver()
    }
    
    var body: some Scene {
        WindowGroup {
            LinkNavigationView(
                linkNavigator: navigator,
                item: .init(path: Screen.Path.SignupPhoneAuth.rawValue)
            )
            .onOpenURL { url in
                if (AuthApi.isKakaoTalkLoginUrl(url)) {
                    _ = AuthController.handleOpenUrl(url: url)
                }
                
                NaverThirdPartyLoginConnection
                    .getSharedInstance()
                    .receiveAccessToken(url)
            }
        }
    }
    
    
    private func initNaver() {
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        // 네이버 앱으로 로그인 허용
        instance?.isNaverAppOauthEnable = true
        // 브라우저 로그인 허용
        instance?.isInAppOauthEnable = true
        
        // 네이버 로그인 세로모드 고정
        instance?.setOnlyPortraitSupportInIphone(true)
        
        // NaverThirdPartyConstantsForApp.h에 선언한 상수 등록
        instance?.serviceUrlScheme = "com.mood.Mood"
        instance?.consumerKey = Env.NAVER_CLIENT_ID
        instance?.consumerSecret = Env.NAVER_CLIENT_SECRET
        instance?.appName = "Mood"
    }
}
