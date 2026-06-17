# RunSessionDetailView Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 로그 탭의 러닝 카드를 탭하면 상세 스탯 + 운동일지(난이도 슬라이더 + 3줄 마음일기)를 보여주는 Push Navigation 화면을 구현한다.

**Architecture:** `RunSession`에 `hkWorkoutID: UUID?`를 추가해 HealthKit의 안정적인 워크아웃 ID를 저장하고, `RunJournalEntry`를 UserDefaults에 `[hkWorkoutID: entry]` 딕셔너리로 저장한다. LogView의 카드를 `NavigationLink`로 감싸고, 새 `RunSessionDetailView`에서 스탯과 일지를 표시한다.

**Tech Stack:** Swift 5.9, SwiftUI, HealthKit, StoreKit 2, XCTest, UserDefaults (App Group)

---

## File Map

| 파일 | 역할 |
|------|------|
| `code/MotivationRun/Models.swift` | RunSession에 hkWorkoutID 추가, RunJournalEntry 신규 |
| `code/MotivationRun/SharedDataManager.swift` | 일지 저장/불러오기 메서드 추가 |
| `code/MotivationRun/HealthKitService.swift` | RunSession 생성 시 workout.uuid 전달 |
| `code/MotivationRun/LocalizedStrings.swift` | 난이도 레이블·섹션 제목 등 LK 케이스 + 번역 추가 |
| `code/MotivationRun/LogView.swift` | RunSessionCard를 NavigationLink로 감싸기 |
| `code/MotivationRun/RunSessionDetailView.swift` | **신규** — 상세 화면 전체 |
| `code/MotivationRunTests/MotivationRunTests.swift` | RunJournalEntry Codable 테스트 |

---

## Task 1: Data Model — RunJournalEntry + hkWorkoutID

**Files:**
- Modify: `code/MotivationRun/Models.swift`
- Test: `code/MotivationRunTests/MotivationRunTests.swift`

- [ ] **Step 1: Write the failing tests**

`MotivationRunTests.swift` 파일 내 기존 `testExample` 아래에 추가:

```swift
func testRunJournalEntryRoundTrip() throws {
    let original = RunJournalEntry(difficulty: 0.75, diary: "힘들었지만 완주!", updatedAt: Date(timeIntervalSince1970: 0))
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(RunJournalEntry.self, from: data)
    XCTAssertEqual(decoded.difficulty, 0.75)
    XCTAssertEqual(decoded.diary, "힘들었지만 완주!")
    XCTAssertEqual(decoded.updatedAt, Date(timeIntervalSince1970: 0))
}

func testRunSessionDecodesWithoutHkWorkoutID() throws {
    // 구형 JSON에 hkWorkoutID 없어도 nil로 복원되어야 함
    let json = """
    {"id":"E621E1F8-C36C-495A-93FC-0C247A3E6E5F","date":0,"distanceKm":3.5,"calories":200,"durationMinutes":30}
    """
    let data = json.data(using: .utf8)!
    let session = try JSONDecoder().decode(RunSession.self, from: data)
    XCTAssertNil(session.hkWorkoutID)
    XCTAssertEqual(session.distanceKm, 3.5)
}
```

- [ ] **Step 2: Build to confirm tests compile-fail (hkWorkoutID 아직 없음)**

```bash
xcodebuild test \
  -project code/MotivationRun.xcodeproj \
  -scheme MotivationRun \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E "error:|RunJournalEntry"
```

Expected: `error: cannot find type 'RunJournalEntry' in scope`

- [ ] **Step 3: RunSession에 hkWorkoutID 추가, RunJournalEntry 신규 추가**

`Models.swift`의 `RunSession` struct를 아래처럼 변경 (기존 computed properties 유지):

```swift
struct RunSession: Codable, Identifiable {
    var id: UUID
    var hkWorkoutID: UUID?          // ← 추가 (구 데이터: nil로 디코딩)
    var date: Date
    var distanceKm: Double
    var calories: Double
    var durationMinutes: Double

    var paceMinPerKm: Double {
        guard distanceKm > 0 else { return 0 }
        return durationMinutes / distanceKm
    }

    var paceString: String {
        let totalSeconds = Int(paceMinPerKm * 60)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes)'\(String(format: "%02d", seconds))\""
    }
}
```

같은 파일 `MonthlyStats` struct 다음에 아래 추가:

