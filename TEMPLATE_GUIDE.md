# Tuist Template 사용 가이드

## 개요

이 템플릿은 다양한 아키텍처 패턴과 네비게이션 방식을 지원하는 유연한 iOS 프로젝트 템플릿입니다.

## 사용 가능한 템플릿

### 1. Feature 템플릿

기본 Feature 모듈을 생성합니다 (MVVM + Clean Architecture 기반).

```bash
tuist scaffold feature --name MyFeature
```

생성되는 파일:
- `Project.swift` - 프로젝트 설정
- `Sources/` - Feature 소스 코드
- `Tests/` - 테스트 코드
- `DemoApp/` - 독립 실행 가능한 데모 앱

### 2. Core 템플릿

새로운 Core 모듈을 생성합니다.

```bash
tuist scaffold core --name PaymentKit
```

생성되는 파일:
- `Project.swift` - 프로젝트 설정
- `Sources/File.swift` - 플레이스홀더 파일

## 템플릿 생성 후 설정

### 1. Module.swift에 모듈 추가

```swift
// Plugins/MyAppPlugIn/ProjectDescriptionHelpers/Module/Module.swift

// Feature 모듈 추가
public extension Module {
    enum Feature: String, CaseIterable {
        case Auth
        case Main
        case Base
        case MyFeature  // ← 추가
        
        public static let name: String = "Feature"
    }
}

// Core 모듈 추가
public extension Module {
    enum Core: String, CaseIterable {
        case NetworkKit
        case CacheKit
        case Logger
        case PaymentKit  // ← 추가
        
        public static let name: String = "Core"
    }
}
```

### 2. 프로젝트 재생성

```bash
tuist edit  # Module.swift 편집
tuist generate  # 프로젝트 재생성
```

## 아키텍처 패턴 선택

### MVVM + Clean Architecture

**추천 상황**: 중소규모 프로젝트, 빠른 개발 필요

**구조**:
```
Feature/
├── ViewModel (프레젠테이션 로직)
├── View (UI)
├── UseCase (비즈니스 로직)
└── Repository (데이터 접근)
```

**사용법**:
```swift
// ViewModel
@MainActor
class ShoppingViewModel: ViewModel {
    @Published var state: ShoppingState
    
    private let useCase: ShoppingUseCase
    
    func send(_ action: ShoppingAction) {
        // Handle actions
    }
}

// View
struct ShoppingView: View {
    @StateObject var viewModel: ShoppingViewModel
    
    var body: some View {
        // UI implementation
    }
}
```

### VIPER

**추천 상황**: 대규모 프로젝트, 극도의 모듈화 필요

**구조**:
```
Feature/
├── View (UIViewController)
├── Interactor (비즈니스 로직)
├── Presenter (프레젠테이션 로직)
├── Entity (데이터 모델)
└── Router (네비게이션)
```

**사용법**:
```swift
// Module Builder
struct ShoppingModule: VIPERModuleBuilder {
    static func build() -> ShoppingViewController {
        let view = ShoppingViewController()
        let interactor = ShoppingInteractor()
        let presenter = ShoppingPresenter()
        let router = ShoppingRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        router.viewController = view
        
        return view
    }
}
```

## 네비게이션 패턴 선택

### 1. Coordinator Pattern (UIKit)

**추천 상황**: UIKit 기반, 복잡한 네비게이션 플로우

```swift
class AppCoordinator: UIKitCoordinator {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showLogin()
    }
    
    func showLogin() {
        let loginCoordinator = LoginCoordinator(navigationController: navigationController)
        loginCoordinator.delegate = self
        coordinate(to: loginCoordinator)
    }
}
```

### 2. Router Pattern (SwiftUI)

**추천 상황**: SwiftUI 기반, 선언적 네비게이션

```swift
enum AppRoute: Route {
    case home
    case detail(id: String)
    case settings
    
    var path: String {
        switch self {
        case .home: return "/home"
        case .detail(let id): return "/detail/\(id)"
        case .settings: return "/settings"
        }
    }
}

class AppRouter: BasicRouter<AppRoute> {
    // NavigationPath 자동 관리
}

// View에서 사용
struct ContentView: View {
    @StateObject var router = AppRouter()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
    }
}
```

## 무한스크롤 구현

### SwiftUI

```swift
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

### UIKit

```swift
class MovieListViewController: UIViewController {
    let paginationHelper = CollectionViewPaginationHelper(threshold: 5) {
        await self.loadNextPage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.prefetchDataSource = paginationHelper
    }
    
    func loadNextPage() async {
        // Load next page
    }
}
```

## 프로젝트 커스터마이징

### xcconfig 설정

```
// XCConfig/Shared.xcconfig

// API Keys
KAKAO_APP_KEY = your_kakao_key
BASE_URL = https://api.yourdomain.com

// Swift Settings
SWIFT_VERSION = 6.0
SWIFT_STRICT_CONCURRENCY = complete
IPHONEOS_DEPLOYMENT_TARGET = 18.0
```

### DI Container 설정

```swift
// AppDelegate or App struct

let container = ManualDIContainer.shared

// 서비스 등록
container.registerSingleton(NetworkServiceProtocol.self) {
    NetworkService()
}

container.registerSingleton(CacheServiceProtocol.self) {
    try! HybridCache()
}

container.registerSingleton(AnalyticsManager.self) {
    let manager = AnalyticsManager.shared
    Task {
        await manager.addProvider(ConsoleAnalyticsProvider())
    }
    return manager
}
```

## 베스트 프랙티스

### 1. 모듈 의존성 관리

- Feature는 Core에만 의존
- Feature 간 직접 의존 금지
- 공통 기능은 Core로 추출

### 2. 테스트 작성

- 각 모듈에 Tests 폴더 생성
- Mock 객체는 프로토콜 기반으로
- 비동기 테스트는 async/await 사용

### 3. 성능 최적화

- 이미지는 ImageCache 사용
- 리스트는 LazyVStack 또는 UICollectionView
- 메모리 경고는 MemoryOptimizer로 처리

### 4. 로깅 및 Analytics

- 개발: ConsoleAnalyticsProvider
- 프로덕션: Firebase/Amplitude
- 민감 정보는 로그에서 제외

## 트러블슈팅

### Q: 템플릿 생성 후 컴파일 에러

```bash
# 1. Module.swift에 모듈 추가 확인
tuist edit

# 2. 프로젝트 재생성
tuist clean
tuist generate
```

### Q: 의존성 문제

```bash
# Package.swift 확인 후 재설치
tuist install --force
```

### Q: Sendable 경고

```swift
// Actor 사용 또는 @unchecked Sendable
actor MyService {
    // 자동으로 Sendable
}
```

## 참고 자료

- [Tuist 공식 문서](https://docs.tuist.io)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Coordinator Pattern](https://khanlou.com/2015/01/the-coordinator/)

