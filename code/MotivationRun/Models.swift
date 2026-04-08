//
//  Models.swift
//  MotivationRun
//
//  ⚠️ 메인 앱 타겟 + 위젯 타겟 양쪽 Target Membership 체크 필수

import Foundation
import SwiftUI

// MARK: - AppLanguage

enum AppLanguage: String, Codable, CaseIterable {
    case english = "en"
    case korean  = "ko"
    case german  = "de"
    case french  = "fr"
    case chinese = "zh"
    case spanish = "es"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .korean:  return "한국어"
        case .german:  return "Deutsch"
        case .french:  return "Français"
        case .chinese: return "中文"
        case .spanish: return "Español"
        }
    }

    var locale: Locale { Locale(identifier: rawValue) }
}

// MARK: - GoalType

enum GoalType: String, Codable, CaseIterable {
    case distance  // "km" or "mi"
    case calories  // "kcal"
    case duration  // "hr"

    /// 내부 저장 단위 (표시 레이어에서 변환)
    var unit: String {
        switch self {
        case .distance: return "km"
        case .calories: return "kcal"
        case .duration: return "hr"
        }
    }

    func localizedDisplayName(lang: AppLanguage) -> String {
        switch self {
        case .distance: return L(.goalTypeDistance, lang)
        case .calories: return L(.goalTypeCalories, lang)
        case .duration: return L(.goalTypeDuration, lang)
        }
    }

    /// 표시 단위 (거리는 distanceUnit에 따라 km 또는 mi, 시간은 언어별)
    func displayUnit(distanceUnit: DistanceUnit, lang: AppLanguage = .english) -> String {
        switch self {
        case .distance: return distanceUnit.symbol
        case .calories: return "kcal"
        case .duration: return L(.durationUnit, lang)
        }
    }

    /// 기본 목표값: distance=100km / calories=10000kcal / duration=10시간(hour)
    var defaultTarget: Double {
        switch self {
        case .distance: return 100
        case .calories: return 10000
        case .duration: return 10
        }
    }
}

// MARK: - RunFrequency

enum RunFrequency: Int, Codable, CaseIterable {
    case daily      = 1
    case everyOther = 2
    case every3Days = 3

    func localizedLabel(lang: AppLanguage) -> String {
        switch self {
        case .daily:      return L(.freqDailyLabel, lang)
        case .everyOther: return L(.freqEveryOtherLabel, lang)
        case .every3Days: return L(.freqEvery3DaysLabel, lang)
        }
    }

    /// "매일 러닝 시" / "Daily run" 형태 (카드 우측 & 위젯에 사용)
    func localizedRunLabel(lang: AppLanguage) -> String {
        switch self {
        case .daily:      return L(.freqDailyRun, lang)
        case .everyOther: return L(.freqEveryOtherRun, lang)
        case .every3Days: return L(.freqEvery3DaysRun, lang)
        }
    }

    /// 남은 일수를 기준으로 예상 러닝 횟수 반환 (최소 1.0)
    func expectedSessions(remainingDays: Int) -> Double {
        max(Double(remainingDays) / Double(rawValue), 1.0)
    }
}

// MARK: - DistanceUnit

enum DistanceUnit: String, Codable, CaseIterable {
    case km, mile

    func localizedLabel(lang: AppLanguage) -> String {
        self == .km ? L(.unitKilometer, lang) : L(.unitMile, lang)
    }

    var symbol: String {
        switch self {
        case .km:   return "km"
        case .mile: return "mi"
        }
    }

    /// 킬로미터 → 선택 단위 변환 계수
    var conversionFromKm: Double {
        self == .mile ? 0.621371 : 1.0
    }
}

// MARK: - ThemeAccent

enum ThemeAccent: String, Codable, CaseIterable {
    case red, orange, yellow, green, blue, navy, purple, white, black

    var label: String {
        switch self {
        case .red:    return "빨강"
        case .orange: return "주황"
        case .yellow: return "노랑"
        case .green:  return "초록"
        case .blue:   return "파랑"
        case .navy:   return "남색"
        case .purple: return "보라"
        case .white:  return "하양"
        case .black:  return "검정"
        }
    }

