import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject private var store: PackageStore
    @State private var showingAdd = false
    @State private var onlyPending = false

    private var visibleItems: [PackageItem] {
        onlyPending ? store.pendingItems : store.items
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 0) {
                        statView(title: "待取", value: store.pendingItems.count, color: .red)
                        Divider().frame(height: 32)
                        statView(title: "已取", value: store.pickedCount, color: .secondary)
                        Divider().frame(height: 32)
                        statView(title: "今天", value: store.todayCount, color: .primary)
                    }
                    .padding(.vertical, 6)
                }

                if store.items.isEmpty {
                    Section {
                        VStack(spacing: 10) {
                            Image(systemName: "shippingbox")
                                .font(.system(size: 38))
                                .foregroundStyle(.orange)
                            Text("还没有取件记录")
                                .font(.headline)
                            Text("收到取件短信后，点右上角 + 添加")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    }
                } else {
                    Section {
                        ForEach(visibleItems) { item in
                            rowView(item)
                        }
                    } header: {
                        Text(onlyPending ? "只看未取" : "全部记录")
                    }
                }
            }
            .navigationTitle("快递取件")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onlyPending.toggle()
                    } label: {
                        Image(systemName: onlyPending
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddView()
                    .environmentObject(store)
            }
        }
        .onAppear {
            store.reload()
            NotificationScheduler.shared.requestAuthorization()
        }
    }

    private func statView(title: String, value: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func rowView(_ item: PackageItem) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.code)
                    .font(.system(.title3, design: .monospaced).weight(.bold))
                    .strikethrough(item.isPicked)
                HStack(spacing: 6) {
                    if !item.note.isEmpty {
                        Text(item.note)
                    }
                    Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Button {
                store.toggle(item)
            } label: {
                Text(item.isPicked ? "未取货" : "已取货")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(item.isPicked ? Color.gray.opacity(0.18) : Color.green)
                    .foregroundStyle(item.isPicked ? Color.secondary : Color.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                store.delete(item)
            } label: {
                Label("删除", systemImage: "trash")
            }

            Button {
                UIPasteboard.general.string = item.code
            } label: {
                Label("复制", systemImage: "doc.on.doc")
            }
            .tint(.blue)
        }
    }
}
