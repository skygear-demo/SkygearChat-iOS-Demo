//
//  RootTabBarController.swift
//  Swift Chat Demo 2
//
//  Created by Ben Lei on 28/3/2018.
//  Copyright © 2018 Skygear. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController {
    enum RootTabBarTab {
        case ConversationTab
        case SettingsTab
        case Unknown(Int)
    }

    var currentTab: RootTabBarTab {
        get {
            switch self.selectedIndex {
            case 0: return .ConversationTab
            case 1: return .SettingsTab
            default: return .Unknown(self.selectedIndex)
            }
        }
        set {
            switch newValue {
            case .ConversationTab: self.selectedIndex = 0
            case .SettingsTab: self.selectedIndex = 1
            case let .Unknown(idx):
                print("Warning: setting to unknown tab \(idx)")
                self.selectedIndex = idx
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .UIApplicationWillEnterForeground,
            object: nil
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handle(appBecomeActiveNotification:)),
            name: .UIApplicationDidBecomeActive,
            object: nil)
    }

    @objc func handle(appBecomeActiveNotification notification:NSNotification) {
        if LaunchingConversationID != nil {
            self.currentTab = .ConversationTab
        }
    }
}
