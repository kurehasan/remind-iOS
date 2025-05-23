//
//  CalendarView.swift
//  remind games
//
//  Created by 浅沼紅葉 on 2025/04/30.
//

// CalendarView.swift

import SwiftUI
import CoreData

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // 全タスクをソート付きでフェッチ
    @FetchRequest(
        entity: ReminderEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ReminderEntity.date, ascending: true)]
    ) private var reminders: FetchedResults<ReminderEntity>

    @Binding var selectedDate: Date

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker(
                    "日付を選択",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()

                List {
                    Section(header: Text("選択日：\(selectedDate, style: .date)")
                                .font(.headline)
                                .padding(.vertical, 4)
                    ) {
                        ForEach(tasksForSelectedDate, id: \.objectID) { item in
                            ReminderRow(entity: item)
                        }
                        .onDelete(perform: deleteTasks)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("カレンダー")
        }
    }

    private var tasksForSelectedDate: [ReminderEntity] {
        reminders.filter { entity in
            guard let d = entity.date else { return false }
            return Calendar.current.isDate(d, inSameDayAs: selectedDate)
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        let toDelete = offsets.map { tasksForSelectedDate[$0] }
        toDelete.forEach(viewContext.delete)
        saveContext()
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Save error: \(error)")
            viewContext.rollback()
        }
    }
}

struct ReminderRow: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var entity: ReminderEntity  // 変更：Observabilityを追加

    var body: some View {
        HStack {
            Button {
                entity.isChecked.toggle()
                do {
                    try viewContext.save()
                } catch {
                    viewContext.rollback()
                }
            } label: {
                Image(systemName: entity.isChecked ? "checkmark.square.fill" : "square")
            }
            .buttonStyle(.plain)

            Text(entity.title ?? "")
                .lineLimit(1)

            Spacer()

            if entity.isNoNotification {
                Text("―").foregroundColor(.gray)
            } else if let d = entity.date {
                Text(d, style: .time)
            }
        }
        .padding(.vertical, 6)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        CalendarView(selectedDate: .constant(Date()))
            .environment(\.managedObjectContext, context)
    }
}
