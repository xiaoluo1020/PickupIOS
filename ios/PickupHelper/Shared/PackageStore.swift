import Foundation
import WidgetKit

/// App 里的数据仓库：增删改查 + 保存 + 通知/小组件刷新
final class PackageStore: ObservableObject {
    @Published private(set) var items: [PackageItem] = []

    init() {
        items = SharedStore.load()
        sortItems()
        NotificationScheduler.shared.reschedule(items: items)
    }

    var pendingItems: [PackageItem] {
        items.filter { !$0.isPicked }
    }

    var pickedCount: Int {
        items.count - pendingItems.count
    }

    var todayCount: Int {
        items.filter { Calendar.current.isDateInToday($0.createdAt) }.count
    }

    func reload() {
        items = SharedStore.load()
        sortItems()
        NotificationScheduler.shared.reschedule(items: items)
        WidgetCenter.shared.reloadAllTimelines()
    }

    func add(code: String, note: String) {
        let raw = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return }

        let finalCode = PackageStore.extractCode(from: raw)
        if items.contains(where: { !$0.isPicked && $0.code == finalCode }) {
            return
        }

        let item = PackageItem(code: finalCode,
                               note: note.trimmingCharacters(in: .whitespacesAndNewlines))
        items.insert(item, at: 0)
        persist()
    }

    func toggle(_ item: PackageItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isPicked.toggle()
        items[index].pickedAt = items[index].isPicked ? Date() : nil
        persist()
    }

    func delete(_ item: PackageItem) {
        items.removeAll { $0.id == item.id }
        persist()
    }

    private func persist() {
        sortItems()
        SharedStore.save(items)
        NotificationScheduler.shared.reschedule(items: items)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func sortItems() {
        items.sort { lhs, rhs in
            if lhs.isPicked != rhs.isPicked {
                return !lhs.isPicked
            }
            return lhs.createdAt > rhs.createdAt
        }
    }

    /// 从整条短信里提取取件码
    static func extractCode(from raw: String) -> String {
        let patterns = [
            #"取件码[\s:：是为]*([A-Za-z0-9][A-Za-z0-9\-]{1,24})"#,
            #"取货码[\s:：是为]*([A-Za-z0-9][A-Za-z0-9\-]{1,24})"#,
            #"提货码[\s:：是为]*([A-Za-z0-9][A-Za-z0-9\-]{1,24})"#
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: raw, range: NSRange(raw.startIndex..., in: raw)),
               let range = Range(match.range(at: 1), in: raw) {
                return String(raw[range]).uppercased()
            }
        }

        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.range(of: #"^[A-Za-z0-9\-]{2,24}$"#, options: .regularExpression) != nil {
            return trimmed.uppercased()
        }
        return String(trimmed.prefix(24)).uppercased()
    }
}
