// ContentView.swift

import SwiftUI
import CoreData

struct ContentView: View {
    // Core Data のコンテキストを取得
    @Environment(\.managedObjectContext) private var viewContext

    // 全タスクを日付順でフェッチ
    @FetchRequest(
        entity: ReminderEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ReminderEntity.date, ascending: true)
        ]
    ) private var reminders: FetchedResults<ReminderEntity>

    // 今日のタスク（通知あり）
    private var todayTasks: [ReminderEntity] {
        reminders.filter {
            guard let d = $0.date else { return false }
            return Calendar.current.isDateInToday(d) && !$0.isNoNotification
        }
    }

    // 通知なしタスク
    private var noNotifyTasks: [ReminderEntity] {
        reminders.filter { $0.isNoNotification }
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // ── 上半分：今日のタスク ──
                List {
                    Section(header:
                        Text("今日のタスク")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    ) {
                        if todayTasks.isEmpty {
                            Text("タスクはありません")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                                .listRowSeparator(.hidden)
                        } else {
                            ForEach(todayTasks, id: \.objectID) { item in
                                rowView(for: item)
                            }
                            .onDelete(perform: deleteToday)
                        }
                    }
                }
                .listStyle(.plain)
                .frame(height: geo.size.height * 0.5)

                Divider()

                // ── 下半分：通知をしないタスク ──
                List {
                    Section(header:
                        Text("通知をしないタスク")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    ) {
                        if noNotifyTasks.isEmpty {
                            Text("該当タスクはありません")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                                .listRowSeparator(.hidden)
                        } else {
                            ForEach(noNotifyTasks, id: \.objectID) { item in
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

    // MARK: — 共通の行ビュー
    @ViewBuilder
    private func rowView(for item: ReminderEntity) -> some View {
        HStack {
            Image(systemName: item.isChecked ? "checkmark.square" : "square")
                .onTapGesture { toggleChecked(item) }
            Text(item.title ?? "")
                .lineLimit(1)
            Spacer()
            if item.isNoNotification {
                Text("―").foregroundColor(.gray)
            } else if let d = item.date {
                Text(d, style: .time)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: — 操作メソッド
    private func toggleChecked(_ item: ReminderEntity) {
        item.isChecked.toggle()
        saveContext()
    }

    private func deleteToday(at offsets: IndexSet) {
        offsets.map { todayTasks[$0] }.forEach(viewContext.delete)
        saveContext()
    }

    private func deleteNoNotify(at offsets: IndexSet) {
        offsets.map { noNotifyTasks[$0] }.forEach(viewContext.delete)
        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Save error:", error)
            viewContext.rollback()
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController().container.viewContext)
}
