# RunSessionDetailView — Design Spec
**Date:** 2026-06-17  
**Status:** Approved

---

## Overview

로그 탭의 RunSession 카드를 탭하면 해당 러닝의 상세 스탯과 운동일지를 볼 수 있는 화면. Push Navigation으로 진입하며, 사용자가 직접 운동 난이도와 3줄 마음일기를 작성·저장할 수 있다.

---

## Data Model Changes

### 1. `RunSession` — `hkWorkoutID` 필드 추가

```swift
struct RunSession: Codable, Identifiable {
    var id: UUID
    var hkWorkoutID: UUID?   // 추가 (optional — 구 데이터 하위 호환)
    var date: Date
    var distanceKm: Double
    var calories: Double
    var durationMinutes: Double
    // ...기존 computed properties 유지
}
```

- `HealthKitService`의 `fetchAllRunningSessions` 및 `fetchMonthlyRunningStats` 양쪽에서 `RunSession` 생성 시 `hkWorkoutID: workout.uuid` 할당
- `id`는 기존대로 `UUID()` 유지 (Identifiable용), `hkWorkoutID`가 일지 연결 키

### 2. `RunJournalEntry` — 새 struct

```swift
struct RunJournalEntry: Codable {
    var difficulty: Double   // 0.0 – 1.0 (연속값, 슬라이더)
    var diary: String        // 자유 텍스트 (줄 수 제한 없음, UI에서 3줄 높이 권장)
    var updatedAt: Date
}
```

**Difficulty 레이블 매핑:**

| 범위 | 한국어 | 영어 |
|------|--------|------|
| 0.0 – 0.2 | 매우 쉬움 | Very Easy |
| 0.2 – 0.4 | 쉬움 | Easy |
| 0.4 – 0.6 | 보통 | Moderate |
| 0.6 – 0.8 | 약간 어려움 | Hard |
| 0.8 – 1.0 | 매우 어려움 | Very Hard |

---

## Persistence

### `SharedDataManager` — 저장/불러오기 메서드 추가

- 저장소: `UserDefaults(suiteName: appGroupID)`
- 키: `"journalEntries"` → `Data` (JSON 인코딩된 `[String: RunJournalEntry]`)
- Dictionary 키: `hkWorkoutID.uuidString`

```swift
func saveJournalEntry(_ entry: RunJournalEntry, for workoutID: UUID)
func loadJournalEntry(for workoutID: UUID) -> RunJournalEntry?
```

- `hkWorkoutID`가 없는 구형 `RunSession`은 일지 저장/불러오기 불가 → UI에서 graceful fallback (일지 섹션 비활성 처리)

---

## UI — `RunSessionDetailView`

### 진입
- `LogView`의 `RunSessionCard`를 `NavigationLink`로 감싸기
- Navigation title: `"기록 상세"` (현재 언어에 따라 로컬라이즈)

### 레이아웃

```
NavigationBar: ← 뒤로  |  기록 상세
────────────────────────────────────
[날짜 헤더]
  "화, 12월 17일"
  "#12번째 러닝"

[스탯 카드 — 2×2 그리드]
  ┌──────────┬──────────┐
  │ 30:30    │ 3.46 km  │
  │ 시간     │ 거리     │
  ├──────────┼──────────┤
  │ 8'48"    │ 198 kcal │
  │ 평균페이스│ 칼로리   │
  └──────────┴──────────┘

[운동일지 카드]
  "운동일지 & 3줄 마음일기"

  운동 난이도           [약간 어려움]
  ●────────────○──○──○
  매우 쉬움  보통  매우 어려움

  ─────────────────────
  3줄 마음일기
  ┌────────────────────┐
  │ 추워서얼~~~         │
  │ 그리고 2:30 슬슬 힘듦│
  │ 그냥 오랜만이라...  │
  └────────────────────┘
  (자동 저장 — onDisappear)
```

### 뷰 초기화 Props

```swift
struct RunSessionDetailView: View {
    let session: RunSession
    let runNumber: Int             // LogView에서 계산된 번호 (#N)
    let distanceUnit: DistanceUnit
    let appLanguage: AppLanguage
    let themeAccent: ThemeAccent
    let themeBackground: ThemeBackground
}
```

### 편집 & 저장 동작
- 화면 진입 시 `hkWorkoutID`로 기존 `RunJournalEntry` 조회 → 있으면 슬라이더·일기 복원
- 슬라이더·일기 텍스트는 `@State`로 관리, 즉시 UI 반영
- **저장 버튼 없음** — `.onDisappear`에서 `hkWorkoutID != nil`이면 자동 저장
- `hkWorkoutID == nil`인 구형 세션: 일지 카드 비활성화, "HealthKit 재동기화 후 사용 가능" 안내 텍스트 표시

### 언어 지원
- 날짜 포맷: `appLanguage.locale` 사용 (기존 패턴 동일)
- 난이도 레이블: `LocalizedStrings.swift`에 5단계 키 추가
- 섹션 제목 "운동일지 & 3줄 마음일기": `LocalizedStrings.swift` 추가

---

## 변경 파일 목록

| 파일 | 변경 내용 |
|------|-----------|
| `Models.swift` | `RunSession`에 `hkWorkoutID: UUID?` 추가, `RunJournalEntry` struct 추가 |
| `HealthKitService.swift` | `fetchAllRunningSessions` + `fetchMonthlyRunningStats` → `hkWorkoutID: workout.uuid` 할당 |
| `SharedDataManager.swift` | `saveJournalEntry` / `loadJournalEntry` 추가 |
| `LocalizedStrings.swift` | 난이도 5단계 레이블, 섹션 제목 등 키 추가 |
| `LogView.swift` | `RunSessionCard`를 `NavigationLink`로 감싸기 |
| `RunSessionDetailView.swift` | **신규** — 상세 화면 전체 |

---

## Out of Scope

- 걷기/달리기 페이스 분리
- 날씨 자동/수동 입력
- 러닝화 관리
- 같이 뛴 사람 수
- "운동 상세 정보" 버튼 (외부 앱 연결)
- CoreData 도입