```swift
// MARK: - RunJournalEntry

struct RunJournalEntry: Codable {
    var difficulty: Double   // 0.0 – 1.0
    var diary: String
    var updatedAt: Date
}
```

- [ ] **Step 4: 테스트 실행 → PASS 확인**

```bash
xcodebuild test \
  -project code/MotivationRun.xcodeproj \
  -scheme MotivationRun \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E "testRunJournal|testRunSession|Test (Passed|Failed)"
```

Expected: `Test Passed`

- [ ] **Step 5: Commit**

```bash
git add code/MotivationRun/Models.swift code/MotivationRunTests/MotivationRunTests.swift
git commit -m "feat: add hkWorkoutID to RunSession and RunJournalEntry model"
```

---

## Task 2: SharedDataManager — Journal 저장/불러오기

**Files:**
- Modify: `code/MotivationRun/SharedDataManager.swift`

- [ ] **Step 1: `saveJournalEntry` / `loadJournalEntry` 메서드 추가**

`SharedDataManager.swift`의 마지막 `}` 바로 앞, 기존 `// MARK:` 섹션 다음에 추가:

```swift
// MARK: - RunJournalEntry

private let journalKey = "journalEntries"

func saveJournalEntry(_ entry: RunJournalEntry, for workoutID: UUID) {
    var dict = loadAllJournalEntries()
    dict[workoutID.uuidString] = entry
    guard let data = try? JSONEncoder().encode(dict) else { return }
    userDefaults?.set(data, forKey: journalKey)
}

func loadJournalEntry(for workoutID: UUID) -> RunJournalEntry? {
    loadAllJournalEntries()[workoutID.uuidString]
}

private func loadAllJournalEntries() -> [String: RunJournalEntry] {
    guard let data = userDefaults?.data(forKey: journalKey),
          let dict = try? JSONDecoder().decode([String: RunJournalEntry].self, from: data)
    else { return [:] }
    return dict
}
```

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild build \
  -project code/MotivationRun.xcodeproj \
  -scheme MotivationRun \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E "error:|BUILD (SUCCEEDED|FAILED)"
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add code/MotivationRun/SharedDataManager.swift
git commit -m "feat: add journal entry save/load to SharedDataManager"
```

---

## Task 3: HealthKitService — workout.uuid 전달

**Files:**
- Modify: `code/MotivationRun/HealthKitService.swift`

- [ ] **Step 1: `fetchAllRunningSessions` 수정**

`HealthKitService.swift`에서 `fetchAllRunningSessions` 안의 `RunSession` 생성 부분을 찾아 교체:

변경 전:
```swift
let sessions: [RunSession] = filtered.map { workout in
    RunSession(
        id: UUID(),
        date: workout.startDate,
        distanceKm: self.distanceMeters(from: workout) / 1000,
        calories: self.energyKcal(from: workout),
        durationMinutes: workout.duration / 60
    )
}
```

변경 후:
```swift
let sessions: [RunSession] = filtered.map { workout in
    RunSession(
        id: UUID(),
        hkWorkoutID: workout.uuid,
        date: workout.startDate,
        distanceKm: self.distanceMeters(from: workout) / 1000,
        calories: self.energyKcal(from: workout),
        durationMinutes: workout.duration / 60
    )
}
```

- [ ] **Step 2: `fetchMonthlyRunningStats` 수정**

같은 파일에서 `fetchMonthlyRunningStats` 안의 `sessions.append(RunSession(...))` 를 찾아 교체:

변경 전:
```swift
sessions.append(RunSession(
    id: UUID(),
    date: workout.startDate,
    distanceKm: distanceM / 1000,
    calories: kcal,
    durationMinutes: durationMin
))
```

변경 후:
```swift
sessions.append(RunSession(
    id: UUID(),
    hkWorkoutID: workout.uuid,
    date: workout.startDate,
    distanceKm: distanceM / 1000,
    calories: kcal,
    durationMinutes: durationMin
))
```

- [ ] **Step 3: 빌드 확인**

```bash
xcodebuild build \
  -project code/MotivationRun.xcodeproj \
  -scheme MotivationRun \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E "error:|BUILD (SUCCEEDED|FAILED)"
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 4: Commit**

```bash
git add code/MotivationRun/HealthKitService.swift
git commit -m "feat: pass workout.uuid as hkWorkoutID when creating RunSession"
```

---

## Task 4: LocalizedStrings — 새 LK 케이스 + 번역

