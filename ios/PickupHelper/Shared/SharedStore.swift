import Foundation

/// 数据文件的位置。
/// 优先用 App Group 容器（App 和小组件共享）；如果拿不到（比如免费签名没有 App Group 权限），
/// 就退回到 App 自己的 Documents 目录，App 照常能用，只是小组件读不到数据。
enum SharedStore {
    static let appGroupID = "group.com.pickuphelper.shared"

    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    static var fileURL: URL {
        if let container = containerURL {
            return container.appendingPathComponent("packages.json")
        }
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("packages.json")
    }

    static func load() -> [PackageItem] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([PackageItem].self, from: data)) ?? []
    }

    static func save(_ items: [PackageItem]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
