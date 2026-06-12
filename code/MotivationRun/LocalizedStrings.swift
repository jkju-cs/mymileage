//
//  LocalizedStrings.swift
//  MotivationRun
//
//  ⚠️ 메인 앱 타겟 + 위젯 타겟 양쪽 Target Membership 체크 필수
//

import Foundation

// MARK: - Localization Key

enum LK: String {
    // App
    case appTitle
    // Header
    case monthYearDateFormat        // date format string
    // Main card
    case daysLeftFmt                // "%d일 남음" / "%d days left"
    // Run frequency labels (short)
    case freqDailyLabel
    case freqEveryOtherLabel
    case freqEvery3DaysLabel
    // Run frequency in card ("매일 러닝 시" style)
    case freqDailyRun
    case freqEveryOtherRun
    case freqEvery3DaysRun
    // Info cards
    case thisMonthActivities
    // Sync
    case lastSyncLabel
    case syncingLabel
    case syncWithHealthKit
    case allowHealthKit
    // Goal button / sheet
    case setGoalButton
    case goalTypeSection
    case goalTargetSection
    case runFreqSection
    case cancelButton
    case saveButton
    case goalNavTitle
    case inputErrorMsg
    // GoalType names
    case goalTypeDistance
    case goalTypeCalories
    case goalTypeDuration
    // Duration unit (for display)
    case durationUnit               // "시간" / "hr"
    // Distance unit labels
    case unitKilometer
    case unitMile
    // ThemeBackground labels
    case themeDark
    case themeLight
    // Settings
    case settingsTitle
    case bgThemeSection
    case distUnitSection
    case notificationsSection
    case goalReminderToggle
    case d7NotifLabel
    case d3NotifLabel
    case d1NotifLabel
    case notifPermError
    case reconnectHK
    case forceRefreshWidget
    case versionLabel
    case resetDataButton
    case resetConfirmMsg
    case resetConfirmButton
    case languageSection
    // Placeholders
    case placeholderDistKm
    case placeholderDistMile
    case placeholderCal
    case placeholderDur
    // Widget
    case widgetTotalGoal
    case widgetRemainingPrefix
    case widgetPerRunUnit
    // Notifications (format strings with %@/%d)
    case notifTitle
    case notifBodyDaysFmt           // "%@ remaining. Run in %d days! 💪"
    case notifBodyLastDay           // "%@ remaining. Last chance tomorrow! 💪"
    // Help
    case helpTitle
    // Help — section headers
    case helpSectionStart
    case helpSectionFeatures
    case helpSectionWidget
    case helpSectionTips
    // Help — getting started steps
    case helpStep1Title
    case helpStep1Desc
    case helpStep2Title
    case helpStep2Desc
    case helpStep3Title
    case helpStep3Desc
    // Help — core features
    case helpFeatGoalTitle
    case helpFeatGoalDesc
    case helpFeatFreqTitle
    case helpFeatFreqDesc
    case helpFeatUnitTitle
    case helpFeatUnitDesc
    // Help — widget & notifications
    case helpWidgetTitle
    case helpWidgetDesc
    case helpNotifTitle
    case helpNotifDesc
    // Help — tips
    case helpTip1
    case helpTip2
    case helpTip3
    // Date formats (for widget)
    case longDateFormat             // "M월 d일"
    case shortDateFormat            // "M/d"
    // Tab labels
    case tabDashboard
    case tabLog
    case tabCalendar
    case tabSettings
    // Widget design
    case widgetDesignSection
    case widgetDesignMinimal
    case widgetDesignCompact
    case widgetDesignBalanced
    case widgetDesignComplete
    // Dashboard — month navigation & summary
    case dashboardTotalDistance
    case dashboardTotalDuration
    case dashboardTotalCalories
    case dashboardAvgPace
    case dashboardAvgDistance
    case dashboardTotalSteps
    case dashboardAvgHeartRate
    // Mileage goal banner
    case mileageGoalLabel
    // Log view
    case noRunsMsg
    case columnDate
    case columnTime
    // Toast messages
    case widgetRefreshed
    case hkReconnected
    case syncCompleted
    // Widget background
    case widgetBgSelectPhoto
    case widgetBgRemovePhoto
    case widgetBgSaved
    case widgetBgRemoved
    // Widget crop
    case widgetCropHint
    case widgetCropDone
    // Lock screen widget
    case lockWidgetName
    case lockWidgetDescription
    case lockWidgetProRequired
    // Pro
    case proSectionTitle
    case proUpgradeButton
    case proRestoreButton
    case proUnlocked
    case proPurchased
    case proRestored
    case proRestoreFailed
    case proFeaturePhoto
    case proFeatureLockWidget
    // Data Source Filter
    case dataSourceButton
    case dataSourceTitle
    case dataSourceAll
    case dataSourceSectionHeader
    case dataSourceFooter
    case dataSourceLoading
    case dataSourceSelectedSingular
    case dataSourceSelectedPlural
    // Calendar heatmap & streak
    case calLegendRest
    case calStreakLabel
    case calStreakDay
    case calStreakDays
    case calRestDay
    // Widget photo gallery
    case widgetGalleryTitle
    case widgetGalleryAddPhoto
    case widgetGalleryEdit
    case widgetGalleryDone
    case widgetGalleryMaxReached
    case widgetGalleryEmpty
}

// MARK: - Global Localization Function

func L(_ key: LK, _ lang: AppLanguage) -> String {
    Strings.table[lang]?[key] ?? Strings.table[.english]?[key] ?? key.rawValue
}

// MARK: - Translation Table