**Files:**
- Modify: `code/MotivationRun/LocalizedStrings.swift`

- [ ] **Step 1: LK enum에 케이스 추가**

`LocalizedStrings.swift`에서 `case settingSectionAbout` 바로 아래, 닫는 `}` 전에 추가:

```swift
// Run detail & journal
case detailNavTitle
case journalSectionTitle
case journalDifficultyLabel
case journalDiaryLabel
case journalDiaryPlaceholder
case difficultyVeryEasy
case difficultyEasy
case difficultyModerate
case difficultyHard
case difficultyVeryHard
case journalUnavailable
```

- [ ] **Step 2: 영어 번역 추가**

`Strings.table`의 `.english: [...]` 딕셔너리 마지막 항목 뒤에 추가:

```swift
.detailNavTitle:            "Run Detail",
.journalSectionTitle:       "Journal & 3-Line Diary",
.journalDifficultyLabel:    "Effort Level",
.journalDiaryLabel:         "3-Line Diary",
.journalDiaryPlaceholder:   "How was your run today?",
.difficultyVeryEasy:        "Very Easy",
.difficultyEasy:            "Easy",
.difficultyModerate:        "Moderate",
.difficultyHard:            "Hard",
.difficultyVeryHard:        "Very Hard",
.journalUnavailable:        "Sync with HealthKit to enable journaling",
```

- [ ] **Step 3: 한국어 번역 추가**

`.korean: [...]` 딕셔너리 마지막 항목 뒤에 추가:

```swift
.detailNavTitle:            "기록 상세",
.journalSectionTitle:       "운동일지 & 3줄 마음일기",
.journalDifficultyLabel:    "운동 난이도",
.journalDiaryLabel:         "3줄 마음일기",
.journalDiaryPlaceholder:   "오늘의 러닝은 어땠나요?",
.difficultyVeryEasy:        "매우 쉬움",
.difficultyEasy:            "쉬움",
.difficultyModerate:        "보통",
.difficultyHard:            "약간 어려움",
.difficultyVeryHard:        "매우 어려움",
.journalUnavailable:        "HealthKit 재동기화 후 사용 가능",
```

- [ ] **Step 4: 독일어 번역 추가**

`.german: [...]` 딕셔너리 마지막 항목 뒤에 추가:

```swift
.detailNavTitle:            "Lauf-Details",
.journalSectionTitle:       "Tagebuch & Notiz",
.journalDifficultyLabel:    "Intensität",
.journalDiaryLabel:         "3-Zeilen-Notiz",
.journalDiaryPlaceholder:   "Wie war dein Lauf heute?",
.difficultyVeryEasy:        "Sehr leicht",
.difficultyEasy:            "Leicht",
.difficultyModerate:        "Mittel",
.difficultyHard:            "Schwer",
.difficultyVeryHard:        "Sehr schwer",
.journalUnavailable:        "Nach HealthKit-Sync verfügbar",
```

- [ ] **Step 5: 프랑스어 번역 추가**

`.french: [...]` 딕셔너리 마지막 항목 뒤에 추가:

```swift
.detailNavTitle:            "Détails du run",
.journalSectionTitle:       "Journal & note",
.journalDifficultyLabel:    "Intensité",
.journalDiaryLabel:         "Journal 3 lignes",
.journalDiaryPlaceholder:   "Comment était ton run aujourd'hui ?",
.difficultyVeryEasy:        "Très facile",
.difficultyEasy:            "Facile",
.difficultyModerate:        "Modéré",
.difficultyHard:            "Difficile",
.difficultyVeryHard:        "Très difficile",
.journalUnavailable:        "Disponible après sync HealthKit",
```

- [ ] **Step 6: 중국어 번역 추가**

`.chinese: [...]` 딕셔너리 마지막 항목 뒤에 추가:

```swift
.detailNavTitle:            "跑步详情",
.journalSectionTitle:       "运动日志 & 心情日记",
.journalDifficultyLabel:    "运动强度",
.journalDiaryLabel:         "3行心情",
.journalDiaryPlaceholder:   "今天的跑步感觉怎么样？",
.difficultyVeryEasy:        "非常轻松",
.difficultyEasy:            "轻松",
.difficultyModerate:        "适中",
.difficultyHard:            "有些困难",
.difficultyVeryHard:        "非常困难",
.journalUnavailable:        "同步 HealthKit 后可用",
```

- [ ] **Step 7: 스페인어 번역 추가**

