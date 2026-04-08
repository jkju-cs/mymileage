//
//  ContentView.swift
//  MotivationRun — Dynamic Theme + Multi-language Design
//

import SwiftUI
import PhotosUI
import StoreKit
import WidgetKit

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard h.count == 6 else { self.init(.clear); return }
        var rgb: UInt64 = 0
        guard Scanner(string: h).scanHexInt64(&rgb) else { self.init(.clear); return }
        self.init(
            red:   Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8)  & 0xFF) / 255,
            blue:  Double( rgb        & 0xFF) / 255
        )
    }
}

// MARK: - 차트 지표 탭

enum ChartMetric: CaseIterable {
    case distance, duration, calories

    func label(lang: AppLanguage) -> String {
        switch self {
        case .distance: return L(.dashboardTotalDistance, lang)
        case .duration: return L(.dashboardTotalDuration, lang)
        case .calories: return L(.dashboardTotalCalories, lang)
        }
    }

    func unit(distanceUnit: DistanceUnit) -> String {
        switch self {
        case .distance: return distanceUnit.symbol
        case .duration: return "min"
        case .calories: return "kcal"
        }
    }
}

// MARK: - 메인 뷰

struct ContentView: View {
    @StateObject private var storeManager = StoreManager.shared

    @State private var goalTarget: Double = 100.0
    @State private var goalType: GoalType = .distance
    @State private var runFrequency: RunFrequency = .everyOther
    @State private var lastSync: Date?
    @State private var isSyncing: Bool = false
    @State private var isAuthorized: Bool = false
    @State private var showGoalSheet: Bool = false
    @State private var showHelpSheet: Bool = false
    @State private var themeAccent: ThemeAccent = .yellow
    @State private var themeBackground: ThemeBackground = .black
    @State private var distanceUnit: DistanceUnit = .km
    @State private var appLanguage: AppLanguage = .english
    @State private var notificationSettings: NotificationSettings = NotificationSettings()
    @State private var selectedTab: Int = 0
    @State private var toastMessage: String = ""
    @State private var showToast: Bool = false

    // MARK: - 월 네비게이션
    @State private var allSessions: [RunSession] = []
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var isLoadingSessions: Bool = false
    @State private var chartMetric: ChartMetric = .distance

    // MARK: - 테마 색상 (동적)
    private var cAccent:   Color { themeAccent.color }
    private var cBg:       Color { themeBackground.appBg }
    private var cCard:     Color { themeBackground.cardBg }
    private var cGray:     Color { themeBackground.grayBg }
    private var cText:     Color { themeBackground.mainText }
    private var cSub:      Color { themeBackground.subText }

    /// 현재 언어로 번역
    private func t(_ key: LK) -> String { L(key, appLanguage) }

    // MARK: - 현재 월 여부
    private var isCurrentMonth: Bool {
        let cal = Calendar.current
        let now = Date()
        return selectedYear == cal.component(.year, from: now) &&
               selectedMonth == cal.component(.month, from: now)
    }

    // MARK: - 선택된 월의 세션
    private var selectedMonthSessions: [RunSession] {
        let cal = Calendar.current
        return allSessions.filter { session in
            let comps = cal.dateComponents([.year, .month], from: session.date)
            return comps.year == selectedYear && comps.month == selectedMonth
        }.sorted { $0.date > $1.date }
    }

    // MARK: - 선택된 월 통계
    private var monthTotalDistanceKm: Double {
        selectedMonthSessions.reduce(0) { $0 + $1.distanceKm }
    }
    private var monthTotalCalories: Double {
        selectedMonthSessions.reduce(0) { $0 + $1.calories }
    }
    private var monthTotalDurationMin: Double {
        selectedMonthSessions.reduce(0) { $0 + $1.durationMinutes }
    }
    private var monthSessionCount: Int { selectedMonthSessions.count }

    private var monthDisplayDistance: Double {
        monthTotalDistanceKm * distanceUnit.conversionFromKm
    }

    private var monthAvgPaceStr: String {
        guard monthTotalDistanceKm > 0 else { return "-" }
        let dist = monthTotalDistanceKm * distanceUnit.conversionFromKm
        let pacePerUnit = monthTotalDurationMin / dist
        let totalSec = Int(pacePerUnit * 60)
        let m = totalSec / 60
        let s = totalSec % 60
        return "\(m)'\(String(format: "%02d", s))\""
    }

    private var monthAvgDistancePerRun: Double {
        guard monthSessionCount > 0 else { return 0 }
        return monthDisplayDistance / Double(monthSessionCount)
    }

    private var monthDurationStr: String {
        let total = Int(monthTotalDurationMin)
        let h = total / 60
        let m = total % 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }

    private var remainingDays: Int {
        let cal = Calendar.current
        let now = Date()
        guard let startOfThisMonth = cal.date(from: cal.dateComponents([.year, .month], from: now)),
              let startOfNextMonth  = cal.date(byAdding: .month, value: 1, to: startOfThisMonth) else {
            return 1
        }
        return max(cal.dateComponents([.day], from: now, to: startOfNextMonth).day ?? 1, 1)
    }

    // MARK: - 선택된 월 표시 문자열
    private var selectedMonthString: String {
        let f = DateFormatter()
        f.locale = appLanguage.locale
        f.dateFormat = t(.monthYearDateFormat)
        var comps = DateComponents()
        comps.year = selectedYear
        comps.month = selectedMonth
        comps.day = 1
        let date = Calendar.current.date(from: comps) ?? Date()
        return f.string(from: date)
    }

    // MARK: - 이동 가능한 월 범위 (세션 데이터가 있는 범위)
    private var availableMonths: [(year: Int, month: Int)] {
        let cal = Calendar.current
        var set = Set<String>()
        var result: [(Int, Int)] = []
        for session in allSessions {
            let comps = cal.dateComponents([.year, .month], from: session.date)
            let key = "\(comps.year ?? 0)-\(comps.month ?? 0)"
            if set.insert(key).inserted {
                result.append((comps.year ?? 0, comps.month ?? 0))
            }
        }
        // 현재 월도 항상 포함
        let nowY = cal.component(.year, from: Date())
        let nowM = cal.component(.month, from: Date())
        let nowKey = "\(nowY)-\(nowM)"
        if set.insert(nowKey).inserted {
            result.append((nowY, nowM))
        }
        return result.sorted { ($0.0, $0.1) < ($1.0, $1.1) }
    }

