import Foundation
import UserNotifications

/// 本地通知：每天固定时间提醒还有几件没取，并把 App 图标角标设成待取数量
final class NotificationScheduler {
    static let shared = NotificationScheduler()

    private let identifier = "daily-pickup-reminder"
    private let hourKey = "dailyReminderHour"

    var reminderHour: Int {
        get {
            if let stored = UserDefaults.standard.object(forKey: hourKey) as? Int {
                return stored
            }
            return 18
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hourKey)
        }
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func reschedule(items: [PackageItem]) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let pending = items.filter { !$0.isPicked }
        center.setBadgeCount(pending.count)

        guard !pending.isEmpty else { return }

        var components = DateComponents()
        components.hour = reminderHour
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = "还有 \(pending.count) 件快递没取"
        content.body = pending.prefix(6).map { $0.code }.joined(separator: "、")
        content.sound = .default

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request)
    }
}
