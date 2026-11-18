import Foundation

/// 一条快递记录，App 和小组件共用（放在 Shared 目录，两个 target 都会编译）
struct PackageItem: Codable, Identifiable, Hashable {
    var id: UUID
    var code: String
    var note: String
    var isPicked: Bool
    var createdAt: Date
    var pickedAt: Date?

    init(id: UUID = UUID(),
         code: String,
         note: String = "",
         isPicked: Bool = false,
         createdAt: Date = Date(),
         pickedAt: Date? = nil) {
        self.id = id
        self.code = code
        self.note = note
        self.isPicked = isPicked
        self.createdAt = createdAt
        self.pickedAt = pickedAt
    }
}
