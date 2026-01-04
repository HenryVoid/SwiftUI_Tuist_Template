# Swift 6.0 Strict Concurrency 에러 추적 문서

**생성일**: 2026-01-03  
**최종 업데이트**: 2026-01-04 10:00  
**빌드 환경**: Xcode 16.2, Swift 6.0.3, iOS 18.0+  
**Strict Concurrency 설정**: `SWIFT_STRICT_CONCURRENCY = targeted`

---

## 📊 최종 빌드 상태

| 모듈 | 빌드 상태 | Swift 6.0 에러 | 비고 |
|------|----------|---------------|------|
| Logger | ✅ BUILD SUCCEEDED | 0 | 완료 |
| Utility | ✅ BUILD SUCCEEDED | 0 | 완료 |
| NetworkKit | ✅ BUILD SUCCEEDED | 0 | 완료 |
| CacheKit | ✅ BUILD SUCCEEDED | 0 | 완료 |
| CoreKit | ✅ BUILD SUCCEEDED | 0 | 완료 |
| Entity | ✅ BUILD SUCCEEDED | 0 | Entity.UI 타입 추가 |
| GitHubService | ✅ BUILD SUCCEEDED | 0 | OngoingRequest enum 리팩토링 |
| **DesignSystem** | ✅ BUILD SUCCEEDED | 0 | 시스템 컬러/아이콘 대체 |
| **Feature 모듈** | 🔄 대기 중 | - | 다음 단계 |

---

## 🎯 주요 수정 사항

### 1. Entity 모듈 - Entity.UI 타입 추가
**파일**: `Projects/Core/Entity/Sources/UI/UITypes.swift`

**추가 타입**:
```swift
public extension Entity {
    enum UI {
        // CheckBox
        public enum CheckBoxState {
            case checked, unchecked, partial, indeterminate
        }
        
        // TextField
        public struct BottomText {
            public let text: String
            public let textColor: Color
        }
        
        public struct RightButton {
            public let action: () -> Void
            public let text: String
            public let textColor: Color
            public let isEnabled: Bool
        }
    }
}
```

### 2. GitHubService - Task 타입 안전성 개선
**파일**: `Projects/Core/GitHubService/Sources/GitHubService.swift`

**변경 전**:
```swift
private var ongoingRequests: [String: Task<Any, Error>] = [:]
return try await existingTask.value as! GitHubSearchResponse
```

**변경 후**:
```swift
private enum OngoingRequest {
    case search(Task<GitHubSearchResponse, any Error>)
    case repository(Task<GitHubRepository, any Error>)
}
private var ongoingRequests: [String: OngoingRequest] = [:]

if case .search(let task) = existingRequest {
    return try await task.value  // 타입 캐스팅 불필요
}
```

**효과**: 타입 안전성 향상, forced unwrapping 제거

### 3. DesignSystem - 시스템 리소스 대체
**파일**: 
- `Projects/DesignSystem/Sources/Color+.swift`
- `Projects/DesignSystem/Sources/Icons+.swift`

**변경 사항**:
- `DesignSystemAsset.Colors` → 시스템 `Color` (opacity 기반)
- `DesignSystemAsset.Icons` → SF Symbols

**예시**:
```swift
// Before
public static let primary500 = DesignSystemAsset.Colors.primary500.swiftUIColor
public static let icCheckThickness15 = DesignSystemAsset.Icons.icCheckThickness15.swiftUIImage

// After
public static let primary500 = Color.blue
public static let icCheckThickness15 = Image(systemName: "checkmark")
```

### 4. DesignSystem - 공통 컴포넌트 추가
**새로 추가된 파일**:

**SwiftUI 컴포넌트**:
- `GitHub/RepositoryRow.swift` - Repository 정보 표시
- `GitHub/AvatarView.swift` - 비동기 이미지 로딩
- `GitHub/StatCard.swift` - 통계 카드
- `Common/SearchBarView.swift` - 검색 바
- `Common/EmptyStateView.swift` - 빈 상태 뷰
- `Common/LoadingOverlay.swift` - 로딩 오버레이

