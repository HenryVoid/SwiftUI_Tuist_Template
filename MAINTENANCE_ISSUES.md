# Maintenance Issues

## 2026-08-11 Cleanup Pass

### 1. PerformanceDashboard cache statistics API mismatch

**문제**
- `PerformanceDashboardView` called `ImageCache.shared.getCacheStatistics()`, but `ImageCache` did not expose that API.
- The call also crossed an actor boundary without `await`.

**결과**
- `PerformanceDashboard` could fail to compile once the scheme is generated and type-checked.
- Cache dashboard values had no backing source of truth.

**해결**
- Added `ImageCache.CacheStatistics` and `getCacheStatistics()`.
- Updated `PerformanceDashboardViewModel.loadData()` to call the actor-isolated API with `await`.
- Added lightweight hit/miss and cached image size tracking inside `ImageCache`.

### 2. CacheKit and Logger forced initialization

**문제**
- `ImageCache` used `try! DiskCache(...)`.
- `AdvancedLogger.shared` used `try! AdvancedLogger()`.

**결과**
- Cache directory or log storage initialization failures could crash the app during shared instance creation.

**해결**
- `ImageCache` now falls back to memory-only behavior when disk cache creation fails.
- `AdvancedLogger.shared` now uses a fallback logger instead of force-trying initialization.

### 3. DesignSystem font loading crash risk

**문제**
- `DesignSystem/Project.swift` keeps resources disabled, while `Font+.swift` force-unwrapped Pretendard font loading.

**결과**
- Missing bundled fonts could crash views that apply DesignSystem typography.

**해결**
- Added a system font fallback for every `FontWeight`.

### 4. Tuist dependency declaration drift

**문제**
- `CoreKit` and `NetworkKit` declared dependencies that their sources did not import.
- `DesignSystem` declared `ThirdPartyLibrary` even though no source imported it.

**결과**
- The module graph overstated coupling and kept placeholder modules alive.

**해결**
- Removed unused Tuist target dependencies based on source import checks.

### 5. Build and test verification blocked by local execution environment

**문제**
- `XcodeRefreshCodeIssuesInFile` returned `SourceEditor.SourceEditorCallableDiagnosticError error 2` for changed files.
- `BuildProject` started a build but could not locate the resulting build log.
- `mise exec -- tuist test CoreKit` initially failed because Tuist tried to write under `~/.cache/tuist`, which is not writable in this sandbox.
- Retrying with `XDG_CACHE_HOME=/tmp/tuist-cache` moved past the cache error, but Tuist reported missing external dependencies.
- `tuist install` was then blocked by SwiftPM sandbox/write errors and `sandbox-exec: sandbox_apply: Operation not permitted`.

**결과**
- Commit 5 test changes could not be fully verified by running Tuist tests in this session.
- The observed failures are environment/setup failures before project tests execute, not XCTest assertion failures.

**해결**
- Documented the blocked commands and their results here.
- Kept test changes minimal and limited to public API behavior.
- Follow-up verification should run outside this restricted sandbox with:
  - `mise trust`
  - `tuist install`
  - `tuist test CoreKit`
  - `tuist test Entity`

### 6. Template placeholders and legacy scaffold

**문제**
- `ThirdPartyLibrary/Sources/file.swift`, `Auth/Sources/File.swift`, and `Base/Sources/File.swift` were placeholder-only files.
- Root-level `MyApp/` was not referenced by `Workspace.swift`, which points to `Projects/MyApp`.
- `graph.png` had no source or documentation references.

**결과**
- The template structure was harder to audit because placeholder and legacy scaffold files looked like active project surface.

**해결**
- Placeholder and legacy files are removed in the cleanup commit after their references are checked.
