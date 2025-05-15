//
//  LocalNotificationManager.swift
//  remind games
//
//  Created by 浅沼紅葉 on 2025/05/14.
//

import SwiftUI
import UserNotifications

struct LocalNotificationManagerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene{
        WindowGroup {
            MainTab()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        // 通知の許可をリクエスト
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("通知許可リクエストでエラー: \(error)")
            } else {
                print("通知の許可: \(granted)")
            }
        }
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler:
                                       @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.banner, .sound])
        }
}
