# Dead Code 검증 보고서 — MotivationRun

**날짜:** 2026-03-21
**대상:** `/code/` 전체 코드베이스
**방침:** 코드 수정 없음 — 현행 코드 기준 분석만 수행

---

## 요약

| 심각도 | 건수 | 설명 |
|--------|------|------|
| HIGH   | 2    | 제거된 기능의 잔여 코드 (Streak, Strava) |
| MEDIUM | 5    | 미사용 로컬라이제이션 키, 미사용 함수 |
| LOW    | 4    | Stub 파일, 보일러플레이트 코드 |

---

## HIGH — 제거된 기능의 잔여 코드

### H-001. Streak 기능 잔여 코드

대시보드에서 Streak 카드가 제거되었으나, 백엔드 로직과 데이터 모델이 그대로 남아 있음.

| 파일 | 위치 | 내용 |
|------|------|------|
| `Models.swift` | 216-221행 | `struct StreakData` 정의 (4개 필드) |
| `SharedDataManager.swift` | 122-174행 | `saveStreakData()`, `getStreakData()`, `updateStreak(stats:)` |
| `SharedDataManager.swift` | 263행 | `resetAll()`에서 `"streakData"` 키 제거 포함 |
| `ContentView.swift` | 696행 | `updateStreak(stats:)` 호출 (동기화 후) |

**상태:** `updateStreak`은 동기화 시 여전히 호출되어 UserDefaults에 데이터를 기록하지만, 이 데이터를 읽어서 UI에 표시하는 곳이 없음. 즉, 쓰기만 하고 읽지 않는 상태.

**관련 미사용 로컬라이제이션 키:**
- `.consecutiveGoal` — "Streak" / "연속 달성"
- `.bestRecord` — "Best" / "최장 기록"
- `.totalAchieved` — "Total" / "누적 달성"
- `.monthsUnit` — "mo" / "개월"

---

### H-002. Strava / AppDelegate 잔여 코드

Strava → HealthKit 전환 후 AppDelegate의 OAuth 콜백 처리 코드가 남아 있음.

| 파일 | 위치 | 내용 |
|------|------|------|
| `AppDelegate.swift` | 9-16행 | `application(_:open:options:)` — Strava OAuth 콜백 처리 |

**문제점:**
1. `MotivationRunApp.swift`에 `@UIApplicationDelegateAdaptor` 선언이 없어 AppDelegate 자체가 연결되지 않음
2. `"StravaOAuthCallback"` NotificationCenter 옵저버가 어디에도 없음
3. Strava 서비스가 완전히 제거된 상태

---

## MEDIUM — 미사용 로컬라이제이션 키

### M-001. 제거된 UI 요소의 로컬라이제이션 키 (13건)

아래 `LK` enum case들은 6개 언어 번역이 모두 존재하지만, 코드에서 `L(.key, lang)` 형태로 참조하는 곳이 없음.

| LK case | 원래 용도 | 제거 사유 |
|---------|-----------|-----------|
| `thisMonthTotal` | 메인 카드 "이번 달 누적" | 메인 카드 제거 |
| `goalPrefix` | 메인 카드 "목표" | 메인 카드 제거 |
| `perRunNeeded` | 메인 카드 "러닝 필요" | 메인 카드 제거 |
| `progressRate` | 메인 카드/위젯 "달성률" | 대시보드에서 미사용 |
| `remainingPrefix` | 메인 카드 "남은" | 대시보드에서 미사용 |
| `accentColorSection` | 설정 섹션 헤더 | "General"로 하드코딩 변경 |
| `distUnitNote` | 거리 단위 안내 문구 | 설정 UI 리디자인으로 제거 |
| `healthKitSection` | 설정 섹션 헤더 | "Data"로 하드코딩 변경 |
| `reconnecting` | "연동 중..." 텍스트 | `isReconnecting` + ProgressView로 대체 |
| `appInfoSection` | 설정 섹션 헤더 | 별도 섹션 없이 통합 |
| `dashboardRecentRuns` | "최근 러닝" 헤더 | Recent Runs 섹션 제거 |
| `dashboardNoData` | "기록 없음" 메시지 | Recent Runs 섹션 제거 |
| `dashboardSeeAll` | "전체보기" 버튼 | Recent Runs 섹션 제거 |

