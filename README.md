# SwiftUI Tuist Template

> 🚀 프로덕션 레벨의 iOS 프로젝트 템플릿 - Swift 6.0, iOS 18+, UIKit/SwiftUI 하이브리드 지원

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-18.0+-blue.svg)](https://www.apple.com/ios)
[![Tuist](https://img.shields.io/badge/Tuist-4.33.0-green.svg)](https://tuist.io)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📋 목차

- [특징](#-특징)
- [요구사항](#-요구사항)
- [시작하기](#-시작하기)
- [아키텍처](#-아키텍처)
- [모듈 구조](#-모듈-구조)
- [Core 모듈](#-core-모듈)
- [네비게이션 패턴](#-네비게이션-패턴)
- [의존성 주입](#-의존성-주입)
- [무한스크롤 최적화](#-무한스크롤-최적화)
- [테스트](#-테스트)
- [Tuist Template 사용법](#-tuist-template-사용법)
- [xcconfig 활용](#-xcconfig-활용)
- [트러블슈팅](#-트러블슈팅)

## ✨ 특징

### 🏗️ 모던 아키텍처
- **MVVM + Clean Architecture**: 레이어 분리 명확, 기업 환경 검증됨
- **VIPER**: 고도의 모듈화, 대규모 프로젝트 적합
- **Coordinator/Router Pattern**: 네비게이션 로직 분리

### 📦 Core 모듈
- **NetworkKit**: URLSession + async/await, Retry, Interceptor
- **CacheKit**: LRU 알고리즘, 메모리/디스크 하이브리드 캐싱
- **Logger**: 구조화된 로깅, 파일 저장, 원격 전송 지원
- **AnalyticsKit**: 이벤트 큐잉, 배치 전송, 다중 제공자 (Firebase/Amplitude)
- **DIContainer**: Manual DI, 컴파일 타임 안정성

### 🎨 UIKit + SwiftUI 하이브리드
- UIViewController ↔ SwiftUI View 양방향 전환
- SwiftUI Preview로 UIKit 컴포넌트 미리보기
- UIHostingController 커스터마이징

### ⚡ 성능 최적화
- **무한스크롤**: LazyVStack + Pagination, UICollectionView Prefetching
- **이미지 캐싱**: NukeUI 통합, 메모리 최적화
- **메모리 관리**: MemoryOptimizer, 메모리 경고 자동 대응

### 🧪 완벽한 테스트 환경
- NetworkKit 테스트 (Mock URLProtocol)
- CacheKit 테스트 (LRU 알고리즘, 만료 정책)
- Logger 테스트 (레벨별 필터링)
- Analytics 테스트 (이벤트 큐잉, 배치 전송)

### 🔧 개발 편의성
- Tuist 4.33.0 기반 모듈화
- xcconfig로 환경별 설정 관리
- Scaffold 템플릿으로 Feature 자동 생성
- Swift 6.0 Concurrency 완전 지원

## 📱 요구사항

- Xcode 16.0+
- Swift 6.0+
- iOS 18.0+
- Tuist 4.33.0+

## 🚀 시작하기

### 1. Tuist 설치

```bash
curl -Ls https://install.tuist.io | bash
```

### 2. 프로젝트 클론

```bash
git clone https://github.com/your-repo/SwiftUI_Tuist_Template.git
cd SwiftUI_Tuist_Template
```

### 3. Dependency 설치

```bash
tuist install
```

### 4. xcconfig 설정

```bash
# API 키 등 환경 변수를 XCConfig/Shared.xcconfig에 설정
open XCConfig/Shared.xcconfig
```

### 5. 프로젝트 생성

```bash
tuist generate
```

### 6. Xcode 실행

```bash
open MyApp.xcworkspace
```

## 🏛️ 아키텍처

### MVVM + Clean Architecture

```
┌─────────────────────────────────────┐
│   Presentation Layer (SwiftUI)      │
│   - View                             │
│   - ViewModel                        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Domain Layer                       │
│   - UseCase                          │
│   - Repository Protocol              │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Data Layer                         │
│   - Repository Implementation        │
│   - NetworkKit, CacheKit             │
└──────────────────────────────────────┘
```

**장점**:
- 레이어 분리 명확
- 테스트 용이
- UIKit/SwiftUI 모두 호환

**사용 시기**:
- 중소규모 프로젝트
- 빠른 개발 속도 필요
- 레이어 분리를 원할 때

### VIPER Architecture

```
View ←→ Presenter ←→ Interactor ←→ Entity
         ↓
       Router
```

**장점**:
- 극도의 모듈화
- 명확한 책임 분리
- 대규모 팀 협업 용이

**사용 시기**:
- 대규모 프로젝트
- 여러 팀이 협업
- 장기 유지보수 계획

## 📦 모듈 구조

```
Projects/
├── Core/
│   ├── NetworkKit       # 네트워크 레이어
│   ├── CacheKit         # 캐싱 시스템
│   ├── Logger           # 로깅 시스템
│   ├── AnalyticsKit     # Analytics 추상화
│   ├── Utility          # DI, UserDefaults, Keychain
│   └── CoreKit          # 공통 프로토콜 및 유틸리티
├── Feature/
│   ├── Auth             # 인증 Feature
│   ├── Main             # 메인 Feature
│   └── Base             # 베이스 Feature
└── DesignSystem         # 디자인 시스템
```

## 🛠️ Core 모듈

### NetworkKit

URLSession 기반 네트워크 레이어:

```swift
import NetworkKit

// 1. Request 정의
struct GetUserRequest: NetworkRequest {
    typealias Response = User
    
    let baseURL = "https://api.example.com"
    let path = "/users/\(userId)"
    let method: HTTPMethod = .get
    
    let userId: String
}

// 2. 네트워크 서비스 사용
let service = NetworkService()
let request = GetUserRequest(userId: "123")
let user = try await service.request(request)

// 3. Interceptor로 인증 추가
let authInterceptor = AuthInterceptor { 
    return await getAccessToken()
}
let authenticatedService = NetworkService(interceptor: authInterceptor)
```

**특징**:
- ✅ async/await 지원
- ✅ 자동 Retry (지수 백오프)
- ✅ Request/Response Interceptor
- ✅ Multipart 업로드 지원

### CacheKit

다층 캐싱 시스템:

```swift
import CacheKit

// 1. 메모리 캐시
let memoryCache = MemoryCache<String, Data>()
try await memoryCache.set(data, forKey: "key", expiration: 3600)
let cached = try await memoryCache.get("key")

// 2. LRU 캐시 (용량 제한)
let lruCache = LRUCacheManager<String, String>(capacity: 100)
try await lruCache.set("value", forKey: "key", expiration: nil)

// 3. 하이브리드 캐시 (메모리 + 디스크)
let cache = try HybridCache<String, User>()
try await cache.set(user, forKey: "user_123", expiration: nil)

// 4. 이미지 캐시
let imageCache = ImageCache.shared
let image = try await imageCache.loadImage(from: "https://example.com/image.jpg")
```

**특징**:
- ✅ LRU 알고리즘
- ✅ 만료 시간 설정
- ✅ 메모리/디스크 하이브리드
- ✅ 이미지 자동 캐싱

### Logger

구조화된 로깅:

```swift
import Logger

// 1. 기본 로깅
Log.debug("Debug message")
Log.info("Info message")
Log.error("Error occurred")
Log.network("API called")

// 2. 고급 로깅 (파일 저장 + 메타데이터)
Log.advanced(
    "User logged in",
    level: .info,
    category: "Authentication",
    metadata: ["userId": "123", "method": "OAuth"]
)

// 3. 로그 조회 및 전송
let logger = AdvancedLogger.shared
let logs = try await logger.fetchLogs(limit: 100)
try await logger.flushLogs() // 원격 서버로 전송
```

**특징**:
- ✅ OSLog 통합
- ✅ 파일 저장 (로테이션)
- ✅ 원격 전송 지원
- ✅ 레벨별 필터링

### AnalyticsKit

다중 Analytics 제공자:

```swift
import AnalyticsKit

// 1. Analytics 설정
let manager = AnalyticsManager.shared
await manager.addProvider(FirebaseAnalyticsAdapter())
await manager.addProvider(AmplitudeAnalyticsAdapter())

// 2. 이벤트 로깅
manager.logEvent(AnalyticsEvent(
    name: "purchase_completed",
    parameters: ["amount": 99.99, "currency": "USD"]
))

// 3. 편의 메서드
await manager.logScreenView(screenName: "HomeScreen")
await manager.logButtonTap(buttonName: "SubmitButton")
await manager.logError(error: someError, context: "Checkout")

// 4. 수동 플러시
await manager.flush()
```

**특징**:
- ✅ 이벤트 큐잉
- ✅ 배치 전송
- ✅ 다중 제공자 지원
- ✅ 자동 플러시

## 🧭 네비게이션 패턴

### 1. Coordinator Pattern (UIKit 권장)

```swift
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

class AppCoordinator: UIKitCoordinator {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    
    func start() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        coordinate(to: loginCoordinator)
    }
}
```

**장점**:
- 뷰 로직과 네비게이션 로직 완전 분리
- 딥링크 처리 용이
- 테스트 가능성 향상

### 2. Router Pattern (SwiftUI 권장)

```swift
enum AppRoute: Route {
    case home
    case profile(userId: String)
    case settings
    
    var path: String {
        switch self {
        case .home: return "/home"
        case .profile(let id): return "/profile/\(id)"
        case .settings: return "/settings"
        }
    }
}

class AppRouter: BasicRouter<AppRoute> {
    // 자동으로 NavigationPath 관리
}
```

**장점**:
- SwiftUI NavigationStack 자연스러운 통합
- URL 기반 라우팅
- 딥링크 친화적

## 💉 의존성 주입

### Manual DI Container

```swift
import Utility

// 1. 서비스 등록
let container = ManualDIContainer.shared

container.registerSingleton(NetworkServiceProtocol.self) {
    NetworkService()
}

container.register(CacheServiceProtocol.self) {
    HybridCache()
}

// 2. 서비스 해결
let networkService = container.resolve(NetworkServiceProtocol.self)!

// 3. Property Wrapper
class ViewModel {
    @Injected var networkService: NetworkServiceProtocol
    @Injected var cacheService: CacheServiceProtocol
}
```

**장점**:
- 컴파일 타임 안정성
- 외부 의존성 없음
- 러닝 커브 낮음

## 📜 무한스크롤 최적화

### SwiftUI - PaginatedListView

```swift
import CoreKit

struct MovieListView: View {
    @StateObject var paginationManager = PaginationManager<Movie>(
        pageSize: 20,
        loadPage: { page in
            try await MovieAPI.fetchMovies(page: page)
        }
    )
    
    var body: some View {
        PaginatedListView(
            items: paginationManager.items,
            threshold: 3,
            loadMore: {
                await paginationManager.loadNext()
            }
        ) { movie in
            MovieRow(movie: movie)
        }
        .task {
            await paginationManager.loadInitial()
        }
    }
}
```

### UIKit - Prefetching

```swift
import CoreKit

class MovieListViewController: UIViewController {
    let paginationHelper = CollectionViewPaginationHelper(threshold: 5) {
        await self.loadNextPage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.prefetchDataSource = paginationHelper
    }
}
```

**성능 최적화**:
- ✅ LazyVStack 자동 재사용
- ✅ Prefetching으로 미리 로드
- ✅ DiffableDataSource 활용
- ✅ 메모리 효율적 관리

## 🧪 테스트

### 네트워크 테스트

```swift
final class NetworkKitTests: XCTestCase {
    func testSuccessfulRequest() async throws {
        // Mock URLProtocol 사용
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, ...)
            let data = """{"message": "Success"}""".data(using: .utf8)
            return (response, data)
        }
        
        let response = try await networkService.request(MockRequest())
        XCTAssertEqual(response.message, "Success")
    }
}
```

### 캐시 테스트

```swift
func testLRUCacheEviction() async throws {
    let cache = LRUCacheManager<String, String>(capacity: 2)
    
    try await cache.set("value1", forKey: "key1", expiration: nil)
    try await cache.set("value2", forKey: "key2", expiration: nil)
    try await cache.set("value3", forKey: "key3", expiration: nil)
    
    // key1이 제거되어야 함
    XCTAssertThrowsError(try await cache.get("key1"))
}
```

## 📝 Tuist Template 사용법

### Feature 생성

```bash
# 새 Feature 모듈 생성
tuist scaffold feature --name Shopping

# 생성 후 Module.swift에 추가
# Plugins/MyAppPlugIn/ProjectDescriptionHelpers/Module/Module.swift
public extension Module {
    enum Feature: String, CaseIterable {
        case Auth
        case Main
        case Base
        case Shopping  // ← 추가
    }
}
```

### Core 모듈 생성

```bash
# 새 Core 모듈 생성
tuist scaffold core --name PaymentKit

# Module.swift에 추가
public extension Module {
    enum Core: String, CaseIterable {
        case NetworkKit
        case CacheKit
        // ... 
        case PaymentKit  // ← 추가
    }
}
```

### 프로젝트 재생성

```bash
# 변경사항 반영
tuist clean
tuist generate

# 의존성 그래프 확인
tuist graph
tuist graph -t  # 테스트 타겟 제외
tuist graph -d  # 외부 라이브러리 제외
```

## ⚙️ xcconfig 활용

### Shared.xcconfig

```
// API Keys
KAKAO_APP_KEY = your_kakao_key
NAVER_CLIENT_ID = your_naver_id
BASE_URL = https://api.production.com

// Swift Settings
SWIFT_VERSION = 6.0
SWIFT_STRICT_CONCURRENCY = complete
IPHONEOS_DEPLOYMENT_TARGET = 18.0
```

### Debug.xcconfig

```
#include "./Shared.xcconfig"

// Debug-specific
SWIFT_OPTIMIZATION_LEVEL = -Onone
OTHER_SWIFT_FLAGS = -D DEBUG -enable-actor-data-race-checks
```

### Release.xcconfig

```
#include "./Shared.xcconfig"

// Release-specific
SWIFT_OPTIMIZATION_LEVEL = -O
SWIFT_COMPILATION_MODE = wholemodule
DEAD_CODE_STRIPPING = YES
```

## 🔍 트러블슈팅

### Tuist 관련

**Q: `tuist generate` 실패**
```bash
# 캐시 정리 후 재시도
tuist clean
rm -rf .build
tuist install
tuist generate
```

**Q: 의존성 문제**
```bash
# Package.swift 확인
tuist edit

# 의존성 재설치
tuist install --force
```

### Concurrency 관련

**Q: Sendable 경고**
```swift
// Actor 또는 @unchecked Sendable 사용
actor MyService {
    // 자동으로 Sendable
}

// 또는
final class MyClass: @unchecked Sendable {
    private let lock = NSLock()
}
```

**Q: MainActor 경고**
```swift
@MainActor
class ViewModel: ObservableObject {
    @Published var state: State
    
    func updateUI() {
        // 자동으로 Main thread
    }
}
```

## 📚 참고 자료

- [Tuist Documentation](https://docs.tuist.io)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## 🤝 기여

이슈와 PR은 언제나 환영합니다!

## 📄 라이선스

MIT License

---

Made with ❤️ by 송형욱
