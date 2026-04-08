//
//  LogView.swift
//  MotivationRun
//

import SwiftUI

// MARK: - 월별 그룹

struct MonthGroup: Identifiable {
    let id: String           // "2025-02" (정렬용)
    let yearMonth: String    // "2025년 2월" (표시용)
    let sessions: [RunSession]  // 날짜 내림차순 정렬
}

// MARK: - 러닝 로그 뷰

struct LogView: View {
    let themeAccent: ThemeAccent
    let themeBackground: ThemeBackground
    let distanceUnit: DistanceUnit
    let appLanguage: AppLanguage

    @State private var monthGroups: [MonthGroup] = []
    @State private var isLoading = false

    private func t(_ key: LK) -> String { L(key, appLanguage) }
    private var cAccent: Color  { themeAccent.color }
    private var cBg:     Color  { themeBackground.appBg }
    private var cCard:   Color  { themeBackground.cardBg }
    private var cGray:   Color  { themeBackground.grayBg }
    private var cText:   Color  { themeBackground.mainText }
    private var cSub:    Color  { themeBackground.subText }

    var body: some View {
        ZStack {
            cBg.ignoresSafeArea()

            if isLoading {
                ProgressView()
                    .tint(cAccent)
            } else if monthGroups.isEmpty {
                Text(t(.noRunsMsg))
                    .font(.system(size: 15))
                    .foregroundColor(cSub)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                        ForEach(monthGroups) { group in
                            Section {
                                ForEach(Array(group.sessions.enumerated()), id: \.element.id) { index, session in
                                    HStack {
                                        Spacer(minLength: 0)
                                        RunSessionCard(
                                            session: session,
                                            runNumber: group.sessions.count - index,
                                            distanceUnit: distanceUnit,
                                            language: appLanguage,
                                            cAccent: cAccent,
                                            cCard: cCard,
                                            cText: cText,
                                            cSub: cSub
                                        )
                                        .frame(maxWidth: UIScreen.main.bounds.width * 0.80)
                                        Spacer(minLength: 0)
                                    }
                                    .padding(.bottom, 10)
                                }
                            } header: {
                                Text(group.yearMonth)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(cSub)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(cBg)
                            }
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }
                .clipped()
            }
        }
        .preferredColorScheme(themeBackground.colorScheme)
        .onAppear { fetchSessions() }
    }

    private func fetchSessions() {
        guard !isLoading else { return }
        isLoading = true
        HealthKitService.shared.fetchAllRunningSessions { sessions in
            monthGroups = groupByMonth(sessions: sessions)
            isLoading = false
        }
    }

    private func groupByMonth(sessions: [RunSession]) -> [MonthGroup] {
        let cal = Calendar.current
        let fmt: DateFormatter = {
            let f = DateFormatter()
            f.locale = appLanguage.locale
            f.dateFormat = t(.monthYearDateFormat)
            return f
        }()

        var dict: [String: [RunSession]] = [:]
        for session in sessions {
            let comps = cal.dateComponents([.year, .month], from: session.date)
            let key = String(format: "%04d-%02d", comps.year ?? 0, comps.month ?? 0)
            dict[key, default: []].append(session)
        }

        return dict.keys.sorted(by: >).map { key in
            let groupSessions = (dict[key] ?? []).sorted { $0.date > $1.date }
            let displayDate = groupSessions.first?.date ?? Date()
            return MonthGroup(
                id: key,
                yearMonth: fmt.string(from: displayDate),
                sessions: groupSessions
            )
        }
    }
}

// MARK: - 러닝 세션 카드

struct RunSessionCard: View {
    let session: RunSession
    let runNumber: Int
    let distanceUnit: DistanceUnit
    let language: AppLanguage
    let cAccent: Color
    let cCard: Color
    let cText: Color
    let cSub: Color

    private var distance: Double { session.distanceKm * distanceUnit.conversionFromKm }

    private var distanceStr: String { String(format: "%.1f", distance) }

    private var durationStr: String {
        let total = Int(session.durationMinutes)
        let h = total / 60
        let m = total % 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }

    private var caloriesStr: String {
        session.calories > 0 ? String(format: "%.0f", session.calories) : "-"
    }

    private var paceStr: String {
        guard distance > 0 else { return "-" }
        let pacePerUnit = session.durationMinutes / distance
        let totalSec = Int(pacePerUnit * 60)
        let m = totalSec / 60
        let s = totalSec % 60
        return "\(m)'\(String(format: "%02d", s))\""
    }

    private var dateStr: String {
        let f = DateFormatter()
        f.locale = language.locale
        f.dateFormat = L(.shortDateFormat, language)
        return f.string(from: session.date)
    }

    var body: some View {
        HStack(spacing: 0) {
            // 러닝 번호 배지
            ZStack {
                Circle()
                    .fill(cAccent.opacity(0.15))
                    .frame(width: 38, height: 38)
                Text("#\(runNumber)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(cAccent)
            }
            .padding(.trailing, 12)

            // 날짜
            VStack(alignment: .leading, spacing: 2) {
                Text(dateStr)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(cText)
                Text(L(.columnDate, language))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(cSub)
            }
            .frame(width: 44, alignment: .leading)

            Spacer()

            // 거리
            statColumn(value: distanceStr, unit: distanceUnit.symbol)

            divider

            // 시간
            statColumn(value: durationStr, unit: L(.columnTime, language))

            divider

            // 칼로리
            statColumn(value: caloriesStr, unit: "kcal")

            divider

            // 페이스
            statColumn(value: paceStr, unit: "/\(distanceUnit.symbol)")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(cCard)
        .cornerRadius(14)
    }

    private var divider: some View {
        Rectangle()
            .fill(cSub.opacity(0.2))
            .frame(width: 1, height: 28)
            .padding(.horizontal, 10)
    }

    private func statColumn(value: String, unit: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(cText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            if !unit.isEmpty {
                Text(unit)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(cSub)
            }
        }
        .frame(minWidth: 44)
    }
}