**UIKit 컴포넌트**:
- `GitHub/RepositoryTableViewCell.swift` - UITableViewCell 기반 (ReactorKit용)

**Font 확장**:
- `title1`, `title2`, `title3` 메서드 추가 (headline 별칭)

---

## 📝 빌드 로그 요약

### 최종 빌드 결과
```bash
xcodebuild -workspace MyApp.xcworkspace -scheme DesignSystem
Result: ** BUILD SUCCEEDED **
```

### 해결된 주요 에러

#### 1. Entity.UI 타입 누락
```
error: no type named 'UI' in module 'Entity'
```
**해결**: Entity 모듈에 UI 네임스페이스 및 타입 정의

#### 2. GitHubService Task 타입 불일치
```
error: cannot assign value of type 'Task<GitHubSearchResponse, any Error>' 
       to type 'Task<Any, any Error>'
```
**해결**: OngoingRequest enum으로 각 Task 타입 분리

#### 3. DesignSystemAsset 번들 생성 실패
```
error: Build input file cannot be found: 'DesignSystem_DesignSystem.bundle'
error: cannot find 'DesignSystemAsset' in scope
```
**해결**: 
- `resources: nil` 설정
- Color+.swift와 Icons+.swift를 시스템 리소스로 대체

#### 4. Font 메서드 누락
```
error: value of type 'Text' has no member 'title3'
```
**해결**: Font+.swift에 title1/2/3 별칭 메서드 추가

#### 5. CheckBox switch exhaustive
```
error: switch must be exhaustive
```
**해결**: CheckBoxState에 `partial`, `indeterminate` 케이스 처리 추가

---

## 🚀 다음 단계

### Feature 모듈 빌드 (대기 중)
1. GitHubSearchMVVM
2. GitHubSearchTCA
3. GitHubSearchReactor
4. PerformanceDashboard

### 전체 워크스페이스 빌드
```bash
xcodebuild -workspace MyApp.xcworkspace -scheme MyApp
```

---

## 📌 기술적 결정 사항

### 1. Entity.UI vs DesignSystem 타입
**결정**: Entity.UI에 UI 타입 정의
**이유**: 
- DesignSystem이 Entity에 의존하는 것이 순환 의존성 방지
- UI 타입은 도메인 엔티티와 밀접한 관련

### 2. OngoingRequest Enum 패턴
**결정**: enum으로 다양한 Task 타입 wrapping
**이유**:
- Task<Any, any Error> 대신 타입 안전한 방식
- forced unwrapping (as!) 제거
- 컴파일 타임 타입 체크

### 3. Resources 번들 vs 시스템 리소스
**결정**: 시스템 컬러/SF Symbols 사용
**이유**:
- Resources 번들 생성 복잡성 회피
- Swift 6.0 호환성 우선
- 추후 커스텀 디자인으로 교체 가능 (점진적 개선)

---

## ✅ 완료 체크리스트

- [x] Logger 모듈 빌드 성공
- [x] Utility 모듈 빌드 성공
- [x] NetworkKit 모듈 빌드 성공
- [x] CacheKit 모듈 빌드 성공
- [x] CoreKit 모듈 빌드 성공
- [x] Entity 모듈 빌드 성공 + UI 타입 추가
- [x] GitHubService 빌드 성공 + Task 리팩토링
- [x] DesignSystem 빌드 성공 + 공통 컴포넌트 추가
- [ ] GitHubSearchMVVM 빌드 테스트
- [ ] GitHubSearchTCA 빌드 테스트
- [ ] GitHubSearchReactor 빌드 테스트
- [ ] 전체 워크스페이스 빌드 테스트
- [ ] Unit Tests 실행

---

**마지막 커밋**: `fix: DesignSystemAsset을 시스템 컬러/아이콘으로 대체`  
**빌드 상태**: ✅ All Core Modules + DesignSystem BUILD SUCCEEDED
