//
//  ReminderStore.swift
//  remind games
//
//  Created by 浅沼紅葉 on 2025/05/10.
//

import Combine
import Foundation

class ReminderStore: ObservableObject {
    @Published var reminders: [Reminder] = []
    @Published var selectDate: Date = Date()

    func reminders(on date: Date) -> [Reminder] {
        reminders.filter{
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
}