private enum Strings {
    static let table: [AppLanguage: [LK: String]] = [

        // ─────────── ENGLISH ───────────
        .english: [
            .appTitle:              "MyMileage - Every Mile Counts",
            .monthYearDateFormat:   "MMMM yyyy",
            .daysLeftFmt:           "%d days left",
            .freqDailyLabel:        "Daily",
            .freqEveryOtherLabel:   "Every 2d",
            .freqEvery3DaysLabel:   "Every 3d",
            .freqDailyRun:          "Daily run",
            .freqEveryOtherRun:     "Every 2d run",
            .freqEvery3DaysRun:     "Every 3d run",
            .thisMonthActivities:   "Activities",
            .lastSyncLabel:         "Last sync",
            .syncingLabel:          "Syncing...",
            .syncWithHealthKit:     "Sync Apple Health",
            .allowHealthKit:        "Allow Apple Health",
            .setGoalButton:         "Set Goal",
            .goalTypeSection:       "Goal Type",
            .goalTargetSection:     "Target",
            .runFreqSection:        "Run Frequency",
            .cancelButton:          "Cancel",
            .saveButton:            "Save",
            .goalNavTitle:          "Goal Setting",
            .inputErrorMsg:         "Enter a number greater than 0",
            .goalTypeDistance:      "Distance",
            .goalTypeCalories:      "Calories",
            .goalTypeDuration:      "Duration",
            .durationUnit:          "hr",
            .unitKilometer:         "Kilometer",
            .unitMile:              "Mile",
            .themeDark:             "Dark",
            .themeLight:            "Light",
            .settingsTitle:         "Settings",
            .bgThemeSection:        "Background",
            .distUnitSection:       "Distance Unit",
            .notificationsSection:  "Notifications",
            .goalReminderToggle:    "Goal Reminder",
            .d7NotifLabel:          "D-7 (7 days before, 9 AM)",
            .d3NotifLabel:          "D-3 (3 days before, 9 AM)",
            .d1NotifLabel:          "D-1 (day before, 9 AM)",
            .notifPermError:        "Notification permission required. Enable it in the Settings app.",
            .reconnectHK:           "Reconnect Apple Health",
            .forceRefreshWidget:    "Force Refresh Widget",
            .versionLabel:          "Version",
            .resetDataButton:       "Reset All Data",
            .resetConfirmMsg:       "All saved data will be deleted. This cannot be undone.",
            .resetConfirmButton:    "Reset",
            .languageSection:       "Language",
            .placeholderDistKm:     "e.g. 100",
            .placeholderDistMile:   "e.g. 62",
            .placeholderCal:        "e.g. 10000",
            .placeholderDur:        "e.g. 10",
            .widgetTotalGoal:       "Mileage Goal",
            .widgetRemainingPrefix: "Remaining",
            .widgetPerRunUnit:      "/run",
            .notifTitle:            "🏃 Monthly Goal Reminder",
            .notifBodyDaysFmt:      "%@ remaining. Run in %d days! 💪",
            .notifBodyLastDay:      "%@ remaining. Last chance tomorrow! 💪",
            .helpTitle:             "How to use MyMileage",
            .longDateFormat:        "MMMM d",
            .shortDateFormat:       "M/d",
            .tabDashboard:          "Dashboard",
            .tabLog:                "Log",
            .tabCalendar:           "Calendar",
            .tabSettings:           "Settings",
            .widgetDesignSection:   "Widget Layout",
            .widgetDesignMinimal:   "Minimal",
            .widgetDesignCompact:   "Compact",
            .widgetDesignBalanced:  "Balanced",
            .widgetDesignComplete:  "Complete",
            .dashboardTotalDistance: "Distance",
            .dashboardTotalDuration:"Duration",
            .dashboardTotalCalories:"Calories",
            .dashboardAvgPace:      "Avg Pace",
            .dashboardAvgDistance:   "Per Run",
            .dashboardTotalSteps:    "Steps",
            .dashboardAvgHeartRate:  "Avg HR",
            .mileageGoalLabel:      "Mileage Goal",
            .noRunsMsg:             "No runs recorded",
            .columnDate:            "Date",
            .columnTime:            "Time",
            .widgetRefreshed:       "Widget refreshed",
            .hkReconnected:         "Apple Health connected",
            .syncCompleted:         "Sync complete",
            .widgetBgSelectPhoto:   "Select Photo",
            .widgetBgRemovePhoto:   "Remove Photo",
            .widgetBgSaved:         "Widget background saved",
            .widgetBgRemoved:       "Widget background removed",
            .widgetCropHint:        "Pinch to zoom, drag to move",
            .widgetCropDone:        "Done",
            .lockWidgetName:        "Running Progress",
            .lockWidgetDescription: "Quick glance at your monthly running goal.",
            .lockWidgetProRequired: "Unlock in the app with Pro.",
            .proSectionTitle:       "Pro",
            .proUpgradeButton:      "Upgrade to Pro",
            .proRestoreButton:      "Restore Purchase",
            .proUnlocked:           "Pro Unlocked",
            .proPurchased:          "Pro unlocked! Thank you!",
            .proRestored:           "Purchase restored!",
            .proRestoreFailed:      "No previous purchase found.",
            .proFeaturePhoto:       "Custom widget background photo",
            .proFeatureLockWidget:  "Lock screen widgets",
            .dataSourceButton:      "Data Sources",
            .dataSourceTitle:       "Data Sources",
            .dataSourceAll:         "All Sources",
            .dataSourceSectionHeader: "Available Sources",
            .dataSourceFooter:      "Only workouts from selected sources will be counted.",
            .dataSourceLoading:     "Loading sources...",
            .dataSourceSelectedSingular: "source",
            .dataSourceSelectedPlural: "sources",
            .calLegendRest:         "Rest",
            .calStreakLabel:        "Current Streak",
            .calStreakDay:          "day",
            .calStreakDays:         "days",
            .calRestDay:            "Rest day",
            .widgetGalleryTitle:        "Widget Background",
            .widgetGalleryAddPhoto:     "Add New Photo",
            .widgetGalleryEdit:         "Edit",
            .widgetGalleryDone:         "Done",
            .widgetGalleryMaxReached:   "Up to 10 photos can be saved",
            .widgetGalleryEmpty:        "Add your first photo",
            .helpContent: """
MyMileage helps you hit your monthly running goal.

Getting Started
1. Open the Settings tab and tap "Set Goal" to choose your goal type (distance, calories, or duration) and set a monthly target.
2. Tap "Sync Apple Health" to grant permission and import your running data.
3. The Dashboard shows a daily bar chart and monthly summary for your progress.

Key Features
• Mileage Goal — The current month displays your goal and remaining days at a glance.
• Run Frequency — Choose daily, every 2 days, or every 3 days. The app calculates how much you need per session.
• Distance Unit — Switch between km and miles in Settings. Your goal converts automatically.
• Widget — Add the widget to your Home Screen. Choose from 4 layouts (Minimal, Compact, Balanced, Complete) and set a custom background photo.
• Notifications — Get reminders 7, 3, or 1 day before month-end if you haven't reached your goal yet.

Tips
• Sync regularly to keep your data up to date.
• The widget refreshes automatically every hour.
• Use the Settings tab to customize theme colors, language, and more.
""",
        ],

        // ─────────── KOREAN ───────────
        .korean: [
            .appTitle:              "MyMileage - Every Mile Counts",
            .monthYearDateFormat:   "yyyy년 M월",
            .daysLeftFmt:           "%d일 남음",
            .freqDailyLabel:        "매일",
            .freqEveryOtherLabel:   "격일",
            .freqEvery3DaysLabel:   "3일마다",
            .freqDailyRun:          "매일 러닝 시",
            .freqEveryOtherRun:     "격일 러닝 시",
            .freqEvery3DaysRun:     "3일마다 러닝 시",
            .thisMonthActivities:   "이번 달 활동",
            .lastSyncLabel:         "마지막 동기화",
            .syncingLabel:          "동기화 중...",
            .syncWithHealthKit:     "Apple Health 데이터 동기화",
            .allowHealthKit:        "Apple Health 권한 허용",
            .setGoalButton:         "목표 설정",
            .goalTypeSection:       "목표 유형",
            .goalTargetSection:     "목표",
            .runFreqSection:        "러닝 빈도",
            .cancelButton:          "취소",
            .saveButton:            "저장",
            .goalNavTitle:          "목표 설정",
            .inputErrorMsg:         "0보다 큰 숫자를 입력해주세요",
            .goalTypeDistance:      "거리",
            .goalTypeCalories:      "칼로리",
            .goalTypeDuration:      "시간",
            .durationUnit:          "시간",
            .unitKilometer:         "킬로미터",
            .unitMile:              "마일",
            .themeDark:             "다크",
            .themeLight:            "라이트",
            .settingsTitle:         "설정",
            .bgThemeSection:        "배경 테마",
            .distUnitSection:       "거리 단위",
            .notificationsSection:  "알림",
            .goalReminderToggle:    "목표 리마인더 알림",
            .d7NotifLabel:          "D-7 알림 (7일 전 오전 9시)",
            .d3NotifLabel:          "D-3 알림 (3일 전 오전 9시)",
            .d1NotifLabel:          "D-1 알림 (전날 오전 9시)",
            .notifPermError:        "알림 권한이 필요합니다. 설정 앱에서 허용해주세요.",
            .reconnectHK:           "Apple Health 재연동",
            .forceRefreshWidget:    "위젯 강제 새로고침",
            .versionLabel:          "버전",
            .resetDataButton:       "데이터 초기화",
            .resetConfirmMsg:       "모든 저장 데이터를 삭제합니다. 이 작업은 되돌릴 수 없습니다.",
            .resetConfirmButton:    "초기화",
            .languageSection:       "언어",
            .placeholderDistKm:     "예: 100",
            .placeholderDistMile:   "예: 62",
            .placeholderCal:        "예: 10000",
            .placeholderDur:        "예: 10",
            .widgetTotalGoal:       "마일리지 목표",
            .widgetRemainingPrefix: "남은",
            .widgetPerRunUnit:      "/회",
            .notifTitle:            "🏃 이번 달 목표 리마인더",
            .notifBodyDaysFmt:      "목표까지 %@ 남았습니다. %d일 안에 달려보세요! 💪",
            .notifBodyLastDay:      "목표까지 %@ 남았습니다. 내일이 마지막 기회예요! 💪",
            .helpTitle:             "MyMileage 사용법",
            .longDateFormat:        "M월 d일",
            .shortDateFormat:       "M/d",
            .tabDashboard:          "대시보드",
            .tabLog:                "기록",
            .tabCalendar:           "캘린더",
            .tabSettings:           "설정",
            .widgetDesignSection:   "위젯 레이아웃",
            .widgetDesignMinimal:   "미니멀",
            .widgetDesignCompact:   "컴팩트",
            .widgetDesignBalanced:  "밸런스",
            .widgetDesignComplete:  "컴플리트",
            .dashboardTotalDistance: "거리",
            .dashboardTotalDuration:"시간",
            .dashboardTotalCalories:"칼로리",
            .dashboardAvgPace:      "평균 페이스",
            .dashboardAvgDistance:   "회당 거리",
            .dashboardTotalSteps:    "총 걸음 수",
            .dashboardAvgHeartRate:  "평균 심박수",
            .mileageGoalLabel:      "마일리지 목표",
            .noRunsMsg:             "러닝 기록이 없습니다",
            .columnDate:            "날짜",
            .columnTime:            "시간",
            .widgetRefreshed:       "위젯 새로고침 완료",
            .hkReconnected:         "재연동 완료",
            .syncCompleted:         "동기화 완료",
            .widgetBgSelectPhoto:   "사진 선택",
            .widgetBgRemovePhoto:   "사진 제거",
            .widgetBgSaved:         "위젯 배경 저장 완료",
            .widgetBgRemoved:       "위젯 배경 제거 완료",
            .widgetCropHint:        "핀치로 확대/축소, 드래그로 이동",
            .widgetCropDone:        "완료",
            .lockWidgetName:        "러닝 현황",
            .lockWidgetDescription: "이번 달 러닝 목표를 한눈에 확인하세요.",
            .lockWidgetProRequired: "앱에서 Pro로 잠금 해제하세요.",
            .proSectionTitle:       "Pro",
            .proUpgradeButton:      "Pro 업그레이드",
            .proRestoreButton:      "구매 복원",
            .proUnlocked:           "Pro 해제 완료",
            .proPurchased:          "Pro가 해제되었습니다! 감사합니다!",
            .proRestored:           "구매가 복원되었습니다!",
            .proRestoreFailed:      "이전 구매 내역이 없습니다.",
            .proFeaturePhoto:       "위젯 배경 사진 커스텀",
            .proFeatureLockWidget:  "잠금화면 위젯",
            .dataSourceButton:      "데이터 소스",
            .dataSourceTitle:       "데이터 소스",
            .dataSourceAll:         "모든 소스",
            .dataSourceSectionHeader: "사용 가능한 소스",
            .dataSourceFooter:      "선택한 소스의 러닝 기록만 집계됩니다.",
            .dataSourceLoading:     "소스 로딩 중...",
            .dataSourceSelectedSingular: "소스",
            .dataSourceSelectedPlural: "소스",
            .calLegendRest:         "휴식",
            .calStreakLabel:        "현재 연속",
            .calStreakDay:          "일",
            .calStreakDays:         "일",
            .calRestDay:            "휴식일",
            .widgetGalleryTitle:        "위젯 배경 사진",
            .widgetGalleryAddPhoto:     "신규 사진 추가",
            .widgetGalleryEdit:         "편집",
            .widgetGalleryDone:         "완료",
            .widgetGalleryMaxReached:   "최대 10장까지 저장할 수 있습니다",
            .widgetGalleryEmpty:        "사진을 추가해보세요",
            .helpContent: """
MyMileage는 이번 달 러닝 목표를 달성할 수 있도록 도와주는 앱입니다.

시작하기
1. 설정 탭에서 '목표 설정'을 탭해 목표 유형(거리·칼로리·시간)과 월간 목표값을 입력하세요.
2. 'Apple Health 동기화'를 탭해 권한을 허용하고 러닝 데이터를 불러오세요.
3. 대시보드에서 일별 바 차트와 월간 요약으로 진행 상황을 확인하세요.

주요 기능
• 마일리지 목표 — 현재 월에는 이번 달 목표와 남은 일수가 한눈에 표시됩니다.
• 러닝 빈도 — 매일·격일·3일마다 중 선택하면 회당 필요량이 자동 계산됩니다.
• 거리 단위 — 설정에서 km와 마일을 전환할 수 있고, 목표값은 자동 변환됩니다.
• 위젯 — 홈 화면에 위젯을 추가하세요. 4가지 레이아웃(미니멀, 컴팩트, 밸런스, 컴플리트) 중 선택하고, 배경 사진도 설정할 수 있습니다.
• 알림 — 월말 7일·3일·1일 전에 목표 미달성 리마인더를 받을 수 있습니다.

도움말
• 정기적으로 동기화해 데이터를 최신 상태로 유지하세요.
• 위젯은 1시간마다 자동으로 갱신됩니다.
• 설정 탭에서 테마 색상, 언어 등을 변경할 수 있습니다.
""",
        ],

        // ─────────── GERMAN ───────────
        .german: [
            .appTitle:              "MyMileage - Every Mile Counts",
            .monthYearDateFormat:   "MMMM yyyy",
            .daysLeftFmt:           "Noch %d Tage",
            .freqDailyLabel:        "Täglich",
            .freqEveryOtherLabel:   "Alle 2 Tage",
            .freqEvery3DaysLabel:   "Alle 3 Tage",
            .freqDailyRun:          "Täglich",
            .freqEveryOtherRun:     "Alle 2 Tage",
            .freqEvery3DaysRun:     "Alle 3 Tage",
            .thisMonthActivities:   "Aktivitäten",
            .lastSyncLabel:         "Letzte Sync",
            .syncingLabel:          "Synchronisieren...",
            .syncWithHealthKit:     "Apple Health synchronisieren",
            .allowHealthKit:        "Apple Health erlauben",
            .setGoalButton:         "Ziel setzen",
            .goalTypeSection:       "Zieltyp",
            .goalTargetSection:     "Ziel",
            .runFreqSection:        "Lauffrequenz",
            .cancelButton:          "Abbrechen",
            .saveButton:            "Speichern",
            .goalNavTitle:          "Zieleinstellung",
            .inputErrorMsg:         "Bitte eine Zahl größer als 0 eingeben",
            .goalTypeDistance:      "Distanz",
            .goalTypeCalories:      "Kalorien",
            .goalTypeDuration:      "Dauer",
            .durationUnit:          "Std",
            .unitKilometer:         "Kilometer",
            .unitMile:              "Meile",
            .themeDark:             "Dunkel",
            .themeLight:            "Hell",
            .settingsTitle:         "Einstellungen",
            .bgThemeSection:        "Hintergrund",
            .distUnitSection:       "Entfernungseinheit",
            .notificationsSection:  "Benachrichtigungen",
            .goalReminderToggle:    "Ziel-Erinnerung",
            .d7NotifLabel:          "D-7 (7 Tage vorher, 9 Uhr)",
            .d3NotifLabel:          "D-3 (3 Tage vorher, 9 Uhr)",
            .d1NotifLabel:          "D-1 (Tag vorher, 9 Uhr)",
            .notifPermError:        "Benachrichtigungsberechtigung erforderlich. Bitte in Einstellungen aktivieren.",
            .reconnectHK:           "Apple Health neu verbinden",
            .forceRefreshWidget:    "Widget aktualisieren",
            .versionLabel:          "Version",
            .resetDataButton:       "Alle Daten zurücksetzen",
            .resetConfirmMsg:       "Alle gespeicherten Daten werden gelöscht. Dies kann nicht rückgängig gemacht werden.",
            .resetConfirmButton:    "Zurücksetzen",
            .languageSection:       "Sprache",
            .placeholderDistKm:     "z.B. 100",
            .placeholderDistMile:   "z.B. 62",
            .placeholderCal:        "z.B. 10000",
            .placeholderDur:        "z.B. 10",
            .widgetTotalGoal:       "Laufziel",
            .widgetRemainingPrefix: "Verbleibend",
            .widgetPerRunUnit:      "/Lauf",
            .notifTitle:            "🏃 Monatliches Ziel-Erinnerung",
            .notifBodyDaysFmt:      "Noch %@ bis zum Ziel. In %d Tagen laufen! 💪",
            .notifBodyLastDay:      "Noch %@ bis zum Ziel. Letzte Chance morgen! 💪",
            .helpTitle:             "So verwendest du MyMileage",
            .longDateFormat:        "d. MMMM",
            .shortDateFormat:       "d.M.",
            .tabDashboard:          "Dashboard",
            .tabLog:                "Protokoll",
            .tabCalendar:           "Kalender",
            .tabSettings:           "Einstellungen",
            .widgetDesignSection:   "Widget-Layout",
            .widgetDesignMinimal:   "Minimal",
            .widgetDesignCompact:   "Kompakt",
            .widgetDesignBalanced:  "Ausgewogen",
            .widgetDesignComplete:  "Komplett",
            .dashboardTotalDistance: "Distanz",
            .dashboardTotalDuration:"Dauer",
            .dashboardTotalCalories:"Kalorien",
            .dashboardAvgPace:      "Ø Tempo",
            .dashboardAvgDistance:   "Pro Lauf",
            .dashboardTotalSteps:    "Schritte",
            .dashboardAvgHeartRate:  "Ø HF",
            .mileageGoalLabel:      "Laufziel",
            .noRunsMsg:             "Keine Läufe aufgezeichnet",
            .columnDate:            "Datum",
            .columnTime:            "Zeit",
            .widgetRefreshed:       "Widget aktualisiert",
            .hkReconnected:         "Apple Health verbunden",
            .syncCompleted:         "Sync abgeschlossen",
            .widgetBgSelectPhoto:   "Foto auswählen",
            .widgetBgRemovePhoto:   "Foto entfernen",
            .widgetBgSaved:         "Widget-Hintergrund gespeichert",
            .widgetBgRemoved:       "Widget-Hintergrund entfernt",
            .widgetCropHint:        "Zum Zoomen pinchen, zum Verschieben ziehen",
            .widgetCropDone:        "Fertig",
            .lockWidgetName:        "Lauffortschritt",
            .lockWidgetDescription: "Monatliches Laufziel auf einen Blick.",
            .lockWidgetProRequired: "In der App mit Pro freischalten.",
            .proSectionTitle:       "Pro",
            .proUpgradeButton:      "Auf Pro upgraden",
            .proRestoreButton:      "Kauf wiederherstellen",
            .proUnlocked:           "Pro freigeschaltet",
            .proPurchased:          "Pro freigeschaltet! Vielen Dank!",
            .proRestored:           "Kauf wiederhergestellt!",
            .proRestoreFailed:      "Kein vorheriger Kauf gefunden.",
            .proFeaturePhoto:       "Eigenes Widget-Hintergrundfoto",
            .proFeatureLockWidget:  "Sperrbildschirm-Widgets",
            .dataSourceButton:      "Datenquellen",
            .dataSourceTitle:       "Datenquellen",
            .dataSourceAll:         "Alle Quellen",
            .dataSourceSectionHeader: "Verfügbare Quellen",
            .dataSourceFooter:      "Nur Trainings von ausgewählten Quellen werden gezählt.",
            .dataSourceLoading:     "Quellen werden geladen...",
            .dataSourceSelectedSingular: "Quelle",
            .dataSourceSelectedPlural: "Quellen",
            .calLegendRest:         "Ruhe",
            .calStreakLabel:        "Aktuelle Serie",
            .calStreakDay:          "Tag",
            .calStreakDays:         "Tage",
            .calRestDay:            "Ruhetag",
            .widgetGalleryTitle:        "Widget-Hintergrund",
            .widgetGalleryAddPhoto:     "Neues Foto hinzufügen",
            .widgetGalleryEdit:         "Bearbeiten",
            .widgetGalleryDone:         "Fertig",
            .widgetGalleryMaxReached:   "Bis zu 10 Fotos können gespeichert werden",
            .widgetGalleryEmpty:        "Füge dein erstes Foto hinzu",
            .helpContent: """
MyMileage hilft dir, dein monatliches Laufziel zu erreichen.

Erste Schritte
1. Öffne den Tab „Einstellungen" und tippe auf „Ziel setzen", um Zieltyp (Distanz, Kalorien oder Dauer) und monatlichen Zielwert festzulegen.
2. Tippe auf „Apple Health synchronisieren", um die Berechtigung zu erteilen und Laufdaten zu importieren.
3. Das Dashboard zeigt ein tägliches Balkendiagramm und eine Monatszusammenfassung.

Hauptfunktionen
• Laufziel — Im aktuellen Monat werden dein Ziel und die verbleibenden Tage auf einen Blick angezeigt.
• Lauffrequenz — Wähle täglich, alle 2 Tage oder alle 3 Tage. Das benötigte Pensum pro Einheit wird automatisch berechnet.
• Entfernungseinheit — Wechsle zwischen km und Meilen in den Einstellungen. Das Ziel wird automatisch umgerechnet.
• Widget — Füge das Widget zum Startbildschirm hinzu. Wähle aus 4 Layouts (Minimal, Kompakt, Ausgewogen, Komplett) und lege ein eigenes Hintergrundfoto fest.
• Benachrichtigungen — Erinnerungen 7, 3 oder 1 Tag vor Monatsende, wenn das Ziel noch nicht erreicht ist.

Tipps
• Synchronisiere regelmäßig, um deinen Fortschritt aktuell zu halten.
• Das Widget aktualisiert sich stündlich automatisch.
• Im Tab „Einstellungen" kannst du Farben, Sprache und mehr ändern.
""",
        ],

        // ─────────── FRENCH ───────────
        .french: [
            .appTitle:              "MyMileage - Every Mile Counts",
            .monthYearDateFormat:   "MMMM yyyy",
            .daysLeftFmt:           "%d jours restants",
            .freqDailyLabel:        "Quotidien",
            .freqEveryOtherLabel:   "Tous les 2j",
            .freqEvery3DaysLabel:   "Tous les 3j",
            .freqDailyRun:          "Quotidien",
            .freqEveryOtherRun:     "Tous les 2j",
            .freqEvery3DaysRun:     "Tous les 3j",
            .thisMonthActivities:   "Activités",
            .lastSyncLabel:         "Dernière sync",
            .syncingLabel:          "Synchronisation...",
            .syncWithHealthKit:     "Sync Apple Health",
            .allowHealthKit:        "Autoriser Apple Health",
            .setGoalButton:         "Définir l'objectif",
            .goalTypeSection:       "Type d'objectif",
            .goalTargetSection:     "Cible",
            .runFreqSection:        "Fréquence de course",
            .cancelButton:          "Annuler",
            .saveButton:            "Enregistrer",
            .goalNavTitle:          "Paramètres d'objectif",
            .inputErrorMsg:         "Entrez un nombre supérieur à 0",
            .goalTypeDistance:      "Distance",
            .goalTypeCalories:      "Calories",
            .goalTypeDuration:      "Durée",
            .durationUnit:          "h",
            .unitKilometer:         "Kilomètre",
            .unitMile:              "Mille",
            .themeDark:             "Sombre",
            .themeLight:            "Clair",
            .settingsTitle:         "Paramètres",
            .bgThemeSection:        "Arrière-plan",
            .distUnitSection:       "Unité de distance",
            .notificationsSection:  "Notifications",
            .goalReminderToggle:    "Rappel d'objectif",
            .d7NotifLabel:          "D-7 (7 jours avant, 9h)",
            .d3NotifLabel:          "D-3 (3 jours avant, 9h)",
            .d1NotifLabel:          "D-1 (veille, 9h)",
            .notifPermError:        "Permission de notification requise. Activez-la dans Réglages.",
            .reconnectHK:           "Reconnecter Apple Health",
            .forceRefreshWidget:    "Actualiser le widget",
            .versionLabel:          "Version",
            .resetDataButton:       "Réinitialiser les données",
            .resetConfirmMsg:       "Toutes les données seront supprimées. Cette action est irréversible.",
            .resetConfirmButton:    "Réinitialiser",
            .languageSection:       "Langue",
            .placeholderDistKm:     "ex : 100",
            .placeholderDistMile:   "ex : 62",
            .placeholderCal:        "ex : 10000",
            .placeholderDur:        "ex : 10",
            .widgetTotalGoal:       "Objectif kilométrique",
            .widgetRemainingPrefix: "Restant",
            .widgetPerRunUnit:      "/course",
            .notifTitle:            "🏃 Rappel d'objectif mensuel",
            .notifBodyDaysFmt:      "%@ restants. Courez dans %d jours ! 💪",
            .notifBodyLastDay:      "%@ restants. Dernière chance demain ! 💪",
            .helpTitle:             "Comment utiliser MyMileage",
            .longDateFormat:        "d MMMM",
            .shortDateFormat:       "d/M",
            .tabDashboard:          "Tableau de bord",
            .tabLog:                "Journal",
            .tabCalendar:           "Calendrier",
            .tabSettings:           "Réglages",
            .widgetDesignSection:   "Disposition du widget",
            .widgetDesignMinimal:   "Minimal",
            .widgetDesignCompact:   "Compact",
            .widgetDesignBalanced:  "Équilibré",
            .widgetDesignComplete:  "Complet",
            .dashboardTotalDistance: "Distance",
            .dashboardTotalDuration:"Durée",
            .dashboardTotalCalories:"Calories",
            .dashboardAvgPace:      "Allure moy.",
            .dashboardAvgDistance:   "Par course",
            .dashboardTotalSteps:    "Pas totaux",
            .dashboardAvgHeartRate:  "FC moy.",
            .mileageGoalLabel:      "Objectif kilométrique",
            .noRunsMsg:             "Aucune course enregistrée",
            .columnDate:            "Date",
            .columnTime:            "Durée",
            .widgetRefreshed:       "Widget actualisé",
            .hkReconnected:         "Apple Health connecté",
            .syncCompleted:         "Sync terminée",
            .widgetBgSelectPhoto:   "Choisir une photo",
            .widgetBgRemovePhoto:   "Supprimer la photo",
            .widgetBgSaved:         "Fond du widget enregistré",
            .widgetBgRemoved:       "Fond du widget supprimé",
            .widgetCropHint:        "Pincez pour zoomer, glissez pour déplacer",
            .widgetCropDone:        "Terminé",
            .lockWidgetName:        "Progrès de course",
            .lockWidgetDescription: "Aperçu de votre objectif mensuel de course.",
            .lockWidgetProRequired: "Débloquez dans l'app avec Pro.",
            .proSectionTitle:       "Pro",
            .proUpgradeButton:      "Passer à Pro",
            .proRestoreButton:      "Restaurer l'achat",
            .proUnlocked:           "Pro débloqué",
            .proPurchased:          "Pro débloqué ! Merci !",
            .proRestored:           "Achat restauré !",
            .proRestoreFailed:      "Aucun achat précédent trouvé.",
            .proFeaturePhoto:       "Photo d'arrière-plan personnalisée",
            .proFeatureLockWidget:  "Widgets d'écran de verrouillage",
            .dataSourceButton:      "Sources de données",
            .dataSourceTitle:       "Sources de données",
            .dataSourceAll:         "Toutes les sources",
            .dataSourceSectionHeader: "Sources disponibles",
            .dataSourceFooter:      "Seuls les entraînements des sources sélectionnées seront comptés.",
            .dataSourceLoading:     "Chargement des sources...",
            .dataSourceSelectedSingular: "source",
            .dataSourceSelectedPlural: "sources",
            .calLegendRest:         "Repos",
            .calStreakLabel:        "Série actuelle",
            .calStreakDay:          "jour",
            .calStreakDays:         "jours",
            .calRestDay:            "Jour de repos",
            .widgetGalleryTitle:        "Fond du widget",
            .widgetGalleryAddPhoto:     "Ajouter une nouvelle photo",
            .widgetGalleryEdit:         "Modifier",
            .widgetGalleryDone:         "Terminé",
            .widgetGalleryMaxReached:   "Vous pouvez enregistrer jusqu'à 10 photos",
            .widgetGalleryEmpty:        "Ajoutez votre première photo",
            .helpContent: """
MyMileage vous aide à atteindre votre objectif mensuel de course.

Pour commencer
1. Ouvrez l'onglet Réglages et appuyez sur « Définir l'objectif » pour choisir le type (distance, calories ou durée) et la cible mensuelle.
2. Appuyez sur « Sync Apple Health » pour accorder la permission et importer vos données de course.
3. Le tableau de bord affiche un graphique à barres quotidien et un résumé mensuel.

Fonctionnalités principales
• Objectif kilométrique — Le mois en cours affiche votre objectif et les jours restants en un coup d'œil.
• Fréquence de course — Choisissez quotidien, tous les 2 jours ou tous les 3 jours. L'app calcule automatiquement la quantité requise par session.
• Unité de distance — Passez entre km et miles dans les réglages. L'objectif se convertit automatiquement.
• Widget — Ajoutez le widget à l'écran d'accueil. Choisissez parmi 4 dispositions (Minimal, Compact, Équilibré, Complet) et définissez une photo de fond personnalisée.
• Notifications — Rappels 7, 3 ou 1 jour avant la fin du mois si l'objectif n'est pas atteint.

Conseils
• Synchronisez régulièrement pour maintenir votre progression à jour.
• Le widget se met à jour automatiquement toutes les heures.
• Utilisez l'onglet Réglages pour changer les couleurs, la langue et plus.
""",
        ],

        // ─────────── CHINESE ───────────
        .chinese: [
            .appTitle:              "MyMileage - Every Mile Counts",
            .monthYearDateFormat:   "yyyy年M月",
            .daysLeftFmt:           "还剩%d天",
            .freqDailyLabel:        "每天",
            .freqEveryOtherLabel:   "隔天",
            .freqEvery3DaysLabel:   "每3天",
            .freqDailyRun:          "每天跑步",
            .freqEveryOtherRun:     "隔天跑步",
            .freqEvery3DaysRun:     "每3天跑步",
            .thisMonthActivities:   "本月活动",
            .lastSyncLabel:         "上次同步",
            .syncingLabel:          "同步中...",
            .syncWithHealthKit:     "同步 Apple 健康数据",
            .allowHealthKit:        "允许 Apple 健康",
            .setGoalButton:         "设置目标",
            .goalTypeSection:       "目标类型",
            .goalTargetSection:     "目标值",
            .runFreqSection:        "跑步频率",
            .cancelButton:          "取消",
            .saveButton:            "保存",
            .goalNavTitle:          "目标设置",
            .inputErrorMsg:         "请输入大于0的数字",
            .goalTypeDistance:      "距离",
            .goalTypeCalories:      "卡路里",
            .goalTypeDuration:      "时长",
            .durationUnit:          "小时",
            .unitKilometer:         "千米",
            .unitMile:              "英里",
            .themeDark:             "深色",
            .themeLight:            "浅色",
            .settingsTitle:         "设置",
            .bgThemeSection:        "背景主题",
            .distUnitSection:       "距离单位",
            .notificationsSection:  "通知",
            .goalReminderToggle:    "目标提醒",
            .d7NotifLabel:          "D-7（提前7天，早上9点）",
            .d3NotifLabel:          "D-3（提前3天，早上9点）",
            .d1NotifLabel:          "D-1（前一天，早上9点）",
            .notifPermError:        "需要通知权限，请在设置中允许。",
            .reconnectHK:           "重新连接 Apple Health",
            .forceRefreshWidget:    "强制刷新小组件",
            .versionLabel:          "版本",
            .resetDataButton:       "重置所有数据",
            .resetConfirmMsg:       "所有保存的数据将被删除，此操作无法撤销。",
            .resetConfirmButton:    "重置",
            .languageSection:       "语言",
            .placeholderDistKm:     "如：100",
            .placeholderDistMile:   "如：62",
            .placeholderCal:        "如：10000",
            .placeholderDur:        "如：10",
            .widgetTotalGoal:       "里程目标",
            .widgetRemainingPrefix: "剩余",
            .widgetPerRunUnit:      "/次",
            .notifTitle:            "🏃 月度目标提醒",
            .notifBodyDaysFmt:      "距离目标还差%@，请在%d天内完成！💪",
            .notifBodyLastDay:      "距离目标还差%@，明天是最后机会！💪",
            .helpTitle:             "如何使用 MyMileage",
            .longDateFormat:        "M月d日",
            .shortDateFormat:       "M/d",
            .tabDashboard:          "仪表板",
            .tabLog:                "日志",
            .tabCalendar:           "日历",
            .tabSettings:           "设置",
            .widgetDesignSection:   "小组件布局",
            .widgetDesignMinimal:   "极简",
            .widgetDesignCompact:   "紧凑",
            .widgetDesignBalanced:  "均衡",
            .widgetDesignComplete:  "完整",
            .dashboardTotalDistance: "距离",
            .dashboardTotalDuration:"时长",
            .dashboardTotalCalories:"卡路里",
            .dashboardAvgPace:      "平均配速",
            .dashboardAvgDistance:   "每次距离",
            .dashboardTotalSteps:    "总步数",
            .dashboardAvgHeartRate:  "平均心率",
            .mileageGoalLabel:      "里程目标",
            .noRunsMsg:             "暂无跑步记录",
            .columnDate:            "日期",
            .columnTime:            "时长",
            .widgetRefreshed:       "小组件已刷新",
            .hkReconnected:         "已重新连接",
            .syncCompleted:         "同步完成",
            .widgetBgSelectPhoto:   "选择照片",
            .widgetBgRemovePhoto:   "移除照片",
            .widgetBgSaved:         "小组件背景已保存",
            .widgetBgRemoved:       "小组件背景已移除",
            .widgetCropHint:        "捏合缩放，拖动移动",
            .widgetCropDone:        "完成",
            .lockWidgetName:        "跑步进度",
            .lockWidgetDescription: "快速查看本月跑步目标。",
            .lockWidgetProRequired: "在应用中升级到 Pro 解锁。",
            .proSectionTitle:       "Pro",
            .proUpgradeButton:      "升级到 Pro",
            .proRestoreButton:      "恢复购买",
            .proUnlocked:           "Pro 已解锁",
            .proPurchased:          "Pro 已解锁！感谢您！",
            .proRestored:           "购买已恢复！",
            .proRestoreFailed:      "未找到之前的购买记录。",
            .proFeaturePhoto:       "自定义小组件背景照片",
            .proFeatureLockWidget:  "锁屏小组件",
            .dataSourceButton:      "数据源",
            .dataSourceTitle:       "数据源",
            .dataSourceAll:         "所有源",
            .dataSourceSectionHeader: "可用源",
            .dataSourceFooter:      "仅统计所选源的跑步记录。",
            .dataSourceLoading:     "正在加载源...",
            .dataSourceSelectedSingular: "源",
            .dataSourceSelectedPlural: "源",
            .calLegendRest:         "休息",
            .calStreakLabel:        "当前连续",
            .calStreakDay:          "天",
            .calStreakDays:         "天",
            .calRestDay:            "休息日",
            .widgetGalleryTitle:        "小组件背景",
            .widgetGalleryAddPhoto:     "添加新照片",
            .widgetGalleryEdit:         "编辑",
            .widgetGalleryDone:         "完成",
            .widgetGalleryMaxReached:   "最多可保存10张照片",
            .widgetGalleryEmpty:        "添加您的第一张照片",
            .helpContent: """
MyMileage 帮助您实现每月跑步目标。

开始使用
1. 打开设置标签页，点击「设置目标」选择目标类型（距离、卡路里或时长）并输入月度目标值。
2. 点击「同步 Apple Health」授权并导入跑步数据。
3. 仪表盘显示每日柱状图和月度摘要，方便查看进度。

主要功能
• 里程目标 — 当前月份会显示本月目标和剩余天数，一目了然。
• 跑步频率 — 选择每天、隔天或每3天，App 自动计算每次所需量。
• 距离单位 — 在设置中切换千米和英里，目标将自动转换。
• 小组件 — 将小组件添加到主屏幕。可选择4种布局（极简、紧凑、均衡、完整），还可设置自定义背景照片。
• 通知 — 月末7天、3天或1天前未完成目标时收到提醒。

使用技巧
• 定期同步以保持数据最新。
• 小组件每小时自动更新一次。
• 在设置标签页中可更改主题颜色、语言等。
""",
        ],

        // ─────────── SPANISH ───────────
        .spanish: [
            .appTitle:              "MyMileage - Every Mile Counts",
            .monthYearDateFormat:   "MMMM yyyy",
            .daysLeftFmt:           "%d días restantes",
            .freqDailyLabel:        "Diario",
            .freqEveryOtherLabel:   "Cada 2 días",
            .freqEvery3DaysLabel:   "Cada 3 días",
            .freqDailyRun:          "Diario",
            .freqEveryOtherRun:     "Cada 2 días",
            .freqEvery3DaysRun:     "Cada 3 días",
            .thisMonthActivities:   "Actividades",
            .lastSyncLabel:         "Última sync",
            .syncingLabel:          "Sincronizando...",
            .syncWithHealthKit:     "Sincronizar Apple Health",
            .allowHealthKit:        "Permitir Apple Health",
            .setGoalButton:         "Establecer meta",
            .goalTypeSection:       "Tipo de meta",
            .goalTargetSection:     "Objetivo",
            .runFreqSection:        "Frecuencia de carrera",
            .cancelButton:          "Cancelar",
            .saveButton:            "Guardar",
            .goalNavTitle:          "Configurar meta",
            .inputErrorMsg:         "Ingresa un número mayor que 0",
            .goalTypeDistance:      "Distancia",
            .goalTypeCalories:      "Calorías",
            .goalTypeDuration:      "Duración",
            .durationUnit:          "h",
            .unitKilometer:         "Kilómetro",
            .unitMile:              "Milla",
            .themeDark:             "Oscuro",
            .themeLight:            "Claro",
            .settingsTitle:         "Configuración",
            .bgThemeSection:        "Fondo",
            .distUnitSection:       "Unidad de distancia",
            .notificationsSection:  "Notificaciones",
            .goalReminderToggle:    "Recordatorio de meta",
            .d7NotifLabel:          "D-7 (7 días antes, 9h)",
            .d3NotifLabel:          "D-3 (3 días antes, 9h)",
            .d1NotifLabel:          "D-1 (día anterior, 9h)",
            .notifPermError:        "Se requiere permiso de notificación. Actívalo en Configuración.",
            .reconnectHK:           "Reconectar Apple Health",
            .forceRefreshWidget:    "Actualizar widget",
            .versionLabel:          "Versión",
            .resetDataButton:       "Restablecer todos los datos",
            .resetConfirmMsg:       "Se eliminarán todos los datos guardados. Esta acción no se puede deshacer.",
            .resetConfirmButton:    "Restablecer",
            .languageSection:       "Idioma",
            .placeholderDistKm:     "ej: 100",
            .placeholderDistMile:   "ej: 62",
            .placeholderCal:        "ej: 10000",
            .placeholderDur:        "ej: 10",
            .widgetTotalGoal:       "Meta de kilometraje",
            .widgetRemainingPrefix: "Restante",
            .widgetPerRunUnit:      "/carrera",
            .notifTitle:            "🏃 Recordatorio de meta mensual",
            .notifBodyDaysFmt:      "%@ restantes. ¡Corre en %d días! 💪",
            .notifBodyLastDay:      "%@ restantes. ¡Última oportunidad mañana! 💪",
            .helpTitle:             "Cómo usar MyMileage",
            .longDateFormat:        "d 'de' MMMM",
            .shortDateFormat:       "d/M",
            .tabDashboard:          "Panel",
            .tabLog:                "Historial",
            .tabCalendar:           "Calendario",
            .tabSettings:           "Ajustes",
            .widgetDesignSection:   "Diseño del widget",
            .widgetDesignMinimal:   "Mínimo",
            .widgetDesignCompact:   "Compacto",
            .widgetDesignBalanced:  "Equilibrado",
            .widgetDesignComplete:  "Completo",
            .dashboardTotalDistance: "Distancia",
            .dashboardTotalDuration:"Duración",
            .dashboardTotalCalories:"Calorías",
            .dashboardAvgPace:      "Ritmo prom.",
            .dashboardAvgDistance:   "Por carrera",
            .dashboardTotalSteps:    "Pasos tot.",
            .dashboardAvgHeartRate:  "FC prom.",
            .mileageGoalLabel:      "Meta de kilometraje",
            .noRunsMsg:             "Sin carreras registradas",
            .columnDate:            "Fecha",
            .columnTime:            "Duración",
            .widgetRefreshed:       "Widget actualizado",
            .hkReconnected:         "Apple Health conectado",
            .syncCompleted:         "Sync completada",
            .widgetBgSelectPhoto:   "Seleccionar foto",
            .widgetBgRemovePhoto:   "Eliminar foto",
            .widgetBgSaved:         "Fondo del widget guardado",
            .widgetBgRemoved:       "Fondo del widget eliminado",
            .widgetCropHint:        "Pellizca para zoom, arrastra para mover",
            .widgetCropDone:        "Listo",
            .lockWidgetName:        "Progreso de carrera",
            .lockWidgetDescription: "Vista rápida de tu meta mensual.",
            .lockWidgetProRequired: "Desbloquea en la app con Pro.",
            .proSectionTitle:       "Pro",
            .proUpgradeButton:      "Mejorar a Pro",
            .proRestoreButton:      "Restaurar compra",
            .proUnlocked:           "Pro desbloqueado",
            .proPurchased:          "¡Pro desbloqueado! ¡Gracias!",
            .proRestored:           "¡Compra restaurada!",
            .proRestoreFailed:      "No se encontró compra previa.",
            .proFeaturePhoto:       "Foto de fondo personalizada",
            .proFeatureLockWidget:  "Widgets de pantalla de bloqueo",
            .dataSourceButton:      "Fuentes de datos",
            .dataSourceTitle:       "Fuentes de datos",
            .dataSourceAll:         "Todas las fuentes",
            .dataSourceSectionHeader: "Fuentes disponibles",
            .dataSourceFooter:      "Solo se contarán las carreras de las fuentes seleccionadas.",
            .dataSourceLoading:     "Cargando fuentes...",
            .dataSourceSelectedSingular: "fuente",
            .dataSourceSelectedPlural: "fuentes",
            .calLegendRest:         "Descanso",
            .calStreakLabel:        "Racha actual",
            .calStreakDay:          "día",
            .calStreakDays:         "días",
            .calRestDay:            "Día de descanso",
            .widgetGalleryTitle:        "Fondo del widget",
            .widgetGalleryAddPhoto:     "Agregar nueva foto",
            .widgetGalleryEdit:         "Editar",
            .widgetGalleryDone:         "Listo",
            .widgetGalleryMaxReached:   "Se pueden guardar hasta 10 fotos",
            .widgetGalleryEmpty:        "Agrega tu primera foto",
            .helpContent: """
MyMileage te ayuda a alcanzar tu meta mensual de carrera.

Cómo empezar
1. Abre la pestaña Ajustes y toca «Establecer meta» para elegir el tipo (distancia, calorías o duración) y fijar la meta mensual.
2. Toca «Sincronizar Apple Health» para conceder permiso e importar tus datos de carrera.
3. El panel muestra un gráfico de barras diario y un resumen mensual de tu progreso.

Funciones principales
• Meta de kilometraje — El mes actual muestra tu meta y los días restantes de un vistazo.
• Frecuencia de carrera — Elige diario, cada 2 días o cada 3 días. La app calcula automáticamente la cantidad necesaria por sesión.
• Unidad de distancia — Cambia entre km y millas en los ajustes. La meta se convierte automáticamente.
• Widget — Añade el widget a la pantalla de inicio. Elige entre 4 diseños (Mínimo, Compacto, Equilibrado, Completo) y establece una foto de fondo personalizada.
• Notificaciones — Recordatorios 7, 3 o 1 día antes del fin de mes si no has alcanzado la meta.

Consejos
• Sincroniza regularmente para mantener tu progreso actualizado.
• El widget se actualiza automáticamente cada hora.
• Usa la pestaña Ajustes para cambiar colores, idioma y más.
""",
        ],
    ]
}
