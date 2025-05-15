import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: ReminderStore
    
    private var todayTasks: [Reminder] {
        store.reminders(on: Date())
            .filter{ !$0.isNoNotification }
    }
    private var noNotifyTasks: [Reminder] {
        store.reminders.filter { $0.isNoNotification }
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                
                // ─ 上半分: 今日のタスク ─────────────────────────────
                List {
                    Section(header: Text("今日のタスク")
                        .foregroundColor(.primary)
                        .font(.system(size: 20, weight: .bold))
                    ) {
                        // 空ならメッセージ、そうでなければ一覧
                        if todayTasks.isEmpty {
                            Text("タスクはありません")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                                .listRowSeparator(.hidden)
                        } else {
                            ForEach(todayTasks, id: \.id) { item in
                                rowView(for: item)
                            }
                            .onDelete(perform: deleteToday)
                        }
                    }
                }
                .listStyle(.plain)
                // 上半分に固定
                .frame(height: geo.size.height * 0.5)
                
                Divider()  // 画面中央の区切り
                
                // ─ 下半分: 通知をしないタスク ────────────────────────
                List {
                    Section(header: Text("通知をしないタスク")
                        .foregroundColor(.primary)
                        .font(.system(size: 20, weight: .bold))
                    ) {
                        if noNotifyTasks.isEmpty {
                            Text("該当タスクはありません")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                                .listRowSeparator(.hidden)
                        } else {
                            ForEach(noNotifyTasks, id: \.id) { item in
                                rowView(for: item)
                            }
                            .onDelete(perform: deleteNoNotify)
                        }
                    }
                }
                .listStyle(.plain)
                .frame(height: geo.size.height * 0.5)
            }
        }
    }
    
    // MARK: 共通の行ビュー
    @ViewBuilder
    private func rowView(for item: Reminder) -> some View {
        HStack {
            Image(systemName: item.isChecked ? "checkmark.square" : "square")
                .onTapGesture {
                    toggleChecked(item)
                }
            Text(item.title)
            Spacer()
            if item.isNoNotification {
                Text("―").foregroundColor(.gray)
            } else {
                Text(item.date, style: .time)
            }
        }
        .padding(.vertical, 6)
    }
    
    // MARK: 操作メソッド
    private func toggleChecked(_ item: Reminder) {
        guard let idx = store.reminders.firstIndex(where: { $0.id == item.id }) else { return }
        store.reminders[idx].isChecked.toggle()
    }
    private func deleteToday(at offsets: IndexSet) {
        delete(offsets, from: todayTasks)
    }
    private func deleteNoNotify(at offsets: IndexSet) {
        delete(offsets, from: noNotifyTasks)
    }
    private func delete(_ offsets: IndexSet, from list: [Reminder]) {
        for off in offsets {
            let del = list[off]
            if let idx = store.reminders.firstIndex(where: { $0.id == del.id }) {
                store.reminders.remove(at: idx)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ReminderStore())
}