`.spanish: [...]` 딕셔너리 마지막 항목 뒤에 추가:

```swift
.detailNavTitle:            "Detalles de carrera",
.journalSectionTitle:       "Diario & nota",
.journalDifficultyLabel:    "Esfuerzo",
.journalDiaryLabel:         "Diario 3 líneas",
.journalDiaryPlaceholder:   "¿Cómo fue tu carrera hoy?",
.difficultyVeryEasy:        "Muy fácil",
.difficultyEasy:            "Fácil",
.difficultyModerate:        "Moderado",
.difficultyHard:            "Difícil",
.difficultyVeryHard:        "Muy difícil",
.journalUnavailable:        "Disponible tras sincronizar HealthKit",
```

- [ ] **Step 8: 빌드 확인**

```bash
xcodebuild build \
  -project code/MotivationRun.xcodeproj \
  -scheme MotivationRun \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E "error:|BUILD (SUCCEEDED|FAILED)"
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 9: Commit**

```bash
git add code/MotivationRun/LocalizedStrings.swift
git commit -m "feat: add journal and difficulty localization keys (6 languages)"
```

---

## Task 5: RunSessionDetailView 신규 생성

**Files:**
- Create: `code/MotivationRun/RunSessionDetailView.swift`

> ⚠️ 파일 생성 후 Xcode에서 **Target Membership → MotivationRun 체크** 필수 (위젯 타겟 체크 불필요)

- [ ] **Step 1: 파일 생성**

`code/MotivationRun/RunSessionDetailView.swift`를 아래 내용으로 생성:

```swift
//
//  RunSessionDetailView.swift
//  MotivationRun
//

import SwiftUI

struct RunSessionDetailView: View {
    let session: RunSession
    let runNumber: Int
    let distanceUnit: DistanceUnit
    let appLanguage: AppLanguage
    let themeAccent: ThemeAccent
    let themeBackground: ThemeBackground

    @State private var difficulty: Double = 0.5
    @State private var diary: String = ""

    private func t(_ key: LK) -> String { L(key, appLanguage) }
    private var cAccent: Color { themeAccent.color }
    private var cBg: Color { themeBackground.appBg }
    private var cCard: Color { themeBackground.cardBg }
    private var cText: Color { themeBackground.mainText }
    private var cSub: Color { themeBackground.subText }

    // MARK: - Stat Formatters

    private var durationStr: String {
        let total = Int(session.durationMinutes)
        let h = total / 60
        let m = total % 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }

    private var distanceStr: String {
        String(format: "%.2f", session.distanceKm * distanceUnit.conversionFromKm)
    }

    private var paceStr: String {
        let dist = session.distanceKm * distanceUnit.conversionFromKm
        guard dist > 0 else { return "-" }
        let totalSec = Int((session.durationMinutes / dist) * 60)
        return "\(totalSec / 60)'\(String(format: "%02d", totalSec % 60))\""
    }

    private var caloriesStr: String {
        session.calories > 0 ? String(format: "%.0f", session.calories) : "-"
    }

    private var dateStr: String {
        let f = DateFormatter()
        f.locale = appLanguage.locale
        f.setLocalizedDateFormatFromTemplate("EEEdMMM")
        return f.string(from: session.date)
    }

    private func difficultyLabel(_ v: Double) -> String {
        switch v {
        case ..<0.2: return t(.difficultyVeryEasy)
        case ..<0.4: return t(.difficultyEasy)
        case ..<0.6: return t(.difficultyModerate)
        case ..<0.8: return t(.difficultyHard)
        default:     return t(.difficultyVeryHard)
        }
    }

