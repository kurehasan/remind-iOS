//
//  MainTab.swift
//  remind games
//
//  Created by 浅沼紅葉 on 2025/04/30.
//

import SwiftUI
import CoreData

struct MainTab: View {
    @State private var tabSelection: Int = 0
    @State private var calenderSelectedDate: Date = Date()

    var body: some View {
        TabView(selection: $tabSelection) {
            ContentView()
                .tag(0)
                .tabItem {
                    Label("Home",systemImage: "house")
                }

            AddView(isPresented: .constant(true), selection: $tabSelection, calendarDate: $calenderSelectedDate)
                .tag(1)
                .tabItem {
                    Label("", systemImage: "plus.app.fill")
                        .font(.system(size: 200, weight: .medium))
                }

            CalendarView(selectedDate: $calenderSelectedDate)
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
            .environment(\.managedObjectContext,PersistenceController().container.viewContext)
    }
}

