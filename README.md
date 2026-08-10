# SwiftUI Tuist Template

Tuist를 이용해 iOS 앱의 App / Feature / Core / DesignSystem 경계를 나누고, SwiftUI와 UIKit이 함께 존재하는 구조를 실험한 모듈러 프로젝트 템플릿입니다.

이 저장소는 완성된 제품 앱이라기보다, iOS 프로젝트가 커질 때 반복되는 target 설정, 공통 모듈 분리, Feature별 아키텍처 실험, UIKit/SwiftUI 공존 방식을 코드로 정리한 포트폴리오 성격의 템플릿입니다.

## Why

iOS 프로젝트가 커지면 다음 문제가 반복됩니다.

- Feature가 늘어날수록 Xcode target 설정과 dependency 관리가 복잡해진다.
- 공통 기능이 App target에 섞이면 테스트와 재사용이 어려워진다.
- UIKit 기반 화면과 SwiftUI 기반 화면이 함께 존재할 때 경계가 흐려진다.
- 네트워크, 캐시, 로깅, 분석, 라우팅 같은 공통 인프라의 위치가 모호해진다.
- 새로운 Feature를 만들 때 Project.swift, DemoApp, Tests 설정을 반복하게 된다.

이 프로젝트는 Tuist와 ProjectDescriptionHelpers를 이용해 위 문제를 구조적으로 다루는 방법을 실험합니다.

## Goals

- Tuist 기반으로 모듈 생성 규칙을 코드화한다.
- App / Feature / Core / DesignSystem의 의존성 방향을 명시한다.
- SwiftUI Feature와 UIKit Feature가 공존할 수 있는 구조를 둔다.
- Network, Cache, Logger, Analytics, Utility 같은 공통 모듈을 분리한다.
- MVVM, TCA, ReactorKit을 같은 GitHub Search 도메인에서 비교할 수 있게 둔다.
- 테스트 가능한 protocol/interface 기반 의존성 주입 구조를 일부 적용한다.
- 과장된 "프로덕션 완성형 템플릿"보다 실제 코드 기반의 trade-off를 드러낸다.

## Requirements

| Tool | Version |
|---|---|
| Swift | 6.0 |
| iOS Deployment Target | 18.0 |
| Tuist | 4.33.0 |
| Xcode | Swift 6 / iOS 18 빌드 가능 버전 |

Tuist 버전은 `.mise.toml`과 `Tuist/Package.swift` 기준으로 관리됩니다.

## Project Structure

```text
SwiftUI_Tuist_Template
├── Workspace.swift
├── Tuist
│   ├── Config.swift
│   ├── Package.swift
│   └── Templates
│       ├── Stencil
│       ├── core
│       └── feature
├── Plugins
│   └── MyAppPlugIn
│       └── ProjectDescriptionHelpers
│           ├── Module
│           ├── Project+Template
│           ├── Setting
│           ├── DependencyPackage
│           ├── Environment
│           └── Scaffold
├── XCConfig
│   ├── Shared.xcconfig
│   ├── Debug.xcconfig
│   └── Release.xcconfig
└── Projects
    ├── MyApp
    ├── Feature
    │   ├── Auth
    │   ├── Base
    │   ├── Main
    │   ├── GitHubSearchMVVM
    │   ├── GitHubSearchTCA
    │   ├── GitHubSearchReactor
    │   ├── GitHubSearchShared
    │   └── PerformanceDashboard
    ├── Core
    │   ├── AnalyticsKit
    │   ├── CacheKit
    │   ├── CoreKit
    │   ├── Entity
    │   ├── GitHubServiceInterface
    │   ├── GitHubService
    │   ├── Logger
    │   ├── NetworkKit
    │   ├── PerformanceMonitor
    │   └── Utility
    └── DesignSystem
```

## Tuist Design

이 프로젝트는 Tuist manifest를 직접 반복 작성하지 않고, `Plugins/MyAppPlugIn/ProjectDescriptionHelpers`에 공통 생성 규칙을 둡니다.

### Workspace

`Workspace.swift`는 다음 project group을 포함합니다.

```swift
projects: [
    "Projects/MyApp",
    "Projects/Core/**",
    "Projects/DesignSystem",
    "Projects/Feature/**"
]
```

### Module Definition

모듈은 `Module.swift`에서 enum으로 관리됩니다.

