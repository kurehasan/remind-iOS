//
//  AddView.swift
//  remind games
//
//  Created by 浅沼紅葉 on 2025/04/30.
//

import SwiftUI
import CoreData
import UserNotifications

struct AddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    @Binding var selection: Int
    @Binding var calendarDate: Date
    
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var isNoNotification: Bool = false
    
    // 今年の1月1日～12月31日までを動的に範囲指定
    private let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let end = calendar.date(from: DateComponents(year: year, month: 12, day: 31,
                                                     hour: 23, minute: 59, second: 59))!
        return start...end
    }()
    
    var body: some View {
        VStack {
            Text("新規タスク")
                .font(.system(size: 30, weight: .bold))
            
            Spacer().frame(height: 50)
            
            TextField("タイトルを入力", text: $title)
                .padding(.horizontal, 30)
                .textFieldStyle(.roundedBorder)
            
            DatePicker(
                "日時を選択",
                selection: $date,
                in: dateRange,
                displayedComponents: [.date, .hourAndMinute]
            )
            .padding(.horizontal, 30)
            .padding(.vertical)
            .disabled(isNoNotification)
            .opacity(isNoNotification ? 0.6 : 1)
            
            Toggle("通知しない", isOn: $isNoNotification)
                .padding(.horizontal, 30)
            
            Spacer().frame(height: 50)
            
            Button {
                let addedDate = date
                
                addReminder()
                calendarDate = addedDate
                selection = 2
                isPresented = false
            } label: {
                Image(systemName: "plus.circle.dashed")
                    .font(.system(size: 100, weight: .light))
                    .foregroundColor(.accentColor)
            }
            .disabled(title.isEmpty)
            
            Spacer()
        }
    }
    
    /// 新しいリマインダーをCoreDataに保存し、通知をスケジュール
    private func addReminder() {
        let newItem = ReminderEntity(context: viewContext)
        newItem.id = UUID()
        newItem.title = title
        newItem.date = date
        newItem.isChecked = false
        newItem.isNoNotification = isNoNotification
        saveContext()
        
        if !isNoNotification {
            scheduleNotification(id: newItem.id!, title: title, date: date)
        }
        
        resetFields()
    }
    
    /// フィールドを初期状態にリセット
    private func resetFields() {
        title = ""
        date = Date()
        isNoNotification = false
    }
    
    /// CoreData の保存処理
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Save failed: \(error)")
            viewContext.rollback()
        }
    }
    
    /// UNUserNotificationCenter に通知リクエストを追加
    private func scheduleNotification(id: UUID, title: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "リマインダーの時間です！"
        content.sound = .default
        
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: id.uuidString,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error.localizedDescription)")
            } else {
                print("通知をスケジュールしました: \(comps)")
            }
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        return AddView(isPresented: .constant(true),
                       selection: .constant(1),
                       calendarDate: .constant(Date()))
            .environment(\.managedObjectContext, context)
    }
}