    // MARK: - Body

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                dateHeader
                statsCard
                journalCard
                Color.clear.frame(height: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(cBg.ignoresSafeArea())
        .navigationTitle(t(.detailNavTitle))
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(themeBackground.colorScheme)
        .onAppear { loadJournal() }
        .onDisappear { saveJournal() }
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(dateStr)
                .font(.pretendard(.bold, size: 18))
                .foregroundColor(cText)
            Text("#\(runNumber)")
                .font(.pretendard(.medium, size: 13))
                .foregroundColor(cSub)
        }
        .padding(.top, 4)
    }

    // MARK: - Stats Card (2×2 grid)

    private var statsCard: some View {
        let line = themeBackground.lineColor
        return VStack(spacing: 0) {
            HStack(spacing: 0) {
                statCell(value: durationStr, unit: "", label: t(.columnTime))
                Rectangle().fill(line).frame(width: 1)
                statCell(value: distanceStr, unit: distanceUnit.symbol, label: t(.dashboardTotalDistance))
            }
            Rectangle().fill(line).frame(height: 1)
            HStack(spacing: 0) {
                statCell(value: paceStr, unit: "/\(distanceUnit.symbol)", label: t(.dashboardAvgPace))
                Rectangle().fill(line).frame(width: 1)
                statCell(value: caloriesStr, unit: "kcal", label: t(.dashboardTotalCalories))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(cCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            themeBackground.isDark ? Color.white.opacity(0.05) : Color(hex: "#0D1220").opacity(0.04),
                            lineWidth: 1
                        )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func statCell(value: String, unit: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.pretendard(.bold, size: 26))
                    .foregroundColor(cText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.pretendard(.medium, size: 11))
                        .foregroundColor(cSub)
                }
            }
            Text(label)
                .font(.pretendard(.medium, size: 11))
                .foregroundColor(cSub)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    // MARK: - Journal Card

    private var journalCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(t(.journalSectionTitle))
                .font(.pretendard(.semiBold, size: 14))
                .foregroundColor(cText)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 14)

            if session.hkWorkoutID != nil {
                difficultySection
                Rectangle()
                    .fill(themeBackground.lineColor)
                    .frame(height: 1)
                    .padding(.horizontal, 16)
                diarySection
            } else {
                Text(t(.journalUnavailable))
                    .font(.pretendard(.regular, size: 13))
                    .foregroundColor(cSub)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(cCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            themeBackground.isDark ? Color.white.opacity(0.05) : Color(hex: "#0D1220").opacity(0.04),
                            lineWidth: 1
                        )
                )
        )
    }

    private var difficultySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(t(.journalDifficultyLabel))
                    .font(.pretendard(.medium, size: 13))
                    .foregroundColor(cSub)
                Spacer()
                Text(difficultyLabel(difficulty))
                    .font(.pretendard(.medium, size: 13))
                    .foregroundColor(cAccent)
            }
            Slider(value: $difficulty, in: 0...1)
                .tint(cAccent)
            HStack {
                Text(t(.difficultyVeryEasy))
                    .font(.pretendard(.medium, size: 10))
                    .foregroundColor(themeBackground.inkOff)
                Spacer()
                Text(t(.difficultyModerate))
                    .font(.pretendard(.medium, size: 10))
                    .foregroundColor(themeBackground.inkOff)
                Spacer()
                Text(t(.difficultyVeryHard))
                    .font(.pretendard(.medium, size: 10))
                    .foregroundColor(themeBackground.inkOff)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
    }

    private var diarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(t(.journalDiaryLabel))
                .font(.pretendard(.medium, size: 13))
                .foregroundColor(cSub)
            ZStack(alignment: .topLeading) {
                if diary.isEmpty {
                    Text(t(.journalDiaryPlaceholder))
                        .font(.pretendard(.regular, size: 14))
                        .foregroundColor(themeBackground.inkOff)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $diary)
                    .font(.pretendard(.regular, size: 14))
                    .foregroundColor(cText)
                    .frame(minHeight: 80)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(themeBackground.cardSoft)
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 16)
    }

    // MARK: - Persistence

    private func loadJournal() {
        guard let wid = session.hkWorkoutID,
              let entry = SharedDataManager.shared.loadJournalEntry(for: wid) else { return }
        difficulty = entry.difficulty
        diary = entry.diary
    }

    private func saveJournal() {
        guard let wid = session.hkWorkoutID else { return }
        SharedDataManager.shared.saveJournalEntry(
            RunJournalEntry(difficulty: difficulty, diary: diary, updatedAt: Date()),
            for: wid
        )
    }
}
```

- [ ] **Step 2: Xcode에서 Target Membership 설정**

Xcode 열기 → Project Navigator에서 `RunSessionDetailView.swift` 선택 → File Inspector → Target Membership → `MotivationRun` 체크 (위젯 타겟 체크 X)

- [ ] **Step 3: 빌드 확인**

```bash
xcodebuild build \
  -project code/MotivationRun.xcodeproj \
  -scheme MotivationRun \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E "error:|BUILD (SUCCEEDED|FAILED)"
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 4: Commit**

