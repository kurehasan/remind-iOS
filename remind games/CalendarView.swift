//
//  CalendarView.swift
//  remind games
//
//  Created by 浅沼紅葉 on 2025/04/30.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var store: ReminderStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                calendarPicker    // カレンダー部分
                taskList          // タスク一覧部分
            }
            .navigationTitle("カレンダー")
        }
    }

    // MARK: — カレンダー（グラフィカル DatePicker）
    private var calendarPicker: some View {
        DatePicker(
            "日付を選択",
            selection: $store.selectDate,
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .padding()
    }

    // MARK: — 選択日のタスク一覧
    private var taskList: some View {
        List {
            Section(header: headerView) {
                ForEach(store.reminders(on: store.selectDate)
                    .filter { !$0.isNoNotification }, id: \.id) { item in
                    ReminderRow(item: item)
                        .environmentObject(store)
                }
                .onDelete(perform: deleteTasks)
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: — セクションヘッダー
    private var headerView: some View {
        Text("選択日：\(store.selectDate, style: .date)")
            .font(.headline)
            .padding(.vertical, 4)
    }

    // MARK: — 削除処理
    private func deleteTasks(at offsets: IndexSet) {
        let todays = store.reminders(on: store.selectDate)
        for off in offsets {
            let toDelete = todays[off]
            if let idx = store.reminders.firstIndex(where: { $0.id == toDelete.id }) {
                store.reminders.remove(at: idx)
            }
        }
    }
}

// MARK: — タスク行のサブビュー
struct ReminderRow: View {
    @EnvironmentObject private var store: ReminderStore
    let item: Reminder

    var body: some View {
        HStack {
            Button {
                if let idx = store.reminders.firstIndex(where: { $0.id == item.id }) {
                    store.reminders[idx].isChecked.toggle()
                }
            } label: {
                Image(systemName: item.isChecked ? "checkmark.square" : "square")
            }
            .buttonStyle(.plain)

            Text(item.title)
                .lineLimit(1)

            Spacer()

            if item.isNoNotification {
                Text("―")
                    .foregroundColor(.gray)
            } else {
                Text(item.date, style: .time)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    CalendarView()
        .environmentObject(
            ReminderStore()
        )
}
