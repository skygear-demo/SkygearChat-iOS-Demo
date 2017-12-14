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
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
