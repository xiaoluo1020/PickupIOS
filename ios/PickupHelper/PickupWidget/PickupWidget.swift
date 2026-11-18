import WidgetKit
import SwiftUI

struct PickupEntry: TimelineEntry {
    let date: Date
    let pending: [PackageItem]
}

struct PickupProvider: TimelineProvider {
    func placeholder(in context: Context) -> PickupEntry {
        PickupEntry(date: Date(),
                    pending: [PackageItem(code: "8-3-1024"),
                              PackageItem(code: "6-2-2048")])
    }

    func getSnapshot(in context: Context, completion: @escaping (PickupEntry) -> Void) {
        let pending = SharedStore.load().filter { !$0.isPicked }
        completion(PickupEntry(date: Date(), pending: pending))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PickupEntry>) -> Void) {
        let pending = SharedStore.load().filter { !$0.isPicked }
        let entry = PickupEntry(date: Date(), pending: pending)
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date())
            ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct PickupWidgetView: View {
    var entry: PickupEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "shippingbox.fill")
                    .foregroundStyle(.orange)
                Text("待取快递")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(entry.pending.count)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(entry.pending.isEmpty ? Color.green : Color.red)
                Text("件")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }

            if entry.pending.isEmpty {
                Text("全部取完了")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if family == .systemMedium {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(entry.pending.prefix(3)) { item in
                        Text(item.code)
                            .font(.system(.caption, design: .monospaced))
                            .lineLimit(1)
                    }
                }
            } else {
                Text(entry.pending.first?.code ?? "")
                    .font(.system(.caption, design: .monospaced))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct PickupWidget: Widget {
    let kind = "PickupWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PickupProvider()) { entry in
            PickupWidgetView(entry: entry)
        }
        .configurationDisplayName("快递取件")
        .description("显示还没取的快递数量，以及最近的取件码。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct PickupWidgetBundle: WidgetBundle {
    var body: some Widget {
        PickupWidget()
    }
}
