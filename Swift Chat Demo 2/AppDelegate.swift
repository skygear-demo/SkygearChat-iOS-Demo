//
//  AppDelegate.swift
//  Swift Chat Demo 2
//
//  Created by Zachary on 25/9/2017.
//  Copyright © 2017 Skygear. All rights reserved.
//

import UIKit
import SKYKit
import UserNotifications

var LaunchingConversationID: String?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var skygear: SKYContainer {
        return SKYContainer.default()
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        let skygear = self.skygear
        skygear.configAddress("https://chatdemoapp.skygeario.com/")
        skygear.configure(withAPIKey: "c0d796f60a9649d78ade26e65c460459")
        skygear.auth.getWhoAmI { (user, _) in
            guard user != nil else {
                return
            }

            application.registerForRemoteNotifications()
        }

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print ("Registered for Push notifications with token: \(deviceToken.base64EncodedString())")
        self.skygear.push.registerDevice(withDeviceToken: deviceToken, completionHandler: { (deviceID, error) in
            if let err = error {
                print ("Failed to register device token: \(err.localizedDescription)")
                return
            }
        })
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier != UNNotificationDismissActionIdentifier {
            let userInfo = response.notification.request.content.userInfo
            if let apsInfo = userInfo["aps"] as? [String: Any],
                let conversationID = apsInfo["conversation_id"] as? String {
                print("Lucnhing to Conversation ID: \(conversationID)")
                LaunchingConversationID = conversationID
            }
        }
        completionHandler()
    }
}
