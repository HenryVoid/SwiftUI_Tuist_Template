# DesignSystem 리팩토링 계획 및 현재 상태

## 📋 작업 개요
**목표**: GitHubSearch 3개 Feature 모듈의 공통 뷰 컴포넌트를 DesignSystem으로 추출  
**브랜치**: `develop`  
**작업 일시**: 2026-01-04  

---

## 🔍 현재 문제 상황

### 1. DesignSystem 모듈의 구조적 이슈
DesignSystem이 `Entity.UI` 타입에 의존하고 있어 순환 의존성 및 빌드 실패 발생:

**문제있는 컴포넌트들**:
- `CheckBox/DefaultCheckBox.swift` - Entity.UI.CheckBoxState 사용
- `CheckBox/RoundCheckBox.swift` - Entity.UI.CheckBoxState 사용
- `CheckBox/RoundCheckBoxRow.swift` - Entity.UI.CheckBoxState, Entity.UI.RightButton 사용
- `TextField/DefaultTextField.swift` - Entity.UI.BottomText, Entity.UI.RightButton 사용
- `TopBar/TopBar.swift` - DesignSystemAsset.Icons 참조
- `DatePicker/DatePickerRow.swift` - DesignSystemAsset.Icons 참조
- `Button/*` - Entity.UI 타입 의존
- `Icons+.swift` - DesignSystemAsset 참조 (번들 생성 실패)
- `Color+.swift` - DesignSystemAsset.Colors 참조 (번들 생성 실패)

### 2. Resources 번들 생성 실패
`DesignSystem/Resources/**` 설정이 `DesignSystem_DesignSystem.bundle` 생성 실패

---

## ✅ 완료된 작업

### Phase 1: GitHubService Swift 6.0 Concurrency 에러 수정
**커밋**: `f27e079 - fix: GitHubService Swift 6.0 concurrency 에러 수정`

**변경 사항**:
```swift
// Before: Task<Any, Error> 사용으로 타입 캐스팅 필요
private var ongoingRequests: [String: Task<Any, Error>] = [:]

// After: 구체적 타입으로 분리
private var searchTasks: [String: Task<GitHubSearchResponse, any Error>] = [:]
private var repoTasks: [String: Task<GitHubRepository, any Error>] = [:]
```

**결과**: ✅ GitHubService 빌드 성공

---

## 🚧 시도했으나 실패한 작업

### Phase 2-4: DesignSystem 컴포넌트 추가 시도
**시도 내용**:
1. `Icons+.swift`, `Color+.swift`에서 DesignSystemAsset 참조 제거
2. TextField에서 Entity.UI 타입 의존성 제거 (TextFieldTypes.swift 생성)
3. GitHubRepository용 공통 컴포넌트 추가:
   - `RepositoryRow.swift`
   - `AvatarView.swift`
   - `StatCard.swift`
   - `SearchBarView.swift`
   - `EmptyStateView.swift`
   - `LoadingOverlay.swift`
   - `RepositoryTableViewCell.swift` (UIKit)

**실패 원인**:
- Tuist generate 실패 (순환 의존성)
- Entity.UI 타입이 존재하지 않음
- 기존 DesignSystem 컴포넌트들의 Entity.UI 의존성 제거 필요
- CheckBox, Button, TopBar 등 다수 파일 수정 필요

**롤백**: git reset --hard로 원래 상태로 복구 (HEAD: 3cf8e56)

---

## 📊 Core 모듈 빌드 상태

| 모듈 | 빌드 상태 | Swift 6.0 에러 | 비고 |
|------|----------|---------------|------|
| Logger | ✅ SUCCESS | 0 | 완료 |
| Utility | ✅ SUCCESS | 0 | 완료 |
| NetworkKit | ✅ SUCCESS | 0 | 완료 |
| CacheKit | ✅ SUCCESS | 0 | 완료 |
| CoreKit | ✅ SUCCESS | 0 | 완료 |
| Entity | ✅ SUCCESS | 0 | 완료 |
| GitHubService | ✅ SUCCESS | 0 | 완료 (이번 작업) |
| **DesignSystem** | ⚠️ 구조적 이슈 | Entity.UI 의존성 | 보류 |

---

## 🎯 다음 단계 제안

### Option 1: DesignSystem Entity.UI 의존성 완전 제거 (추천)
1. `Entity.UI` 타입들을 DesignSystem 내부로 이동
2. CheckBox, TextField, Button 등 모든 컴포넌트 수정
3. DesignSystemAsset 번들 문제 해결 (SwiftGen 또는 시스템 컬러로 대체)
4. **예상 소요 시간**: 2-3시간

### Option 2: DesignSystem 우회하고 Feature 모듈 직접 빌드
1. Feature 모듈들이 DesignSystem 없이도 빌드 가능한지 확인
2. MVVM, TCA, Reactor 각각 독립적으로 빌드 테스트
3. 공통 컴포넌트는 각 Feature 내부에서 중복 구현
4. **예상 소요 시간**: 1-2시간

### Option 3: DesignSystem 최소화 접근
1. 문제있는 컴포넌트들(CheckBox, TextField, Button 등) 임시 비활성화
2. GitHubRepository용 최소 컴포넌트만 추가 (3-4개)
3. Feature 모듈 빌드 진행
4. **예상 소요 시간**: 1시간

---

## 💡 권장사항

현재 상황에서는 **Option 2 (DesignSystem 우회)**를 먼저 시도하는 것이 합리적입니다:

**이유**:
1. Core 모듈들은 모두 빌드 성공
2. Feature 모듈들은 DesignSystem의 문제있는 컴포넌트들을 사용하지 않을 가능성 높음
3. 빠르게 Feature 모듈 빌드 테스트 진행 가능
4. DesignSystem 리팩토링은 별도 작업으로 진행 가능

**진행 순서**:
1. GitHubSearchMVVM 빌드 테스트
2. GitHubSearchTCA 빌드 테스트
3. GitHubSearchReactor 빌드 테스트
4. 빌드 성공 후 DesignSystem 리팩토링 논의

---

## 📌 참고 정보

- **Git 상태**: develop 브랜치, HEAD at 3cf8e56
- **Tuist**: v4.70.0
- **Swift**: 6.0.3
- **Xcode**: 16.2
- **iOS Target**: 18.0+

