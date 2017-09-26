//
//  ConversationListViewController.swift
//  Swift Chat Demo 2
//
//  Created by Zachary on 26/9/2017.
//  Copyright © 2017 Skygear. All rights reserved.
//

import UIKit
import SKYKit
import SKYKitChat
import JSQMessagesViewController
import SVProgressHUD
import AFDateHelper

let ConversationCellIdentifier:String = "Conversation"
let ConversationViewSegueIdentifier:String = "ConversationView"

class ConversationListViewController: UIViewController {

    @IBOutlet weak var conversationlistTableView: UITableView!
    @IBOutlet weak var conversationSearchBar: UISearchBar!
    
    var conversations:[SKYConversation]? = nil
    var cachedConversations:[SKYConversation]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        self.fetchConversations(successBlock: {
            print("Fetched Conversations")
        }) { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
        // For removing extra cells in the bottom of the tableView
        self.conversationlistTableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchConversations(successBlock: @escaping (()->Void), failureBlock: @escaping ((Error)->Void)) {
        SKYContainer.default().chatExtension?.fetchConversations(completion: { (conversations, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                failureBlock(error)
            }
            self.conversations = conversations
            self.cachedConversations = conversations
            self.conversationlistTableView.reloadData()
            successBlock()
        })
    }
    
    func resetConversationList() {
        self.conversations = self.cachedConversations
        self.conversationlistTableView.reloadData()
    }
    
    func conversationLastUpdateDateString(conversation: SKYConversation) -> String {
        let dateFormatter = DateFormatter()
        if let modificationDate = conversation.lastMessage?.creationDate() {
            let dateBetweenModificationDateNow = Date().since(modificationDate, in: .day)
            if dateBetweenModificationDateNow >= 7 {
                dateFormatter.dateFormat = "dd/MM/yyyy"
            }else if dateBetweenModificationDateNow < 7 && dateBetweenModificationDateNow >= 1 {
                dateFormatter.dateFormat = "EEEE"
            }else if dateBetweenModificationDateNow < 1 {
                dateFormatter.dateFormat = "HH:mm"
            }
            return dateFormatter.string(from: modificationDate)
        }else {
            return ""
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ConversationViewSegueIdentifier {
            let vc = segue.destination as! ViewController
            vc.conversation = self.conversations![self.conversationlistTableView.indexPathForSelectedRow!.row]
        }
    }
}

extension ConversationListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: ConversationViewSegueIdentifier, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let selectedConversation = self.conversations?[indexPath.row] {
                SVProgressHUD.show()
                SKYContainer.default().chatExtension?.deleteConversation(selectedConversation, completion: { (result, error) in
                    SVProgressHUD.dismiss()
                    if let error = error {
                        SVProgressHUD.showError(withStatus: error.localizedDescription)
                        return
                    }
                    self.fetchConversations(successBlock: {
                        SVProgressHUD.showSuccess(withStatus: "Conversation Deleted ☑️")
                        SVProgressHUD.dismiss(withDelay: 1)
                    }, failureBlock: { (error) in
                        SVProgressHUD.showError(withStatus: error.localizedDescription)
                    })
                })
            }
        }
    }
}

extension ConversationListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let conversations = conversations {
            return conversations.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conversationCell = tableView.dequeueReusableCell(withIdentifier: ConversationCellIdentifier) as! ConversationListTableViewCell
        if let conversations = conversations {
            let conversation = conversations[indexPath.row]
            
            let conversationTitle = conversation.title ?? ""
            let conversationInitials = conversationTitle.components(separatedBy: " ").reduce("") {
                ($0 == "" ? "" : "\($0.characters.first!)") + "\($1.characters.first!)"
            }
            let conversationLastMessage = conversation.lastMessage?.body
            let avatarColor = [UIColor.jsq_messageBubbleRed(), UIColor.jsq_messageBubbleBlue(), UIColor.jsq_messageBubbleGreen(), UIColor.jsq_messageBubbleLightGray()]
            let avatar = JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: conversationInitials, backgroundColor: avatarColor[indexPath.row % 4], textColor: UIColor.white, font: UIFont.systemFont(ofSize: 14), diameter: 50)
            
            conversationCell.avatarImageView.image = avatar?.avatarImage
            conversationCell.conversationNameLabel.text = conversationTitle
            conversationCell.messageLabel.text = conversationLastMessage ?? ""
            conversationCell.lastMessageTimeLabel.text = conversationLastUpdateDateString(conversation: conversation)
            if conversation.unreadCount < 0 {
                conversationCell.unreadCountLabel.text = "\(conversation.unreadCount)"
                conversationCell.unreadCountLabel.isHidden = false
            }else {
                conversationCell.unreadCountLabel.isHidden = true
            }
        }
        
        return conversationCell
    }
}

extension ConversationListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            resetConversationList()
            return
        }
        self.conversations = self.cachedConversations?.filter({ (conversation) -> Bool in
            if let title = conversation.title {
                return title.lowercased().contains(searchText.lowercased())
            }else {
                return false
            }
        })
        self.conversationlistTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        resetConversationList()
    }
}