```text
Feature
├── Auth
├── Main
├── Base
├── GitHubSearchMVVM
├── GitHubSearchTCA
├── GitHubSearchReactor
├── GitHubSearchShared
└── PerformanceDashboard

Core
├── Entity
├── NetworkKit
├── Logger
├── Utility
├── CoreKit
├── CacheKit
├── AnalyticsKit
├── GitHubServiceInterface
├── GitHubService
└── PerformanceMonitor

Design
└── DesignSystem
```

### Project Template

`Project.makeModule`은 main target, unit test target, demo app target, scheme, demo scheme, xcconfig 연결을 공통 규칙으로 생성합니다.

각 모듈의 `Project.swift`는 product type, dependency, test/demo 여부만 선언합니다.

### Dependency Helper

dependency는 helper를 통해 선언합니다.

```swift
.core(module: .NetworkKit)
.feature(module: .GitHubSearchMVVM)
.design(module: .DesignSystem)
.external(name: "ComposableArchitecture")
```

이 방식은 문자열 기반 path를 줄이고, 모듈 경계를 코드에서 확인하기 쉽게 만듭니다.

### Templates

`Tuist/Templates`에는 Stencil 기반 template이 존재합니다.

```text
Tuist/Templates
├── Stencil
│   ├── base.stencil
│   ├── core.stencil
│   ├── demo.stencil
│   ├── feature.stencil
│   ├── file.stencil
│   └── test.stencil
├── core
└── feature
```

현재 상태에서는 완성된 Feature 자동 생성 시스템이라기보다, scaffold/template 기반 확장 지점에 가깝습니다.

## Dependency Direction

현재 주요 방향은 다음과 같습니다.

```text
MyApp
└── Feature
    ├── Core
    ├── DesignSystem
    └── GitHubSearchShared

Core
├── GitHubServiceInterface
├── GitHubService
├── NetworkKit
├── CacheKit
├── Logger
├── AnalyticsKit
└── Utility

DesignSystem
└── Entity

GitHubSearchShared
├── GitHubServiceInterface
├── CacheKit
└── DesignSystem
```

`GitHubServiceInterface`는 GitHub 도메인의 public DTO와 service protocol을 담고, `GitHubService`는 실제 GitHub API 구현을 담당합니다.

이 분리는 Feature가 concrete service 구현보다 interface에 의존할 수 있게 하기 위한 구조입니다.

## App

`Projects/MyApp`는 실제 앱 target입니다.

현재 `MoimApp.swift`의 entry point는 단순한 `Text("Hello, World")`입니다. GitHub Search나 Performance Dashboard가 MyApp의 메인 플로우에 통합되어 있다고 표현하지 않습니다.

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Hello, World")
        }
    }
}
```

Feature별 실험은 각 Feature의 DemoApp target에서 확인하는 구조입니다.

## Feature Modules

### GitHubSearchMVVM

SwiftUI 기반 MVVM + 일부 Clean Architecture 스타일을 실험한 Feature입니다.

```text
GitHubSearchMVVM
├── DI
├── Data
│   └── Repository
├── Domain
│   ├── Entity
│   ├── Repository
│   └── UseCase
└── Presentation
    ├── Home
    └── Detail
```

구현 요소:

- `HomeView`
- `HomeViewModel`
- `DetailView`
- `DetailViewModel`
- `SearchRepositoriesUseCase`
- `GetRepositoryDetailUseCase`
- `GitHubRepositoryProtocol`
- `GitHubRepositoryImpl`
- `GitHubSearchDIContainer`

`HomeViewModel`과 `DetailViewModel`은 `@MainActor`로 UI 상태를 다룹니다. UseCase와 Repository 구현은 actor 기반입니다.

### GitHubSearchTCA

The Composable Architecture 기반 GitHub Search 예제입니다.

```text
GitHubSearchTCA
├── Home
│   ├── HomeFeature
│   └── HomeView
└── Services
    └── GitHubClient
```

구현 요소:

- `@Reducer`
- `@ObservableState`
- `Action`
- `TaskResult`
- `DependencyValues.githubClient`
- closure 기반 `GitHubClient`

TCA 구조는 state/action/effect 흐름을 명시적으로 보여주는 예제입니다.

### GitHubSearchReactor

UIKit + ReactorKit + RxSwift 기반 GitHub Search 예제입니다.

```text
GitHubSearchReactor
├── Home
│   ├── HomeReactor
│   └── HomeViewController
└── Services
    └── RxGitHubService
