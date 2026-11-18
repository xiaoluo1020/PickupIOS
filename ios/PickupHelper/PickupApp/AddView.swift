import SwiftUI
import UIKit

struct AddView: View {
    @EnvironmentObject private var store: PackageStore
    @Environment(\.dismiss) private var dismiss

    @State private var code = ""
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("取件码") {
                    TextField("比如 8-3-1024", text: $code)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .font(.system(.title3, design: .monospaced))
                }

                Section("备注（可选）") {
                    TextField("菜鸟驿站 / 丰巢快递柜……", text: $note)
                }

                Section {
                    Button {
                        if let text = UIPasteboard.general.string {
                            code = PackageStore.extractCode(from: text)
                        }
                    } label: {
                        Label("粘贴短信并识别", systemImage: "doc.on.clipboard")
                    }
                }

                Section {
                    Text("可以直接粘贴整条取件短信，程序会自动识别「取件码：xxx」里的取件码。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("添加取件码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        store.add(code: code, note: note)
                        dismiss()
                    }
                    .disabled(code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
