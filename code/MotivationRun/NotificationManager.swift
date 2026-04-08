//
//  NotificationManager.swift
//  MotivationRun
//
//  ⚠️ 메인 앱 타겟만 포함 (위젯 타겟 불필요)
//

import UserNotifications
import Foundation

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // 알림 ID 상수
    private let idD7 = "motivationrun_goal_d7"
    private let idD3 = "motivationrun_goal_d3"
    private let idD1 = "motivationrun_goal_d1"

    // MARK: - 시스템 권한 요청

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ [Notification] 권한 요청 오류: \(error.localizedDescription)")
            }
            DispatchQueue.main.async { completion(granted) }
        }
    }

    // MARK: - 목표 리마인더 스케줄

    /// 현재 월 기준 D-7, D-3, D-1 알림 스케줄
    /// - 기존 동일 ID 알림은 먼저 제거 후 재등록
    func scheduleGoalReminders(remaining: Double, goalType: GoalType,
                               distanceUnit: DistanceUnit, settings: NotificationSettings) {
        cancelGoalReminders()
        guard settings.isEnabled && remaining > 0 else { return }

        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else { return }

        let reminders: [(daysFromEnd: Int, enabled: Bool, id: String)] = [
            (7, settings.d7Enabled, idD7),
            (3, settings.d3Enabled, idD3),
            (1, settings.d1Enabled, idD1),
        ]

        for r in reminders where r.enabled {
            guard let fireDate = calendar.date(byAdding: .day, value: -r.daysFromEnd, to: startOfNextMonth),
                  fireDate > now else { continue }

            var components = calendar.dateComponents([.year, .month, .day], from: fireDate)
            components.hour   = 9
            components.minute = 0

            let content = UNMutableNotificationContent()
            content.title = L(.notifTitle, SharedDataManager.shared.getLanguage())
            content.body  = notificationBody(remaining: remaining, goalType: goalType,
                                             distanceUnit: distanceUnit, daysLeft: r.daysFromEnd)
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: r.id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ [Notification] 등록 실패 (\(r.id)): \(error.localizedDescription)")
                } else {
                    print("🔔 [Notification] 등록 완료: D-\(r.daysFromEnd) → \(fireDate)")
                }
            }
        }
    }

    func cancelGoalReminders() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [idD7, idD3, idD1])
    }

    // MARK: - 알림 본문 생성

    private func notificationBody(remaining: Double, goalType: GoalType,
                                  distanceUnit: DistanceUnit, daysLeft: Int) -> String {
        let lang = SharedDataManager.shared.getLanguage()
        let unit = goalType.displayUnit(distanceUnit: distanceUnit, lang: lang)
        let formatted: String
        switch goalType {
        case .distance: formatted = String(format: "%.1f\(unit)", remaining)
        case .calories: formatted = "\(Int(remaining))\(unit)"
        case .duration: formatted = String(format: "%.1f\(unit)", remaining)
        }
        if daysLeft == 1 {
            return String(format: L(.notifBodyLastDay, lang), formatted)
        } else {
            return String(format: L(.notifBodyDaysFmt, lang), formatted, daysLeft)
        }
    }
}