    var color: Color {
        switch self {
        case .red:    return Color(red: 1.0,   green: 0.231, blue: 0.188)
        case .orange: return Color(red: 1.0,   green: 0.584, blue: 0.0)
        case .yellow: return Color(red: 0.961, green: 0.784, blue: 0.0)
        case .green:  return Color(red: 0.204, green: 0.780, blue: 0.349)
        case .blue:   return Color(red: 0.0,   green: 0.478, blue: 1.0)
        case .navy:   return Color(red: 0.0,   green: 0.188, blue: 0.529)
        case .purple: return Color(red: 0.686, green: 0.322, blue: 0.871)
        case .white:  return Color.white
        case .black:  return Color(red: 0.067, green: 0.067, blue: 0.067)
        }
    }

    /// 포인트 색상 위에 올라가는 텍스트/아이콘 색상
    var foregroundColor: Color {
        switch self {
        case .yellow, .orange, .green, .white: return Color(red: 0.067, green: 0.067, blue: 0.067)
        case .red, .blue, .navy, .purple, .black: return .white
        }
    }
}

// MARK: - ThemeBackground

enum ThemeBackground: String, Codable, CaseIterable {
    case black, white

    func localizedLabel(lang: AppLanguage) -> String {
        self == .black ? L(.themeDark, lang) : L(.themeLight, lang)
    }

    var isDark: Bool  { self == .black }
    var colorScheme: ColorScheme { isDark ? .dark : .light }

    var appBg:    Color { isDark ? Color(red: 0.067, green: 0.067, blue: 0.067) : Color(red: 0.949, green: 0.949, blue: 0.957) }
    var cardBg:   Color { isDark ? Color(red: 0.110, green: 0.110, blue: 0.118) : Color.white }
    var grayBg:   Color { isDark ? Color(red: 0.227, green: 0.227, blue: 0.235) : Color(red: 0.820, green: 0.820, blue: 0.839) }
    var subText:  Color { isDark ? Color(red: 0.557, green: 0.557, blue: 0.576) : Color(red: 0.427, green: 0.427, blue: 0.447) }
    var mainText: Color { isDark ? Color.white : Color(red: 0.067, green: 0.067, blue: 0.067) }
}

// MARK: - WidgetDesign

enum WidgetDesign: String, Codable, CaseIterable {
    case minimal, compact, balanced, complete

    func localizedLabel(lang: AppLanguage) -> String {
        switch self {
        case .minimal:  return L(.widgetDesignMinimal, lang)
        case .compact:  return L(.widgetDesignCompact, lang)
        case .balanced: return L(.widgetDesignBalanced, lang)
        case .complete: return L(.widgetDesignComplete, lang)
        }
    }
}

// MARK: - NotificationSettings

struct NotificationSettings: Codable {
    var isEnabled: Bool = false
    var d7Enabled: Bool = true   // 월말 7일 전 알림
    var d3Enabled: Bool = true   // 월말 3일 전 알림
    var d1Enabled: Bool = false  // 월말 1일 전 알림
}

// MARK: - RunSession

struct RunSession: Codable, Identifiable {
    var id: UUID
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

// MARK: - MonthlyStats

struct MonthlyStats: Codable {
    var year: Int
    var month: Int
    var totalDistanceKm: Double
    var totalCalories: Double
    var totalDurationMinutes: Double
    var goalType: GoalType
    var goalTarget: Double
    var lastSyncTime: Date
    var activitiesCount: Int
    var sessions: [RunSession]

    /// goalType에 따른 현재 달성값 (거리는 km 기준 — 표시 레이어에서 단위 변환)
    var currentValue: Double {
        switch goalType {
        case .distance: return totalDistanceKm
        case .calories: return totalCalories
        case .duration: return totalDurationMinutes / 60
        }
    }

    /// distanceUnit을 적용한 표시용 달성값 (streak/알림 비교에 사용)
    func displayCurrentValue(distanceUnit: DistanceUnit) -> Double {
        switch goalType {
        case .distance: return totalDistanceKm * distanceUnit.conversionFromKm
        case .calories: return totalCalories
        case .duration: return totalDurationMinutes / 60
        }
    }
}