    private func navigateMonth(delta: Int) {
        var comps = DateComponents()
        comps.year = selectedYear
        comps.month = selectedMonth
        comps.day = 1
        guard let current = Calendar.current.date(from: comps),
              let next = Calendar.current.date(byAdding: .month, value: delta, to: current) else { return }
        let cal = Calendar.current
        selectedYear = cal.component(.year, from: next)
        selectedMonth = cal.component(.month, from: next)
    }

    private var canGoForward: Bool {
        let cal = Calendar.current
        let nowY = cal.component(.year, from: Date())
        let nowM = cal.component(.month, from: Date())
        return (selectedYear < nowY) || (selectedYear == nowY && selectedMonth < nowM)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            dashboardTab
                .tabItem { Label(t(.tabDashboard), systemImage: "chart.bar.fill") }
                .tag(0)
            LogView(themeAccent: themeAccent, themeBackground: themeBackground,
                    distanceUnit: distanceUnit, appLanguage: appLanguage)
                .tabItem { Label(t(.tabLog), systemImage: "list.bullet.rectangle") }
                .tag(1)
            SettingsTabView(
                storeManager: storeManager,
                accent: $themeAccent,
                background: $themeBackground,
                distanceUnit: $distanceUnit,
                notificationSettings: $notificationSettings,
                language: $appLanguage,
                goalType: $goalType,
                goalTarget: $goalTarget,
                onSettingsChanged: {
                    rescheduleNotifications()
                    loadData()
                    WidgetCenter.shared.reloadAllTimelines()
                },
                onReset: {
                    loadData()
                    WidgetCenter.shared.reloadAllTimelines()
                },
                onSyncHealthKit: syncWithHealthKit,
                onSetGoal: { showGoalSheet = true },
                isSyncing: isSyncing,
                isAuthorized: isAuthorized
            )
            .tabItem { Label(t(.tabSettings), systemImage: "gearshape.fill") }
            .tag(2)
        }
        .tint(.primary)
    }

    // MARK: - 대시보드 탭 콘텐츠

    private var dashboardTab: some View {
        ZStack {
            cBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    headerView
                    monthNavigator

                    if isCurrentMonth {
                        mileageGoalBanner
                    }

                    dailyBarChart

                    monthlySummaryCards

                    if isCurrentMonth, let sync = lastSync {
                        Text("\(t(.lastSyncLabel))  \(sync.formatted(date: .abbreviated, time: .shortened))")
                            .font(.system(size: 11))
                            .foregroundColor(cSub)
                            .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
        .preferredColorScheme(themeBackground.colorScheme)
        .onAppear { loadData(); autoRefreshIfAuthorized(); fetchAllSessions() }
        .sheet(isPresented: $showGoalSheet) {
            GoalSettingView(
                goalType: goalType,
                goalInput: "\(Int(goalTarget))",
                frequency: runFrequency,
                distanceUnit: distanceUnit,
                language: appLanguage
            ) { newType, newTarget, newFrequency in
                SharedDataManager.shared.saveGoal(type: newType, target: newTarget)
                SharedDataManager.shared.saveRunFrequency(newFrequency)
                goalType     = newType
                goalTarget   = newTarget
                runFrequency = newFrequency
                loadData()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        .sheet(isPresented: $showHelpSheet) {
            HelpView(language: appLanguage,
                     cAccent: cAccent, cBg: cBg, cCard: cCard, cText: cText, cSub: cSub)
        }
        .overlay(alignment: .bottom) {
            if showToast {
                Text(toastMessage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.78))
                    .cornerRadius(24)
                    .padding(.bottom, 88)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showToast)
    }

    // MARK: - 헤더

    private var headerView: some View {
        HStack {
            Text(t(.appTitle))
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(cText)
            Spacer()
            Button(action: { showHelpSheet = true }) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(cAccent)
                    .padding(9)
                    .background(cAccent.opacity(0.15))
                    .clipShape(Circle())
            }
        }
    }

    // MARK: - 월 네비게이터

    private var monthNavigator: some View {
        HStack {
            Button(action: { navigateMonth(delta: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(cAccent)
                    .padding(8)
            }

            Spacer()

            Text(selectedMonthString)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(cText)

            Spacer()

            Button(action: { navigateMonth(delta: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(canGoForward ? cAccent : cGray)
                    .padding(8)
            }
            .disabled(!canGoForward)
        }
        .padding(.vertical, 4)
    }

    // MARK: - 마일리지 목표 배너

    private var mileageGoalBanner: some View {
        let goalStr: String = {
            switch goalType {
            case .distance: return "\(Int(goalTarget)) \(distanceUnit.symbol)"
            case .calories: return "\(Int(goalTarget)) kcal"
            case .duration: return "\(Int(goalTarget)) \(t(.durationUnit))"
            }
        }()

        return HStack {
            HStack(spacing: 6) {
                Image(systemName: "target")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(cAccent)
                Text(t(.mileageGoalLabel))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(cText)
                Text(goalStr)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(cAccent)
            }
            Spacer()
            Text(String(format: t(.daysLeftFmt), remainingDays))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(cSub)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(cCard)
        .cornerRadius(12)
    }

    // MARK: - 일별 바 차트

    private var daysInSelectedMonth: Int {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.year = selectedYear
        comps.month = selectedMonth
        comps.day = 1
        guard let date = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: date) else { return 30 }
        return range.count
    }

    /// 일별 데이터 배열 (chartMetric에 따라)
    private var dailyChartData: [Double] {
        let cal = Calendar.current
        let days = daysInSelectedMonth
        var result = Array(repeating: 0.0, count: days)
        for session in selectedMonthSessions {
            let day = cal.component(.day, from: session.date)
            guard day >= 1 && day <= days else { continue }
            switch chartMetric {
            case .distance:
                result[day - 1] += session.distanceKm * distanceUnit.conversionFromKm
            case .duration:
                result[day - 1] += session.durationMinutes
            case .calories:
                result[day - 1] += session.calories
            }
        }
        return result
    }

    /// X축에 표시할 일요일 day 목록
    private var sundaysInMonth: [Int] {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.year = selectedYear
        comps.month = selectedMonth
        comps.day = 1
        guard let firstOfMonth = cal.date(from: comps) else { return [] }
        let days = daysInSelectedMonth
        var sundays: [Int] = []
        for d in 1...days {
            comps.day = d
            if let date = cal.date(from: comps), cal.component(.weekday, from: date) == 1 {
                sundays.append(d)
            }
        }
        return sundays
    }

    private var dailyBarChart: some View {
        let data = dailyChartData
        let maxVal = data.max() ?? 0
        let chartMax = maxVal > 0 ? maxVal * 1.25 : 1
        let totalDays = daysInSelectedMonth
        let cal = Calendar.current
        let todayDay: Int? = isCurrentMonth ? cal.component(.day, from: Date()) : nil

        // 사분위수 값 (Y축 기준)
        let q1 = chartMax * 0.25
        let q2 = chartMax * 0.50
        let q3 = chartMax * 0.75

        let yAxisW: CGFloat = 36

        return VStack(spacing: 0) {
            // MARK: 지표 탭
            HStack(spacing: 0) {
                ForEach(ChartMetric.allCases, id: \.self) { metric in
                    Button {
                        chartMetric = metric
                    } label: {
                        VStack(spacing: 6) {
                            Text(metric.label(lang: appLanguage))
                                .font(.system(size: 14, weight: chartMetric == metric ? .bold : .medium))
                                .foregroundColor(chartMetric == metric ? cText : cSub)
                            Rectangle()
                                .fill(chartMetric == metric ? cAccent : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 14)

            // MARK: 차트 영역
            GeometryReader { geo in
                let chartW = geo.size.width - yAxisW - 16  // 16 = right padding
                let chartH = geo.size.height - 24  // 24 = bottom labels
                let spacing: CGFloat = totalDays > 28 ? 1 : 1.5
                let totalSpacing = spacing * CGFloat(totalDays - 1)
                let barW = max((chartW - totalSpacing) / CGFloat(totalDays), 2)

                ZStack(alignment: .topLeading) {
                    // Y축 레이블 + 가로선
                    ForEach([0.0, q1, q2, q3], id: \.self) { qVal in
                        let yRatio = 1.0 - (qVal / chartMax)
                        let yPos = CGFloat(yRatio) * chartH

                        // 가로선
                        Path { path in
                            path.move(to: CGPoint(x: yAxisW, y: yPos))
                            path.addLine(to: CGPoint(x: yAxisW + chartW, y: yPos))
                        }
                        .stroke(cGray.opacity(qVal == 0 ? 0 : 0.4), lineWidth: 0.5)

                        // Y축 레이블
                        Text(chartYLabel(qVal))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(cSub)
                            .frame(width: yAxisW - 4, alignment: .trailing)
                            .position(x: (yAxisW - 4) / 2, y: yPos)
                    }

                    // Y축 세로선
                    Path { path in
                        path.move(to: CGPoint(x: yAxisW, y: 0))
                        path.addLine(to: CGPoint(x: yAxisW, y: chartH))
                    }
                    .stroke(cSub.opacity(0.3), lineWidth: 1)

                    // X축 가로선 (바닥)
                    Path { path in
                        path.move(to: CGPoint(x: yAxisW, y: chartH))
                        path.addLine(to: CGPoint(x: yAxisW + chartW, y: chartH))
                    }
                    .stroke(cSub.opacity(0.3), lineWidth: 1)

                    // 바 차트
                    HStack(alignment: .bottom, spacing: spacing) {
                        ForEach(0..<totalDays, id: \.self) { i in
                            let val = data[i]
                            let ratio = val / chartMax
                            let barH = max(CGFloat(ratio) * chartH, val > 0 ? 2 : 0)
                            let isToday = todayDay != nil && (i + 1) == todayDay

                            RoundedRectangle(cornerRadius: barW > 5 ? 2 : 1)
                                .fill(isToday ? cAccent : (val > 0 ? cAccent.opacity(0.6) : Color.clear))
                                .frame(width: barW, height: barH)
                        }
                    }
                    .frame(height: chartH, alignment: .bottom)
                    .offset(x: yAxisW)

                    // X축 레이블
                    xAxisLabels(chartW: chartW, chartH: chartH, yAxisW: yAxisW, totalDays: totalDays)
                }
            }
            .aspectRatio(1.43, contentMode: .fit)
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
        }
        .background(cCard)
        .cornerRadius(18)
    }

    private func chartYLabel(_ value: Double) -> String {
        switch chartMetric {
        case .distance:
            return value >= 10 ? String(format: "%.0f", value) : String(format: "%.1f", value)
        case .duration:
            let m = Int(value)
            return m >= 60 ? "\(m / 60)h" : "\(m)"
        case .calories:
            return String(format: "%.0f", value)
        }
    }

    private func xAxisLabels(chartW: CGFloat, chartH: CGFloat, yAxisW: CGFloat, totalDays: Int) -> some View {
        let sundays = sundaysInMonth
        // 표시할 일자: 1일, 일요일들, 마지막 날
        var labelDays: [Int] = [1]
        for s in sundays {
            if s != 1 && s != totalDays { labelDays.append(s) }
        }
        labelDays.append(totalDays)

        return ForEach(labelDays, id: \.self) { day in
            let x = yAxisW + (CGFloat(day - 1) + 0.5) * (chartW / CGFloat(totalDays))
            Text("\(day)")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(cSub)
                .position(x: x, y: chartH + 12)
        }
    }

    // MARK: - 월간 요약 카드

    private var monthlySummaryCards: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(cText)
            HStack(spacing: 12) {
                summaryCard(
                    icon: "figure.run",
                    value: String(format: "%.1f", monthDisplayDistance),
                    unit: distanceUnit.symbol,
                    label: t(.dashboardTotalDistance)
                )
                summaryCard(
                    icon: "clock.fill",
                    value: monthDurationStr,
                    unit: "",
                    label: t(.dashboardTotalDuration)
                )
            }
            HStack(spacing: 12) {
                summaryCard(
                    icon: "flame.fill",
                    value: String(format: "%.0f", monthTotalCalories),
                    unit: "kcal",
                    label: t(.dashboardTotalCalories)
                )
                summaryCard(
                    icon: "number",
                    value: "\(monthSessionCount)\(appLanguage == .korean ? "회" : "")",
                    unit: "",
                    label: t(.thisMonthActivities)
                )
            }
            HStack(spacing: 12) {
                summaryCard(
                    icon: "speedometer",
                    value: monthAvgPaceStr,
                    unit: "/\(distanceUnit.symbol)",
                    label: t(.dashboardAvgPace)
                )
                summaryCard(
                    icon: "arrow.left.arrow.right",
                    value: String(format: "%.1f", monthAvgDistancePerRun),
                    unit: distanceUnit.symbol,
                    label: t(.dashboardAvgDistance)
                )
            }
        }
    }

    private func summaryCard(icon: String, value: String, unit: String, label: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(cAccent)
                .frame(width: 32, height: 32)
                .background(cAccent.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(value)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(cText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(cSub)
                    }
                }
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(cSub)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(cCard)
        .cornerRadius(14)
    }

    // MARK: - HealthKit 동기화

    private func syncWithHealthKit() {
        if HealthKitService.shared.hasRequestedAuthorization() {
            isSyncing = true
            HealthKitService.shared.fetchMonthlyRunningStats { success in
                isSyncing = false
                if success { postSyncUpdate(showToast: true) }
            }
        } else {
            HealthKitService.shared.requestAuthorization { success in
                isAuthorized = success
                if success {
                    isSyncing = true
                    HealthKitService.shared.fetchMonthlyRunningStats { fetchSuccess in
                        isSyncing = false
                        if fetchSuccess { postSyncUpdate(showToast: true) }
                    }
                }
            }
        }
    }

    private func postSyncUpdate(showToast: Bool = false) {
        if let stats = SharedDataManager.shared.getMonthlyStats() {
            rescheduleNotifications(stats: stats)
        }
        loadData()
        fetchAllSessions()
        WidgetCenter.shared.reloadAllTimelines()
        if showToast { showToastBanner(t(.syncCompleted)) }
    }

    private func fetchAllSessions() {
        guard !isLoadingSessions else { return }
        isLoadingSessions = true
        HealthKitService.shared.fetchAllRunningSessions { sessions in
            allSessions = sessions
            isLoadingSessions = false
        }
    }

    private func showToastBanner(_ msg: String) {
        toastMessage = msg
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { showToast = false }
        }
    }

    private func autoRefreshIfAuthorized() {
        guard HealthKitService.shared.hasRequestedAuthorization() else {
            isAuthorized = false
            return
        }
        isAuthorized = true
        isSyncing = true
        HealthKitService.shared.fetchMonthlyRunningStats { success in
            isSyncing = false
            if success { postSyncUpdate() }
        }
    }

    // MARK: - 알림 재스케줄

    private func rescheduleNotifications(stats: MonthlyStats? = nil) {
        let s        = stats ?? SharedDataManager.shared.getMonthlyStats()
        let settings = SharedDataManager.shared.getNotificationSettings()
        let distUnit = SharedDataManager.shared.getDistanceUnit()
        let gType    = SharedDataManager.shared.getGoalType()
        let gTarget  = SharedDataManager.shared.getGoalTarget()
        let displayValue = s?.displayCurrentValue(distanceUnit: distUnit) ?? 0
        let rem = max(gTarget - displayValue, 0)
        NotificationManager.shared.scheduleGoalReminders(
            remaining: rem, goalType: gType,
            distanceUnit: distUnit, settings: settings
        )
    }

    private func loadData() {
        let stats        = SharedDataManager.shared.getMonthlyStats()
        goalType         = SharedDataManager.shared.getGoalType()
        goalTarget       = SharedDataManager.shared.getGoalTarget()
        runFrequency     = SharedDataManager.shared.getRunFrequency()
        themeAccent      = SharedDataManager.shared.getThemeAccent()
        themeBackground  = SharedDataManager.shared.getThemeBackground()
        distanceUnit     = SharedDataManager.shared.getDistanceUnit()
        appLanguage      = SharedDataManager.shared.getLanguage()
        notificationSettings = SharedDataManager.shared.getNotificationSettings()

        lastSync        = stats?.lastSyncTime
        isAuthorized    = HealthKitService.shared.hasRequestedAuthorization()
    }
}

// MARK: - 도움말 뷰

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    let language: AppLanguage
    let cAccent: Color
    let cBg: Color
    let cCard: Color
    let cText: Color
    let cSub: Color

    private func t(_ key: LK) -> String { L(key, language) }

    var body: some View {
        NavigationView {
            ZStack {
                cBg.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    Text(t(.helpContent))
                        .font(.system(size: 15))
                        .foregroundColor(cText)
                        .lineSpacing(5)
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(cCard)
                        .cornerRadius(16)
                        .padding(16)
                }
            }
            .navigationTitle(t(.helpTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(t(.cancelButton)) { dismiss() }
                        .foregroundColor(cAccent)
                        .bold()
                }
            }
        }
        .preferredColorScheme(nil)
    }
}

// MARK: - 목표 설정 시트

struct GoalSettingView: View {
    @Environment(\.dismiss) var dismiss
    var onSave: (GoalType, Double, RunFrequency) -> Void

    @State private var selectedGoalType: GoalType
    @State private var goalInput: String
    @State private var selectedFrequency: RunFrequency
    @State private var showInputError = false

    let distanceUnit: DistanceUnit
    let language: AppLanguage

    init(goalType: GoalType, goalInput: String, frequency: RunFrequency,
         distanceUnit: DistanceUnit, language: AppLanguage,
         onSave: @escaping (GoalType, Double, RunFrequency) -> Void) {
        self._selectedGoalType  = State(initialValue: goalType)
        self._goalInput         = State(initialValue: goalInput)
        self._selectedFrequency = State(initialValue: frequency)
        self.distanceUnit       = distanceUnit
        self.language           = language
        self.onSave = onSave
    }

    private func t(_ key: LK) -> String { L(key, language) }
    private var inputUnit: String { selectedGoalType.displayUnit(distanceUnit: distanceUnit, lang: language) }

    private var inputPlaceholder: String {
        switch selectedGoalType {
        case .distance: return distanceUnit == .km ? t(.placeholderDistKm) : t(.placeholderDistMile)
        case .calories: return t(.placeholderCal)
        case .duration: return t(.placeholderDur)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: $selectedGoalType) {
                        ForEach(GoalType.allCases, id: \.self) { type in
                            Text(type.localizedDisplayName(lang: language)).tag(type)
                        }
                    } label: {
                        Text(t(.goalTypeSection))
                    }
                    .onChange(of: selectedGoalType) { showInputError = false }

                    HStack {
                        Text(t(.goalTargetSection))
                        Spacer()
                        TextField(inputPlaceholder, text: $goalInput)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 120)
                            .onChange(of: goalInput) { showInputError = false }
                        Text(inputUnit)
                            .foregroundColor(.secondary)
                    }

                    if showInputError {
                        Text(t(.inputErrorMsg))
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }

                    Picker(selection: $selectedFrequency) {
                        ForEach(RunFrequency.allCases, id: \.self) { freq in
                            Text(freq.localizedLabel(lang: language)).tag(freq)
                        }
                    } label: {
                        Text(t(.runFreqSection))
                    }
                }
            }
            .navigationTitle(t(.goalNavTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(t(.cancelButton)) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(t(.saveButton)) {
                        guard let val = Double(goalInput), val > 0 else {
                            showInputError = true
                            return
                        }
                        onSave(selectedGoalType, val, selectedFrequency)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

// MARK: - 설정 탭

struct SettingsTabView: View {
    @ObservedObject var storeManager: StoreManager

    @Binding var accent: ThemeAccent
    @Binding var background: ThemeBackground
    @Binding var distanceUnit: DistanceUnit
    @Binding var notificationSettings: NotificationSettings
    @Binding var language: AppLanguage
    @Binding var goalType: GoalType
    @Binding var goalTarget: Double

    var onSettingsChanged: () -> Void
    var onReset: () -> Void
    var onSyncHealthKit: () -> Void
    var onSetGoal: () -> Void
    var isSyncing: Bool
    var isAuthorized: Bool

    @State private var isReconnecting = false
    @State private var showResetConfirm = false
    @State private var notifAuthStatus: String = ""
    @State private var settingsToastMsg: String = ""
    @State private var settingsShowToast: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var hasWidgetBgImage: Bool = SharedDataManager.shared.hasWidgetBackgroundImage()
    @State private var widgetBgPreview: UIImage? = SharedDataManager.shared.loadWidgetBackgroundImage()
    @State private var pickedRawImage: UIImage?
    @State private var showCropSheet: Bool = false
    @State private var selectedWidgetDesign: WidgetDesign = SharedDataManager.shared.getWidgetDesign()
    @State private var isRestoring: Bool = false

    private func t(_ key: LK) -> String { L(key, language) }

    private var accentColor: Color { accent.color }

    private var availableAccents: [ThemeAccent] {
        ThemeAccent.allCases.filter { a in
            switch a {
            case .white: return background == .black
            case .black: return background == .white
            default: return true
            }
        }
    }

    /// 설정 변경 시 즉시 저장
    private func saveAll() {
        SharedDataManager.shared.saveTheme(accent: accent, background: background)
        SharedDataManager.shared.saveDistanceUnit(distanceUnit)
        SharedDataManager.shared.saveNotificationSettings(notificationSettings)
        SharedDataManager.shared.saveLanguage(language)
        SharedDataManager.shared.saveWidgetDesign(selectedWidgetDesign)
        onSettingsChanged()
    }

    // MARK: - iOS-style 아이콘 뱃지
    private func settingsIcon(_ systemName: String, _ color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 28, height: 28)
            .background(color)
            .cornerRadius(6)
    }

    var body: some View {
        NavigationView {
            Form {
                // MARK: Data
                Section {
                    Button(action: onSetGoal) {
                        HStack(spacing: 12) {
                            settingsIcon("target", .orange)
                            Text(t(.setGoalButton))
                            Spacer()
                            Text("\(goalType.localizedDisplayName(lang: language)) \(formatGoalLabel())")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        .padding(.vertical, 4)
                    }

                    Button(action: onSyncHealthKit) {
                        HStack(spacing: 12) {
                            settingsIcon(isAuthorized ? "arrow.clockwise" : "heart.text.square", .red)
                            Text(isSyncing ? t(.syncingLabel) : (isAuthorized ? t(.syncWithHealthKit) : t(.allowHealthKit)))
                            Spacer()
                            if isSyncing { ProgressView() }
                        }
                        .padding(.vertical, 4)
                    }
                    .disabled(isSyncing)

                    Button(action: {
                        isReconnecting = true
                        HealthKitService.shared.requestAuthorization { _ in
                            isReconnecting = false
                            showSettingsToast(t(.hkReconnected))
                        }
                    }) {
                        HStack(spacing: 12) {
                            settingsIcon("heart.text.square", .pink)
                            Text(t(.reconnectHK))
                            Spacer()
                            if isReconnecting { ProgressView() }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Data")
                }

                // MARK: 위젯
                Section {
                    NavigationLink {
                        WidgetDesignPickerView(
                            selectedDesign: $selectedWidgetDesign,
                            accent: accentColor,
                            bg: background,
                            language: language,
                            onChanged: saveAll
                        )
                    } label: {
                        HStack(spacing: 12) {
                            settingsIcon("square.grid.2x2.fill", .indigo)
                            Text(t(.widgetDesignSection))
                            Spacer()
                            Text(selectedWidgetDesign.localizedLabel(lang: language))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }

                    if storeManager.isPro {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            HStack(spacing: 12) {
                                settingsIcon("photo.on.rectangle", .blue)
                                Text(t(.widgetBgSelectPhoto))
                            }
                            .padding(.vertical, 4)
                        }
                        .onChange(of: selectedPhotoItem) {
                            guard let item = selectedPhotoItem else { return }
                            Task {
                                if let data = try? await item.loadTransferable(type: Data.self),
                                   let img = UIImage(data: data) {
                                    await MainActor.run {
                                        pickedRawImage = img.normalizedOrientation()
                                        selectedPhotoItem = nil
                                        showCropSheet = true
                                    }
                                }
                            }
                        }

                        if hasWidgetBgImage {
                            Button(role: .destructive) {
                                SharedDataManager.shared.removeWidgetBackgroundImage()
                                widgetBgPreview = nil
                                hasWidgetBgImage = false
                                selectedPhotoItem = nil
                                WidgetCenter.shared.reloadAllTimelines()
                                showSettingsToast(t(.widgetBgRemoved))
                            } label: {
                                HStack(spacing: 12) {
                                    settingsIcon("trash", .red)
                                    Text(t(.widgetBgRemovePhoto))
                                        .foregroundColor(.red)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    } else {
                        HStack(spacing: 12) {
                            settingsIcon("photo.on.rectangle", .blue)
                            Text(t(.widgetBgSelectPhoto))
                            Spacer()
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text("Pro")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(accentColor)
                        }
                        .padding(.vertical, 4)
                        .opacity(0.6)
                    }
                } header: {
                    Text("Widget")
                }

                // MARK: Pro
                if !storeManager.isPro {
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(accentColor)
                                    .font(.system(size: 14))
                                Text(t(.proFeaturePhoto))
                                    .font(.system(size: 14))
                            }
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(accentColor)
                                    .font(.system(size: 14))
                                Text(t(.proFeatureLockWidget))
                                    .font(.system(size: 14))
                            }
                        }
                        .padding(.vertical, 4)

                        Button {
                            Task {
                                let success = await storeManager.purchasePro()
                                if success {
                                    WidgetCenter.shared.reloadAllTimelines()
                                    showSettingsToast(t(.proPurchased))
                                }
                            }
                        } label: {
                            HStack {
                                Spacer()
                                if storeManager.purchaseInProgress {
                                    ProgressView()
                                        .padding(.trailing, 8)
                                }
                                Text(t(.proUpgradeButton))
                                    .font(.system(size: 16, weight: .bold))
                                if let price = storeManager.proProduct?.displayPrice {
                                    Text(price)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                Spacer()
                            }
                            .padding(.vertical, 6)
                            .foregroundColor(background == .black ? .black : .white)
                        }
                        .listRowBackground(accentColor)
                        .disabled(storeManager.purchaseInProgress)

                        Button {
                            isRestoring = true
                            Task {
                                await storeManager.restorePurchases()
                                isRestoring = false
                                if storeManager.isPro {
                                    WidgetCenter.shared.reloadAllTimelines()
                                    showSettingsToast(t(.proRestored))
                                } else {
                                    showSettingsToast(t(.proRestoreFailed))
                                }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                settingsIcon("arrow.clockwise", .gray)
                                Text(t(.proRestoreButton))
                                Spacer()
                                if isRestoring { ProgressView() }
                            }
                            .padding(.vertical, 4)
                        }
                        .disabled(isRestoring)
                    } header: {
                        Text(t(.proSectionTitle))
                    }
                }

                // MARK: General
                Section {
                    // 포인트 색상
                    HStack(spacing: 0) {
                        settingsIcon("paintpalette.fill", .purple)
                            .padding(.trailing, 12)
                        ForEach(availableAccents, id: \.self) { ac in
                            ZStack {
                                Circle()
                                    .fill(ac.color)
                                    .frame(width: 28, height: 28)
                                if accent == ac {
                                    Circle()
                                        .strokeBorder(Color.primary, lineWidth: 2.5)
                                        .frame(width: 28, height: 28)
                                    Circle()
                                        .fill(ac.color)
                                        .frame(width: 20, height: 20)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                accent = ac
                                saveAll()
                            }
                        }
                    }
                    .padding(.vertical, 6)

                    // 배경 테마
                    HStack(spacing: 12) {
                        settingsIcon("circle.lefthalf.filled", .gray)
                        Picker(t(.bgThemeSection), selection: $background) {
                            ForEach(ThemeBackground.allCases, id: \.self) { bg in
                                Text(bg.localizedLabel(lang: language)).tag(bg)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: background) {
                            if background == .white && accent == .white {
                                accent = .yellow
                            } else if background == .black && accent == .black {
                                accent = .yellow
                            }
                            saveAll()
                        }
                    }
                    .padding(.vertical, 4)

                    // 거리 단위
                    HStack(spacing: 12) {
                        settingsIcon("ruler", .teal)
                        Picker(t(.distUnitSection), selection: $distanceUnit) {
                            ForEach(DistanceUnit.allCases, id: \.self) { unit in
                                Text(unit.symbol).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: distanceUnit) {
                            if goalType == .distance {
                                let converted = distanceUnit == .mile
                                    ? goalTarget * DistanceUnit.mile.conversionFromKm
                                    : goalTarget / DistanceUnit.mile.conversionFromKm
                                goalTarget = converted
                                SharedDataManager.shared.saveGoal(type: goalType, target: converted)
                            }
                            saveAll()
                        }
                    }
                    .padding(.vertical, 4)

                    // 언어 선택
                    Picker(selection: $language) {
                        ForEach(AppLanguage.allCases, id: \.self) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            settingsIcon("globe", .blue)
                            Text(t(.languageSection))
                        }
                    }
                    .padding(.vertical, 4)
                    .onChange(of: language) { saveAll() }
                } header: {
                    Text("General")
                }

                // MARK: 알림
                Section {
                    Toggle(isOn: $notificationSettings.isEnabled) {
                        HStack(spacing: 12) {
                            settingsIcon("bell.badge.fill", .red)
                            Text(t(.goalReminderToggle))
                        }
                    }
                    .padding(.vertical, 4)
                    .tint(.primary)
                    .onChange(of: notificationSettings.isEnabled) {
                        if notificationSettings.isEnabled {
                            NotificationManager.shared.requestAuthorization { granted in
                                if !granted {
                                    notificationSettings.isEnabled = false
                                    notifAuthStatus = t(.notifPermError)
                                } else {
                                    notifAuthStatus = ""
                                }
                            }
                        }
                        saveAll()
                    }

                    if notificationSettings.isEnabled {
                        Toggle(t(.d7NotifLabel), isOn: $notificationSettings.d7Enabled)
                            .tint(.primary)
                            .onChange(of: notificationSettings.d7Enabled) { saveAll() }
                        Toggle(t(.d3NotifLabel), isOn: $notificationSettings.d3Enabled)
                            .tint(.primary)
                            .onChange(of: notificationSettings.d3Enabled) { saveAll() }
                        Toggle(t(.d1NotifLabel), isOn: $notificationSettings.d1Enabled)
                            .tint(.primary)
                            .onChange(of: notificationSettings.d1Enabled) { saveAll() }
                    }

                    if !notifAuthStatus.isEmpty {
                        Text(notifAuthStatus)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                } header: {
                    Text(t(.notificationsSection))
                }

                // MARK: 일반
                Section {
                    HStack(spacing: 12) {
                        settingsIcon("info.circle.fill", .gray)
                        Text(t(.versionLabel))
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)

                    if storeManager.isPro {
                        HStack(spacing: 12) {
                            settingsIcon("crown.fill", .yellow)
                            Text(t(.proUnlocked))
                                .foregroundColor(accentColor)
                        }
                        .padding(.vertical, 4)
                    }

                    Button(action: {
                        WidgetCenter.shared.reloadAllTimelines()
                        showSettingsToast(t(.widgetRefreshed))
                    }) {
                        HStack(spacing: 12) {
                            settingsIcon("arrow.clockwise.circle", .green)
                            Text(t(.forceRefreshWidget))
                        }
                        .padding(.vertical, 4)
                    }

                    Button(role: .destructive, action: { showResetConfirm = true }) {
                        HStack(spacing: 12) {
                            settingsIcon("trash.fill", .red)
                            Text(t(.resetDataButton))
                                .foregroundColor(.red)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(t(.settingsTitle))
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(background.colorScheme)
            .confirmationDialog(
                t(.resetConfirmMsg),
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button(t(.resetConfirmButton), role: .destructive) {
                    SharedDataManager.shared.resetAll()
                    NotificationManager.shared.cancelGoalReminders()
                    onReset()
                }
                Button(t(.cancelButton), role: .cancel) {}
            }
            .overlay(alignment: .bottom) {
                if settingsShowToast {
                    Text(settingsToastMsg)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.78))
                        .cornerRadius(24)
                        .padding(.bottom, 40)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: settingsShowToast)
            .sheet(isPresented: $showCropSheet) {
                if let rawImage = pickedRawImage {
                    WidgetImageCropView(image: rawImage, accentColor: accentColor, language: language) { croppedImage in
                        SharedDataManager.shared.saveWidgetBackgroundImage(croppedImage)
                        widgetBgPreview = SharedDataManager.shared.loadWidgetBackgroundImage()
                        hasWidgetBgImage = true
                        WidgetCenter.shared.reloadAllTimelines()
                        showSettingsToast(t(.widgetBgSaved))
                    }
                }
            }
        }
    }

    private func formatGoalLabel() -> String {
        switch goalType {
        case .distance: return "\(Int(goalTarget))\(distanceUnit.symbol)"
        case .calories: return "\(Int(goalTarget))kcal"
        case .duration: return "\(Int(goalTarget))\(t(.durationUnit))"
        }
    }

    private func showSettingsToast(_ msg: String) {
        settingsToastMsg = msg
        withAnimation { settingsShowToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { settingsShowToast = false }
        }
    }
}

// MARK: - 위젯 디자인 선택 뷰

struct WidgetDesignPickerView: View {
    @Binding var selectedDesign: WidgetDesign
    let accent: Color
    let bg: ThemeBackground
    let language: AppLanguage
    var onChanged: () -> Void

    var body: some View {
        Form {
            // 선택된 디자인 프리뷰
            Section {
                WidgetDesignPreview(design: selectedDesign, accent: accent, bg: bg)
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .cornerRadius(16)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            } header: {
                Text("Preview")
            }

            // 디자인 목록
            Section {
                ForEach(WidgetDesign.allCases, id: \.self) { design in
                    Button {
                        selectedDesign = design
                        SharedDataManager.shared.saveWidgetDesign(design)
                        onChanged()
                    } label: {
                        HStack(spacing: 14) {
                            WidgetDesignPreview(design: design, accent: accent, bg: bg)
                                .frame(width: 80, height: 38)
                                .cornerRadius(8)

                            Text(design.localizedLabel(lang: language))
                                .foregroundColor(.primary)

                            Spacer()

                            if selectedDesign == design {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(accent)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle(L(.widgetDesignSection, language))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 위젯 디자인 미니 프리뷰

struct WidgetDesignPreview: View {
    let design: WidgetDesign
    let accent: Color
    let bg: ThemeBackground

    // 기준 크기 140×66 에서의 스케일 계산
    private let refW: CGFloat = 140
    private let refH: CGFloat = 66

    var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width / refW, geo.size.height / refH)
            ZStack {
                bg.cardBg
                previewContent(scale: s)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    @ViewBuilder
    private func previewContent(scale s: CGFloat) -> some View {
        let pad = 8 * s
        let sp1 = 1 * s
        let sp3 = 3 * s
        let sp4 = 4 * s

        switch design {
        case .minimal:
            VStack {
                HStack {
                    Text("7/20").font(.system(size: 6 * s, weight: .medium))
                    Spacer()
                }
                Spacer()
                Text("42.5")
                    .font(.system(size: 18 * s, weight: .black))
                + Text(" km").font(.system(size: 8 * s, weight: .semibold))
                Spacer()
            }
            .foregroundColor(bg.mainText)
            .padding(pad)

        case .compact:
            VStack(alignment: .leading, spacing: sp4) {
                HStack {
                    Text("7/20").font(.system(size: 5 * s, weight: .medium))
                    Spacer()
                    Text("11d").font(.system(size: 5 * s, weight: .bold))
                }
                Spacer()
                Text("42.5")
                    .font(.system(size: 14 * s, weight: .black))
                + Text(" km").font(.system(size: 6 * s, weight: .semibold))
                miniBar(progress: 0.42, height: 4 * s)
            }
            .foregroundColor(bg.mainText)
            .padding(pad)

        case .balanced:
            VStack(alignment: .leading, spacing: sp3) {
                HStack {
                    Text("7/20").font(.system(size: 5 * s, weight: .medium))
                    Spacer()
                    Text("11d").font(.system(size: 5 * s, weight: .bold))
                }
                Spacer()
                HStack(alignment: .bottom) {
                    Text("42.5")
                        .font(.system(size: 14 * s, weight: .black))
                    + Text(" km").font(.system(size: 6 * s, weight: .semibold))
                    Spacer()
                    VStack(alignment: .trailing, spacing: sp1) {
                        Text("Mileage").font(.system(size: 4 * s, weight: .medium)).foregroundColor(bg.subText)
                        Text("100km").font(.system(size: 7 * s, weight: .bold))
                    }
                }
                miniBar(progress: 0.42, height: 4 * s)
            }
            .foregroundColor(bg.mainText)
            .padding(pad)

        case .complete:
            VStack(alignment: .leading, spacing: sp3) {
                HStack {
                    Text("7/20").font(.system(size: 5 * s, weight: .medium))
                    Text("·").foregroundColor(bg.subText)
                    Text("11d").font(.system(size: 5 * s, weight: .bold)).foregroundColor(accent)
                    Spacer()
                }
                HStack(spacing: sp4) {
                    (Text("42.5")
                        .font(.system(size: 14 * s, weight: .black))
                    + Text(" km").font(.system(size: 6 * s, weight: .semibold)).foregroundColor(bg.subText))
                    miniBar(progress: 0.42, height: 4 * s)
                }
                HStack {
                    VStack(alignment: .leading, spacing: sp1) {
                        Text("100km").font(.system(size: 5 * s, weight: .bold)).foregroundColor(accent)
                        Text("Mileage").font(.system(size: 4 * s)).foregroundColor(bg.subText)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: sp1) {
                        Text("57.5km").font(.system(size: 5 * s, weight: .bold)).foregroundColor(accent)
                        Text("Left").font(.system(size: 4 * s)).foregroundColor(bg.subText)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: sp1) {
                        Text("5.2km").font(.system(size: 5 * s, weight: .bold)).foregroundColor(accent)
                        Text("/run").font(.system(size: 4 * s)).foregroundColor(bg.subText)
                    }
                }
            }
            .foregroundColor(bg.mainText)
            .padding(pad)
        }
    }

    private func miniBar(progress: Double, height: CGFloat) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(bg.grayBg)
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(accent)
                    .frame(width: geo.size.width * CGFloat(progress))
            }
        }
        .frame(height: height)
    }
}

// MARK: - 위젯 배경 이미지 크롭 뷰

struct WidgetImageCropView: View {
    @Environment(\.dismiss) var dismiss
    let image: UIImage
    let accentColor: Color
    let language: AppLanguage
    var onSave: (UIImage) -> Void

    // Medium 위젯 비율
    private let cropAspect: CGFloat = 360.0 / 169.0

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var currentCropW: CGFloat = 400  // 실제 화면 크롭 폭 (renderCrop 동기화용)

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                GeometryReader { geo in
                    let cropW = geo.size.width - 32
                    let cropH = cropW / cropAspect
                    let fill  = fillSize(cropW: cropW, cropH: cropH)
                    let imgW  = fill.width * scale
                    let imgH  = fill.height * scale

                    VStack(spacing: 16) {
                        Text(L(.widgetCropHint, language))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))

                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: imgW, height: imgH)
                                .offset(offset)

                            CropOverlay(cropW: cropW, cropH: cropH)
                        }
                        .frame(width: cropW, height: cropH)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { v in
                                    offset = CGSize(
                                        width: lastOffset.width + v.translation.width,
                                        height: lastOffset.height + v.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    clampOffset(cropW: cropW, cropH: cropH)
                                }
                        )
                        .simultaneousGesture(
                            MagnifyGesture()
                                .onChanged { v in
                                    scale = min(max(lastScale * v.magnification, 1.0), 5.0)
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                    clampOffset(cropW: cropW, cropH: cropH)
                                }
                        )
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .onAppear { currentCropW = cropW }
                    .onChange(of: geo.size) { currentCropW = geo.size.width - 32 }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L(.cancelButton, language)) { dismiss() }
                        .foregroundColor(.white.opacity(0.8))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L(.widgetCropDone, language)) {
                        onSave(renderCrop())
                        dismiss()
                    }
                    .bold()
                    .foregroundColor(accentColor)
                }
            }
        }
    }

    // MARK: - 이미지가 크롭 영역을 꽉 채우는 크기 (aspect fill, scale=1 기준)

    private func fillSize(cropW: CGFloat, cropH: CGFloat) -> CGSize {
        let imgAspect = image.size.width / image.size.height
        let cAspect   = cropW / cropH
        if imgAspect > cAspect {
            // 이미지가 더 넓음 → 높이 맞춤
            return CGSize(width: cropH * imgAspect, height: cropH)
        } else {
            // 이미지가 더 좁거나 같음 → 너비 맞춤
            return CGSize(width: cropW, height: cropW / imgAspect)
        }
    }

    // MARK: - 바운드 클램핑 (이미지가 크롭 영역 바깥으로 나가지 않게)

    private func clampOffset(cropW: CGFloat, cropH: CGFloat) {
        let fill = fillSize(cropW: cropW, cropH: cropH)
        let imgW = fill.width * scale
        let imgH = fill.height * scale
        let maxX = max((imgW - cropW) / 2, 0)
        let maxY = max((imgH - cropH) / 2, 0)
        withAnimation(.easeOut(duration: 0.2)) {
            offset.width  = min(max(offset.width, -maxX), maxX)
            offset.height = min(max(offset.height, -maxY), maxY)
        }
        lastOffset = offset
    }

    // MARK: - 크롭 렌더링

    private func renderCrop() -> UIImage {
        let cropW = currentCropW
        let cropH = cropW / cropAspect

        let fill = fillSize(cropW: cropW, cropH: cropH)
        let imgW = fill.width * scale
        let imgH = fill.height * scale

        // 이미지 중심은 크롭 중심에서 offset만큼 이동
        // → 이미지 draw origin = (cropW/2 - imgW/2 + offset.width,
        //                         cropH/2 - imgH/2 + offset.height)
        let drawX = (cropW - imgW) / 2 + offset.width
        let drawY = (cropH - imgH) / 2 + offset.height

        // UIGraphicsImageRenderer로 크롭 — orientation 자동 반영
        let outputSize = CGSize(width: cropW, height: cropH)
        let renderer = UIGraphicsImageRenderer(size: outputSize)
        return renderer.image { _ in
            image.draw(in: CGRect(x: drawX, y: drawY, width: imgW, height: imgH))
        }
    }
}

// MARK: - 크롭 오버레이 (반투명 마스크 + 테두리)

private struct CropOverlay: View {
    let cropW: CGFloat
    let cropH: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(Color.white.opacity(0.7), lineWidth: 2)
            .frame(width: cropW, height: cropH)
            .allowsHitTesting(false)
    }
}