```bash
git add code/MotivationRun/RunSessionDetailView.swift
git commit -m "feat: add RunSessionDetailView with stats and journal"
```

---

## Task 6: LogView — NavigationLink 연결

**Files:**
- Modify: `code/MotivationRun/LogView.swift`

- [ ] **Step 1: ForEach 내부의 RunSessionCard를 NavigationLink로 감싸기**

`LogView.swift`에서 아래 부분을 찾아:

```swift
ForEach(Array(group.sessions.enumerated()), id: \.element.id) { index, session in
    RunSessionCard(
        session: session,
        runNumber: group.sessions.count - index,
        distanceUnit: distanceUnit,
        language: appLanguage,
        themeBackground: themeBackground,
        cAccent: cAccent,
        cCard: cCard,
        cText: cText,
        cSub: cSub
    )
    .padding(.horizontal, 16)
    .padding(.bottom, 8)
}
```

아래로 교체:

```swift
ForEach(Array(group.sessions.enumerated()), id: \.element.id) { index, session in
    NavigationLink {
        RunSessionDetailView(
            session: session,
            runNumber: group.sessions.count - index,
            distanceUnit: distanceUnit,
            appLanguage: appLanguage,
            themeAccent: themeAccent,
            themeBackground: themeBackground
        )
    } label: {
        RunSessionCard(
            session: session,
            runNumber: group.sessions.count - index,
            distanceUnit: distanceUnit,
            language: appLanguage,
            themeBackground: themeBackground,
            cAccent: cAccent,
            cCard: cCard,
            cText: cText,
            cSub: cSub
        )
    }
    .buttonStyle(.plain)
    .padding(.horizontal, 16)
    .padding(.bottom, 8)
}
```

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild build \
  -project code/MotivationRun.xcodeproj \
  -scheme MotivationRun \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E "error:|BUILD (SUCCEEDED|FAILED)"
```

Expected: `BUILD SUCCEEDED`

- [ ] **Step 3: Commit**

```bash
git add code/MotivationRun/LogView.swift
git commit -m "feat: wire NavigationLink from log card to RunSessionDetailView"
```

---

## Task 7: 시뮬레이터 수동 검증

- [ ] **Step 1: 시뮬레이터에서 앱 실행**

Xcode → Product → Run (⌘R) → iPhone 16 시뮬레이터

- [ ] **Step 2: 체크리스트 확인**

| 시나리오 | 기대 동작 |
|----------|-----------|
| Log 탭 카드 탭 | 오른쪽에서 슬라이드 인, 상단 "기록 상세" 표시 |
| 스탯 카드 | 시간·거리·페이스·칼로리 2×2 표시, distanceUnit 반영 |
| 난이도 슬라이더 드래그 | 우측 레이블 실시간 변경 |
| 일기 텍스트 입력 | 키보드 올라오고 TextEditor에 입력됨 |
| 뒤로가기 → 다시 진입 | 저장된 난이도 + 일기 복원됨 |
| 구형 세션(hkWorkoutID = nil) | 일지 카드에 "HealthKit 재동기화 후 사용 가능" 표시 |
| 다크/라이트 테마 전환 | 상세 화면도 테마 반영 |
| 거리 단위 km↔mi 전환 | 상세 화면 페이스·거리 단위 즉시 반영 |

- [ ] **Step 3: 최종 Commit (필요 시)**

이전 단계에서 미처 포함되지 않은 파일이 있다면 커밋. 모두 완료됐으면 생략.

---

## 자체 검토 결과

**Spec 커버리지:**
- ✅ hkWorkoutID 추가 (Task 1, 3)
- ✅ RunJournalEntry 신규 (Task 1)
- ✅ SharedDataManager journal 저장/불러오기 (Task 2)
- ✅ HealthKitService 두 메서드 모두 수정 (Task 3)
- ✅ 6개 언어 번역 (Task 4)
- ✅ RunSessionDetailView 2×2 스탯 + 슬라이더 + 일기 (Task 5)
- ✅ NavigationLink 연결 (Task 6)
- ✅ onDisappear 자동 저장 (Task 5)
- ✅ hkWorkoutID == nil graceful fallback (Task 5)
- ✅ Props: session, runNumber, distanceUnit, appLanguage, themeAccent, themeBackground (Task 5, 6)

**Out of Scope (구현 안 함):**
- 걷기/달리기 페이스 분리, 날씨, 러닝화, 같이 뛴 사람, "운동 상세 정보" 버튼
