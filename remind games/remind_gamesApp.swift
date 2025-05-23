//
//  remind_gamesApp.swift
//  remind games
//
//  Created by 浅沼紅葉 on 2025/04/28.
//

import SwiftUI

@main
struct remind_gamesApp: App {
    let persistenceController = PersistenceController()
    init(){
        
    }
    var body: some Scene {
        WindowGroup {
            MainTab()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
