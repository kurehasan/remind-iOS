//
//  Reminder.swift
//  remind games
//
//  Created by 浅沼紅葉 on 2025/05/10.
//

import Foundation

struct Reminder: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let isNoNotification: Bool
    var isChecked: Bool = false
}
