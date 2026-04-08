# QA Report — MotivationRun

**날짜:** 2026-03-04 (초판) → 2026-04-02 (Pro IAP 추가 후 재검증)
**대상:** HealthKit 전환 후 전체 코드베이스 + Pro 인앱 구매 기능
**판정:** **Pass**

---

## Pro 인앱 구매 추가 검증 (2026-04-02)

| ID | 파일 | 심각도 | 내용 | 상태 |
|----|------|--------|------|------|
| PRO-001 | StoreManager.swift | High | `nonisolated deinit` Swift 5.x 미지원 → deinit 제거 | ✅ 수정 |
| PRO-002 | StoreManager.swift | High | `Task.detached`에서 `@MainActor` 메서드 `await` 누락 → `Task` 변경 | ✅ 수정 |
| PRO-003 | SharedDataManager.swift | Medium | `isWidgetBgDark()` force unwrap → guard let | ✅ 수정 |
| PRO-004 | ContentView.swift | - | 위젯 사진 크롭 `cgImage.cropping` orientation 미반영 → `UIGraphicsImageRenderer` | ✅ 수정 |
| PRO-005 | pbxproj | - | StoreManager.swift, Products.storekit, StoreKit.framework 타겟 등록 | ✅ 완료 |

### Pro 기능 검증 항목

| 카테고리 | 상태 |
|----------|------|
| StoreKit 2 구매 흐름 | Pass |
| 구매 복원 (AppStore.sync) | Pass |
| 트랜잭션 리스너 (Transaction.updates) | Pass |
| Pro 상태 App Group 공유 (위젯) | Pass |
| 위젯 배경 사진 게이팅 | Pass |
| 잠금화면 위젯 게이팅 | Pass |
| Pro 미구매 시 UI (잠금 표시) | Pass |
| Pro 구매 후 UI (섹션 숨김 + 배지) | Pass |
| 데이터 초기화 시 Pro 상태 유지 | Pass |
| 6개 언어 Pro 문자열 (10키 × 6언어) | Pass |

---

## 수정 완료 이슈 (초판 2026-03-04)

| ID | 파일 | 심각도 | 내용 | 상태 |
|----|------|--------|------|------|
| CRITICAL-001 | HealthKitService.swift | Critical | `quantityType` 강제 언래핑 → lazy + compactMap | ✅ 수정 |
| CRITICAL-002 | HealthKitService.swift | Critical | `calendar.date(from:)` 강제 언래핑 → guard let | ✅ 수정 |
| CRITICAL-003 | ContentView.swift | Critical | `Color(hex:)` 잘못된 입력 방어 추가 | ✅ 수정 |
| CRITICAL-004 | MotivationRunWidget.swift | Critical | `WidgetStats` 날짜 계산 강제 언래핑 → guard | ✅ 수정 |
| CRITICAL-005 | MotivationRunWidget.swift | Critical | `Provider.getTimeline` 날짜 강제 언래핑 → `??` | ✅ 수정 |
| HIGH-001 | SharedDataManager.swift | High | `UserDefaults` 매 접근 재생성 → `lazy var` | ✅ 수정 |
| HIGH-002 | HealthKitService.swift | High | `private init()` 추가 (singleton 보호) | ✅ 수정 |
| HIGH-003 | HealthKitService.swift | High | 쿼리 end 범위를 `now` → `startOfNextMonth` 수정 | ✅ 수정 |
| HIGH-004 | ContentView.swift | High | `remainingDays` 이중 강제 언래핑 → guard let | ✅ 수정 |
| HIGH-005 | ContentView.swift | High | 목표 저장 실패 시 인라인 에러 메시지 추가 | ✅ 수정 |
| HIGH-006 | ContentView.swift | High | `.sharingAuthorized` 오용 → `hasRequestedAuthorization()` 캐시 기반 | ✅ 수정 |
| HIGH-007 | MotivationRunWidget.swift | High | `WidgetStats` computed property → body 내 단일 생성 | ✅ 수정 |

## 수정 완료 Medium/Low 이슈

| ID | 심각도 | 내용 | 상태 |
|----|--------|------|------|
| MEDIUM-001 | Medium | `synchronize()` 불필요 호출 제거 (3곳) | ✅ 수정 |
| MEDIUM-002 | Medium | `getRunFrequency()` rawValue 0 기본값 명시적 처리 | ✅ 수정 |
| MEDIUM-007 | Medium | `DateFormatter` 매 호출 재생성 → static 캐싱 | ✅ 수정 |
| MEDIUM-008 | Medium | 진행 바 텍스트 경계 초과 방지 | ✅ 수정 |
| LOW-003 | Low | `SharedDataManager` `private init()` 추가 | ✅ 수정 |
| LOW-004 | Low | `navigationBarItems` deprecated → `.toolbar` | ✅ 수정 |
| LOW-005 | Low | `GoalSettingView` @Binding → 로컬 @State (취소 시 롤백) | ✅ 수정 |
| LOW-006 | Low | `switch family { default }` → `case .systemMedium` 명시 | ✅ 수정 |

## 잔여 이슈 (수용 가능)

| ID | 심각도 | 내용 | 판단 |
|----|--------|------|------|
| LOW-001 | Low | `paceString` 0값 미구분 (`"0'00\""` 출력) | 현재 UI에 paceString 미사용, 수용 |
| LOW-002 | Low | duration 단위 혼용 주석 분산 | 코드는 정상 동작, 수용 |
| MEDIUM-003 | Medium | iOS 16 분기 nil 시 로깅 없음 | 기능 정상, 디버깅 편의 수준, 수용 |
| MEDIUM-004 | Medium | 중복 main queue dispatch 가능성 | 기능 정상, 수용 |
| MEDIUM-009 | Medium | 미사용 `AppIntent.swift` 잔류 | 빌드 무관, 수용 |

---

## 최종 판정: **Pass**

초판: Critical 5건, High 7건 전부 수정 완료.
Pro IAP 추가: High 2건, Medium 1건, 기능 개선 1건 수정 완료.
잔여 이슈는 모두 기능 정상 범위의 Low/Medium으로, 출시 블로커 없음.