---

### M-002. 삭제된 위젯 디자인의 로컬라이제이션 키 (2건)

`WidgetDesign` enum에서 `detailed`, `focus` case가 제거되었으나 번역 키가 남아 있음.

| LK case | 6개 언어 번역 존재 | Models.swift enum case |
|---------|-------------------|----------------------|
| `widgetDesignDetailed` | 있음 | **없음** (제거됨) |
| `widgetDesignFocus` | 있음 | **없음** (제거됨) |

---

### M-003. 미사용 로컬라이제이션 키 — 위젯 메타데이터 (2건)

| LK case | 용도 | 상태 |
|---------|------|------|
| `widgetName` | 위젯 display name | 위젯에서 하드코딩 `"MyMileage"` 사용 |
| `widgetDescription` | 위젯 설명 | 위젯에서 하드코딩 문자열 사용 |

---

### M-004. 미사용 로컬라이제이션 키 — 설정 섹션 헤더 (1건)

| LK case | 용도 | 상태 |
|---------|------|------|
| `widgetBgSection` | 위젯 배경 섹션 헤더 | "Widget"으로 하드코딩 변경 |

---

### M-005. 미사용 함수 (1건)

| 파일 | 위치 | 함수 |
|------|------|------|
| `NotificationManager.swift` | 31-35행 | `getAuthorizationStatus(completion:)` |

정의만 존재하고 호출하는 곳이 없음.

---

## LOW — Stub 파일 및 보일러플레이트

### L-001. 빈 Stub 파일 (2건)

| 파일 | 내용 |
|------|------|
| `StravaService.swift` | 주석만 존재 ("HealthKit 전환으로 더 이상 사용되지 않습니다") |
| `KeychainManager.swift` | 주석만 존재 (동일) |

빌드 대상에서 제외된 상태이므로 기능에 영향 없음. 프로젝트 정리 차원의 제거 대상.

---

### L-002. Xcode 템플릿 보일러플레이트 (1건)

| 파일 | 위치 | 내용 |
|------|------|------|
| `MotivationRunWidget/AppIntent.swift` | 11-18행 | `ConfigurationAppIntent` struct |

Xcode 위젯 템플릿이 자동 생성한 예제 코드. 실제 위젯은 `StaticConfiguration`을 사용하므로 이 Intent는 참조되지 않음.

---

### L-003. 미사용 테스트 파일 (3건)

| 파일 | 상태 |
|------|------|
| `MotivationRunTests/MotivationRunTests.swift` | Xcode 기본 생성 템플릿, 실제 테스트 없음 |
| `MotivationRunUITests/MotivationRunUITests.swift` | Xcode 기본 생성 템플릿, 실제 테스트 없음 |
| `MotivationRunUITests/MotivationRunUITestsLaunchTests.swift` | Xcode 기본 생성 템플릿, 실제 테스트 없음 |

---

## 참고 — 미사용 아닌 항목 (오탐 방지)

아래 항목들은 미사용으로 보일 수 있으나 실제로 사용 중임을 확인함.

| 항목 | 확인 결과 |
|------|-----------|
| `thisMonthActivities` | `ContentView.swift:617`에서 사용 중 |
| `StreakData` 구조체 | `updateStreak()`에서 사용 중 (H-001에서 별도 보고) |
| `paceString` (RunSession) | LogView의 RunSessionCard에서 자체 계산 사용, Models.swift의 `paceString`은 미사용이나 모델 API로 유지 가능 |

---

## 결론

- **기능에 영향을 주는 버그:** 없음
- **빌드 오류 위험:** 없음 (미사용 코드가 컴파일은 되지만 실행 경로에 영향 없음)
- **정리 권장 우선순위:** H-001 (Streak 잔여) → M-001~M-004 (미사용 LK 키) → H-002 (AppDelegate) → 나머지
- **총 미사용 로컬라이제이션 키:** 19건 (6개 언어 × 19 = 114개 번역 엔트리)
