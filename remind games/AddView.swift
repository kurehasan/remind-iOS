//
//  AddView.swift
//  remind games
//
//  Created by 浅沼紅葉 on 2025/04/30.
//

import SwiftUI
import UserNotifications

struct AddView: View {
    @EnvironmentObject var store: ReminderStore
    @Binding var selection: Int
    
    @State var title: String = ""
    @State var date: Date = Date()         // ← 今日の日付／時刻が初期値
    @State var noNotif = false

    // 今年の1/1 ～ 12/31 を動的に作る
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let startComp = DateComponents(year: year, month: 1, day: 1)
        let endComp   = DateComponents(year: year, month: 12, day: 31,
                                       hour: 23, minute: 59, second: 59)
        let start = calendar.date(from: startComp)!
        let end   = calendar.date(from: endComp)!
        return start...end
    }()

    var body: some View {
        
        VStack {
            Text("予定を追加する")
                .font(.system(size: 30, weight: .bold))

            Spacer().frame(height: 50)

            TextField("タイトルを入力してください", text: $title)
                .padding(.horizontal, 30)
                .textFieldStyle(.roundedBorder)

            DatePicker(
                "通知時間",
                selection: $date,
                in: dateRange,                  // ← 今年の範囲
                displayedComponents: [.date, .hourAndMinute]
            )
            .padding(.horizontal, 30)
            .padding(.vertical)
            .disabled(noNotif)
            .opacity(noNotif ? 0.6 : 1)

            Toggle("通知をしない", isOn: $noNotif)
                .padding(.horizontal, 30)

            Button {
                let newItem = Reminder(
                    title: title,
                    date: date,
                    isNoNotification: noNotif
                )
                store.reminders.append(newItem)

                // 通知する設定ならスケジュール
                if !noNotif {
                    scheduleNotification(for: newItem)
                }

                // 入力リセット
                title = ""
                date = Date()
                noNotif = false

                // タブを戻す
                selection = 0

            } label: {
                Image(systemName: "plus.circle.dashed")
                    .font(.system(size: 100, weight: .light))
            }
            
        }
    }
    
    func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = "リマインダーの時間です！"
        content.sound = .default

        // 通知日時をセット
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知エラー: \(error.localizedDescription)")
            } else {
                print("通知をスケジュールしました: \(components)")
            }
        }
    }

}

#Preview {
    AddView(selection: .constant(1))
        .environmentObject(
                    ReminderStore()
        )
}
