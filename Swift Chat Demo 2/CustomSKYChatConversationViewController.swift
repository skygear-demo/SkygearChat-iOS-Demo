//
//  ViewController.swift
//  Swift Chat Demo 2
//
//  Created by Zachary on 25/9/2017.
//  Copyright © 2017 Skygear. All rights reserved.
//

import SKYKitChat
import SVProgressHUD

class CustomSKYChatConversationViewController: SKYChatConversationViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handle(appBecomeActiveNotification:)),
            name: .UIApplicationDidBecomeActive,
            object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .UIApplicationWillEnterForeground,
            object: nil
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        LaunchingConversationID = nil
    }

    @objc func handle(appBecomeActiveNotification notification: NSNotification) {
        LaunchingConversationID = nil
    }
}

// MARK: - SKYChatConversationViewControllerDelegate

extension CustomSKYChatConversationViewController: SKYChatConversationViewControllerDelegate {
    func conversationViewController(_ controller: SKYChatConversationViewController,
                                    didFetchedParticipants participants: [SKYRecord]) {

        ChatHelper.shared.cacheUserRecords(participants)
    }

    func conversationViewController(_ controller: SKYChatConversationViewController, didFetchedMessages messages: [SKYMessage], isCached: Bool) {
        SVProgressHUD.dismiss()
    }

    func startFetchingMessages(_ controller: SKYChatConversationViewController) {
        if controller.messageList.count == 0 {
            SVProgressHUD.show()
        }
    }

}
