//
//  RunSessionDetailView.swift
//  MotivationRun
//

import SwiftUI

private let detailDateFormatter: DateFormatter = {
    let f = DateFormatter()
    return f
}()

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
        detailDateFormatter.locale = appLanguage.locale
        detailDateFormatter.setLocalizedDateFormatFromTemplate("EEEdMMM")
        return detailDateFormatter.string(from: session.date)
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
                difficultyCard
                notesCard
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

    // MARK: - Difficulty Card

    private var difficultyCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(t(.journalDifficultyLabel))
                .font(.pretendard(.semiBold, size: 14))
                .foregroundColor(cText)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 14)

            if session.hkWorkoutID != nil {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Spacer()
                        Text(difficultyLabel(difficulty))
                            .font(.pretendard(.medium, size: 13))
                            .foregroundColor(cAccent)
                    }
                    Slider(value: $difficulty, in: 0...1)
                        .tint(cAccent)
                    HStack {
                        Text(t(.difficultyVeryEasy))
                        Spacer()
                        Text(t(.difficultyModerate))
                        Spacer()
                        Text(t(.difficultyVeryHard))
                    }
                    .font(.pretendard(.medium, size: 10))
                    .foregroundColor(themeBackground.inkOff)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
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

    // MARK: - Notes Card

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(t(.journalDiaryLabel))
                .font(.pretendard(.semiBold, size: 14))
                .foregroundColor(cText)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 14)

            if session.hkWorkoutID != nil {
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
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
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