```

구현 요소:

- `HomeReactor`
- `HomeViewController`
- `RxGitHubService`
- `UITableView`
- `UISearchBar`
- RxSwift/RxCocoa binding

UIKit 화면에서도 같은 GitHub service interface와 shared UI cell을 사용할 수 있도록 구성되어 있습니다.

### GitHubSearchShared

GitHub Search 계열 Feature가 공유하는 UI 컴포넌트 모듈입니다.

```text
GitHubSearchShared
├── AvatarView
├── RepositoryRow
├── RepositoryTableViewCell
├── StatCard
└── GitHubRepositoryRow
```

이 모듈은 `DesignSystem`에서 분리되었습니다. `RepositoryRow`, `RepositoryTableViewCell` 같은 컴포넌트가 순수 디자인 시스템이 아니라 GitHub 도메인 모델에 의존하기 때문입니다.

### PerformanceDashboard

성능 지표를 화면으로 확인하는 SwiftUI demo Feature입니다.

구현 요소:

- FPS 지표
- 메모리 사용량
- ImageCache 통계
- performance report JSON export

실제 아키텍처별 성능 측정을 자동으로 실행하고 비교하는 완성형 benchmark 시스템은 아닙니다. 현재는 `PerformanceMonitor`, `CacheKit`의 지표를 보여주는 실험용 대시보드에 가깝습니다.

### Auth / Main / Base

`Auth`, `Main`, `Base` 모듈은 현재 구조상 scaffold 또는 placeholder 성격이 강합니다.

- `Auth`: `Base`에 의존하며 demo/test target이 존재
- `Main`: `Base`에 의존하며 demo/test target이 존재
- `Base`: `CoreKit`, `DesignSystem`에 의존하는 framework

현재 상태에서는 이 모듈들을 완성된 인증/메인 기능으로 소개하지 않습니다.

## Core Modules

### GitHubServiceInterface

GitHub 도메인의 interface 모듈입니다.

포함 타입:

- `GitHubServiceProtocol`
- `GitHubRepository`
- `Owner`
- `GitHubSearchResponse`

Feature, shared UI, GitHub service 구현체가 같은 DTO/protocol을 공유하기 위한 모듈입니다.

### GitHubService

GitHub API 구현체입니다.

구현 요소:

- `GitHubService`
- `GitHubAPI`
- `SearchRepositoriesRequest`
- `GetRepositoryRequest`

특징:

- `GitHubService`는 actor
- `NetworkKit.NetworkService`를 통해 async request 수행
- 동일 query/page 또는 owner/repo 요청에 대해 ongoing task를 재사용하는 구조
- `Logger`를 통해 네트워크 로그 기록

### NetworkKit

URLSession 기반 네트워크 모듈입니다.

구현 요소:

- `NetworkRequest`
- `NetworkService`
- `NetworkError`
- `HTTPMethod`
- `RequestInterceptor`
- `DefaultRequestInterceptor`
- `AuthInterceptor`

특징:

- async/await 기반 request
- Decodable response 처리
- HTTP status code 검증
- retry 가능한 interceptor 구조
- multipart upload helper 존재

주의: `NetworkRequest.parameters`는 `[String: Any]?`를 사용하므로 엄격한 Sendable 관점에서는 추가 정리가 필요할 수 있습니다.

### CacheKit

actor 기반 캐시 모듈입니다.

구현 요소:

- `MemoryCache`
- `DiskCache`
- `HybridCache`
- `LRUCacheManager`
- `ImageCache`
- `CacheProtocol`
- `CacheError`

특징:

- 메모리 캐시
- 디스크 캐시
- LRU 캐시
- 이미지 로딩 및 캐싱
- 이미지 캐시 통계 제공

`ImageCache`는 `GitHubSearchShared`의 avatar UI와 `PerformanceDashboard`에서 사용됩니다.

### Logger

OSLog + 파일 저장 + 선택적 원격 전송 구조를 가진 로깅 모듈입니다.

구현 요소:

- `Log`
- `AdvancedLogger`
- `FileLogStorage`
- `LogStorage`
- `RemoteLogSender`
- `HTTPRemoteLogSender`

특징:

- `AdvancedLogger`는 actor
- OSLog 출력
- 파일 기반 로그 저장
- metadata 포함 로그
- remote sender protocol 및 HTTP sender 구현 존재

주의: 원격 로그 전송은 protocol과 HTTP sender 구현이 존재하지만, 앱에서 특정 운영 endpoint로 연결된 상태라고 표현하지 않습니다.

### AnalyticsKit

이벤트 큐잉과 provider fan-out 구조를 가진 분석 모듈입니다.

구현 요소:

- `AnalyticsManager`
- `AnalyticsEvent`
- `AnalyticsProvider`
- `ConsoleAnalyticsProvider`
- `FirebaseAnalyticsAdapter`
- `AmplitudeAnalyticsAdapter`

특징:

- `AnalyticsManager`는 actor
- event queue
- batch flush
- multiple provider
- `withTaskGroup`을 이용한 provider dispatch

주의: Firebase/Amplitude adapter는 실제 SDK 연동이 아니라 예시 adapter입니다. 현재 코드는 print 기반 placeholder 호출을 포함합니다.

### CoreKit

앱 구조 패턴과 UIKit/SwiftUI bridge를 모아둔 모듈입니다.

구현 요소:

- `Coordinator`
- `UIKitCoordinator`
- `Route`
- `Router`
- `BasicRouter`
- `UIViewControllerWrapper`
- `SwiftUIHostingController`
- `UIViewControllerPreview`
- `Pagination`
- `UIKitPagination`
- `MVVMClean`
- `VIPER`

주의:

- VIPER는 실제 Feature 구현이 아니라 protocol/template 성격의 구조 샘플입니다.
- Coordinator/Router도 공통 패턴 구현체이며, 현재 MyApp 메인 플로우에 깊게 연결되어 있다고 표현하지 않습니다.

### Utility

공통 유틸리티 모듈입니다.

구현 요소:

- `ManualDIContainer`
- `Injected`
- `KeychainManager`
- `UserDefault`
- `UserDefaultCodable`
- `UserDefaultsManager`
- `MemoryOptimizer`

주의:

- `ManualDIContainer`는 런타임 resolve 방식입니다. 컴파일 타임 DI 프레임워크라고 표현하지 않습니다.
- 일부 Utility 테스트는 현재 API와 불일치 가능성이 있어 정비가 필요합니다.

### Entity

공통 UI 타입과 GitHub repository alias를 담는 모듈입니다.

구현 요소:

- `Entity.UI.CheckBoxState`
- `Entity.UI.BottomText`
- `Entity.UI.RightButton`
- `RepositoryEntity`

`RepositoryEntity`는 현재 `GitHubRepository`의 typealias입니다.

### PerformanceMonitor

FPS, 메모리, 성능 리포트를 수집하는 모듈입니다.

구현 요소:

- `FPSMonitor`
- `MemoryMonitor`
- `PerformanceMetrics`

특징:

- CADisplayLink 기반 FPS 측정
- mach task info 기반 메모리 측정
- report 누적 및 JSON export

## DesignSystem

`DesignSystem`은 공통 UI 토큰과 재사용 컴포넌트를 제공합니다.

```text
DesignSystem
├── Button
│   ├── SolidButton
│   ├── SecondaryButton
│   ├── OutlinedButton
│   ├── AssistiveButton
│   └── DSButtonContent
├── CheckBox
├── TextField
├── Common
├── DatePicker
├── TopBar
├── Line
├── Radio
├── Color+.swift
├── Font+.swift
├── Icons+.swift
└── DesignToken.swift
```

최근 구조에서는 GitHub 도메인 UI를 `GitHubSearchShared`로 분리했습니다. 따라서 DesignSystem은 가능한 한 도메인 모델을 모르는 공통 UI 계층으로 유지하는 방향입니다.

현재 DesignSystem은 `Entity.UI` 타입을 사용하는 일부 TextField/CheckBox API 때문에 `Entity`에 의존합니다.

## UIKit and SwiftUI

이 프로젝트는 SwiftUI와 UIKit을 모두 포함합니다.

SwiftUI 구현:

- `MyApp`
- `GitHubSearchMVVM`
- `GitHubSearchTCA`
- `PerformanceDashboard`
- `DesignSystem` components

UIKit 구현:

- `GitHubSearchReactor.HomeViewController`
- `RepositoryTableViewCell`
- `UISearchBar`
- `UITableView`
- `UINavigationController`

Bridge 구조:

- `UIViewControllerWrapper`
- `SwiftUIHostingController`
- `UIViewControllerPreview`

현재 bridge helper는 존재하지만, 모든 Feature가 bridge를 통해 통합되어 있는 것은 아닙니다. README에서는 이를 UIKit/SwiftUI 공존을 위한 공통 도구로 설명합니다.

## Swift Concurrency

실제 코드에서 사용되는 Swift Concurrency 요소는 다음과 같습니다.

| 요소 | 사용 위치 |
|---|---|
| `async/await` | NetworkKit, GitHubService, CacheKit, Logger, AnalyticsKit, Feature ViewModel |
| `actor` | NetworkService, GitHubService, CacheKit, Logger, AnalyticsManager, Utility 일부 |
| `@MainActor` | SwiftUI ViewModel, Router, FPSMonitor, PerformanceDashboard ViewModel |
| `Task` | Feature side effect, Logger async logging, monitoring stop |
| `withTaskGroup` | Analytics provider dispatch |
| `Sendable` | DTO, protocol, cache generic constraint 일부 |

주의:

- `SWIFT_STRICT_CONCURRENCY = complete` 설정이 존재합니다.
- 일부 API는 `[String: Any]`, UIKit 타입, legacy test와 함께 사용되므로 Swift 6 Concurrency 완전 지원이라고 표현하지 않습니다.
- 현재 README에서는 Swift Concurrency를 적극적으로 적용 중인 구조로 표현합니다.

## External Dependencies

`Tuist/Package.swift` 기준 선언된 외부 의존성입니다.

| Dependency | 현재 코드 사용 여부 |
|---|---|
| ComposableArchitecture | `GitHubSearchTCA`에서 사용 |
| ReactorKit | `GitHubSearchReactor`에서 사용 |
| RxSwift / RxCocoa | `GitHubSearchReactor`에서 사용 |
| RxTest | ReactorKit 테스트에서 사용 |
| Alamofire | 선언되어 있으나 현재 프로젝트 소스에서 직접 import 확인 안 됨 |
| NukeUI | 선언되어 있으나 현재 프로젝트 소스에서 직접 import 확인 안 됨 |

이미지 로딩은 현재 `NukeUI`가 아니라 `CacheKit.ImageCache` 기반으로 구현되어 있습니다.

## Demo Targets

현재 코드 기준 demo app target이 있는 모듈:

| Demo | 내용 |
|---|---|
| DesignSystemDemoApp | DesignSystem demo app target |
| GitHubSearchMVVMDemoApp | SwiftUI MVVM GitHub Search |
| GitHubSearchTCADemoApp | SwiftUI TCA GitHub Search |
| GitHubSearchReactorDemoApp | UIKit ReactorKit GitHub Search |
| PerformanceDashboardDemoApp | 성능 지표 대시보드 |
| AuthDemoApp | scaffold 성격 |
| MainDemoApp | scaffold 성격 |
| BaseDemoApp | scaffold 성격 |

주의:

- MyApp 메인 target은 현재 Hello World 수준입니다.
- GitHub Search 계열은 demo target 중심의 실험 구조입니다.
- 실제 API 연결은 GitHub public API request 구조가 존재합니다.
- 각 demo의 현재 빌드 가능 여부는 로컬 generate/build 상태에 따라 재검증이 필요합니다.

## Testing

현재 테스트는 XCTest 중심이며, 일부 Swift Testing이 추가되어 있습니다.

| 영역 | 테스트 파일 |
|---|---|
| Logger | `LoggerTests.swift` |
| GitHubServiceInterface | `GitHubServiceInterfaceTests.swift` |
| Entity | `EntityTests.swift` |
| CoreKit | `CoreKitTests.swift` |
| CacheKit | `CacheKitTests.swift` |
| NetworkKit | `NetworkKitTests.swift` |
| AnalyticsKit | `AnalyticsKitTests.swift` |
| PerformanceMonitor | `PerformanceMonitorTests.swift` |
| GitHubService | `GitHubServiceTests.swift` |
| GitHubSearchMVVM | `GitHubSearchMVVMTests.swift` |
| GitHubSearchTCA | `GitHubSearchTCATests.swift` |
| GitHubSearchReactor | `GitHubSearchReactorTests.swift` |
| MyApp | `MoimTests.swift` |

테스트에서 확인되는 것:

- NetworkKit: Mock URLProtocol 기반 request/decoding/error 테스트
- CacheKit: Memory cache, expiration, LRU 일부 테스트
- Logger: level filtering, file storage, metadata 테스트
- AnalyticsKit: queueing, batch flush, multiple provider 테스트
- GitHubService: GitHub search/detail response decoding 테스트
- GitHubServiceInterface: DTO decoding, protocol mock 가능성 테스트
- MVVM: UseCase 테스트
- TCA: TestStore 기반 state transition 테스트
- ReactorKit: RxTest dependency와 mock service 기반 테스트 시도

현재 없는 것:

- Snapshot test
- UI automation test
- 전체 앱 end-to-end test
- coverage 수치
- 모든 Feature의 완성도 높은 테스트

주의:

- 일부 scaffold/legacy 테스트는 placeholder 성격입니다.
- Utility 테스트 일부는 현재 API와 맞지 않을 가능성이 있어 정비가 필요합니다.
- 따라서 완벽한 테스트 환경 또는 높은 커버리지라고 표현하지 않습니다.

## Running the Project

```bash
mise exec -- tuist install
mise exec -- tuist generate --no-open
open MyApp.xcworkspace
```

또는 Tuist가 PATH에 있다면:

```bash
tuist install
tuist generate
open MyApp.xcworkspace
```

Feature demo를 확인하려면 Xcode에서 해당 demo scheme을 선택합니다.

```text
GitHubSearchMVVMDemoApp
GitHubSearchTCADemoApp
GitHubSearchReactorDemoApp
PerformanceDashboardDemoApp
DesignSystemDemoApp
```

## Configuration

공통 build setting은 `XCConfig`에서 관리합니다.

```text
XCConfig
├── Shared.xcconfig
├── Debug.xcconfig
└── Release.xcconfig
```

현재 설정 예:

- `SWIFT_VERSION = 6.0`
- `SWIFT_STRICT_CONCURRENCY = complete`
- `IPHONEOS_DEPLOYMENT_TARGET = 18.0`
- Debug: actor data race check flag
- Release: wholemodule optimization

주의:

- `Shared.xcconfig`에는 API key placeholder가 존재합니다.
- 실제 앱 배포용 secret 관리 구조까지 완성된 것은 아닙니다.

## Architectural Trade-offs

### 1. Framework와 Static Library 혼합

일부 모듈은 framework, 일부는 static library입니다.

framework로 둔 모듈:

- `DesignSystem`
- `GitHubServiceInterface`
- `GitHubService`
- `Logger`
- `CoreKit`
- GitHub Search Feature 계열

static library로 둔 모듈:

- `NetworkKit`
- `CacheKit`
- `AnalyticsKit`
- `Entity`
- `Utility`
- 일부 scaffold Feature

여러 경로에서 동시에 링크되는 shared 모듈은 static product 중복 링크 경고가 발생할 수 있어 framework로 전환했습니다.

### 2. GitHubSearchShared 분리

GitHub 관련 row/cell/stat UI는 처음에는 DesignSystem에 있을 수 있지만, 실제로는 `GitHubRepository` 도메인 모델에 의존합니다.

따라서 현재 구조에서는 다음처럼 분리합니다.

```text
DesignSystem: 도메인 독립 UI
GitHubSearchShared: GitHub 도메인 UI
```

### 3. 여러 아키텍처 공존

MVVM, TCA, ReactorKit이 모두 존재합니다.

이 구조는 하나의 정답 아키텍처를 강제하기보다, 같은 GitHub Search 도메인을 서로 다른 방식으로 구현해 비교하기 위한 목적이 큽니다.

실제 제품 코드라면 팀 기준에 맞춰 하나의 Feature architecture를 선택하거나, migration 목적이 분명해야 합니다.

## Current Limitations

- `MyApp` target은 아직 실제 Feature navigation에 연결되지 않은 Hello World 상태입니다.
- Auth/Main/Base 일부는 scaffold 또는 placeholder 성격입니다.
- Firebase/Amplitude는 실제 SDK 연동이 아니라 예시 adapter입니다.
- NukeUI/Alamofire는 package dependency로 선언되어 있지만 현재 소스에서 직접 사용되는 import는 확인되지 않습니다.
- Snapshot/UI automation 테스트는 없습니다.
- 일부 legacy/scaffold 테스트는 현재 API와 맞지 않을 수 있어 정리가 필요합니다.
- PerformanceDashboard는 지표 표시 구조가 있지만, 자동 benchmark 시스템이라고 보기는 어렵습니다.
- Tuist generate 후 Xcode build 검증은 로컬 환경의 code signing, generated project 상태에 따라 추가 확인이 필요합니다.

## Repository Positioning

이 프로젝트는 다음 관점에서 보는 것이 가장 정확합니다.

> UIKit과 SwiftUI가 공존하는 iOS 프로젝트에서 Tuist를 이용해 모듈 경계, 공통 인프라, 프로젝트 생성 규칙을 실험하고 정리한 템플릿

이 README는 프로젝트를 완성된 엔터프라이즈 템플릿으로 과장하지 않습니다.
대신 실제 코드에 존재하는 모듈 경계, 의존성 방향, 테스트 가능한 지점, 그리고 아직 정비가 필요한 부분을 함께 드러냅니다.
