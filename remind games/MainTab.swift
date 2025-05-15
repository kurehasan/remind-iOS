//
//  MainTab.swift
//  remind games
//
//  Created by 浅沼紅葉 on 2025/04/30.
//

import SwiftUI

struct MainTab: View {
    @StateObject private var store = ReminderStore()
    @State private var selection: Int = 0

    var body: some View {
        TabView(selection: $selection) {
            ContentView()
                .environmentObject(store)
                .tag(0)
                .tabItem {
                    Label("Home",systemImage: "house")
                }

            AddView(selection: $selection)
                .environmentObject(store)
                .tag(1)
                .tabItem {
                    Label("", systemImage: "plus.app.fill")
                        .font(.system(size: 200, weight: .medium))
                }

            CalendarView()
                .environmentObject(store)
                .tag(2)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
        }
    }
}

struct MainTab_Previews: PreviewProvider {
    static var previews: some View {
        MainTab()
    }
}

