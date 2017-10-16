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
import DZNEmptyDataSet


let ConversationCellIdentifier:String = "Conversation"
let ConversationViewSegueIdentifier:String = "ConversationView"
let UserListSegueIdentifier:String = "NewMessage"

class ConversationListViewController: UIViewController {

    @IBOutlet weak var conversationlistTableView: UITableView!
    @IBOutlet weak var conversationSearchBar: UISearchBar!
    
    var refreshControl:UIRefreshControl!
    var selectedConversation:SKYConversation? = nil
    var conversations:[SKYConversation]? = nil
    var cachedConversations:[SKYConversation]? = nil
    var conversationChangeObserver: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.isHidden = false
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        self.conversationlistTableView.addSubview(refreshControl);
        self.refreshControl.beginRefreshing()
        self.handleRefresh(refreshControl: self.refreshControl)
        
        self.conversationlistTableView.emptyDataSetDelegate = self
        self.conversationlistTableView.emptyDataSetSource = self
        
        // For removing extra cells in the bottom of the tableView
        self.conversationlistTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchConversations(successBlock: {
            print("Fetched Conversations")
        }) { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        subscribeConversationChanges()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        unsubscribeConversationChanges()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        SVProgressHUD.show()
        self.fetchConversations(successBlock: {
            print("Fetched Conversations")
            refreshControl.endRefreshing()
        }) { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
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
    
    func subscribeConversationChanges() {
        
        self.unsubscribeConversationChanges()
        
        let handler: ((SKYChatRecordChangeEvent, SKYConversation) -> Void) = {(event, msg) in
            switch event {
            case .create:
                NSLog("Conversation create")
            case .update:
                NSLog("Conversation update")
            case .delete:
                NSLog("Conversation delete")
            }
            self.fetchConversations(successBlock: {
                print("Fetched Conversations")
                print("Conversation: \(msg.title)")
            }) { (error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
        self.conversationChangeObserver = SKYContainer.default().chatExtension?
            .subscribeToConversation(handler: handler)
        
    }
    
    func unsubscribeConversationChanges() {
        if let observer = self.conversationChangeObserver {
            SKYContainer.default().chatExtension?.unsubscribeToConversation(withObserver: observer)
            self.conversationChangeObserver = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ConversationViewSegueIdentifier {
            let vc = segue.destination as! ViewController
            vc.conversation = self.selectedConversation
        }else if segue.identifier == UserListSegueIdentifier {
            let destinationNavigationController = segue.destination as! UINavigationController
            let vc = destinationNavigationController.topViewController as! UsersListViewController
            vc.delegate = self
        }
    }
}

extension ConversationListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedConversation = self.conversations?[indexPath.row]
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
            let conversationInitials = Utilities.getInitials(withString: conversationTitle)
            let conversationLastMessage = conversation.lastMessage?.body
            let avatar = Utilities.avatarImage(withString: conversationInitials, color: Utilities.avatarColor(number: indexPath.row % 4), diameter: 50)
            
            conversationCell.avatarImageView.image = avatar
            conversationCell.messageLabel.text = conversationLastMessage ?? ""
            conversationCell.lastMessageTimeLabel.text = conversationLastUpdateDateString(conversation: conversation)
            
            if conversation.participantIds.count == 2 {
                var conversationTarget:String = ""
                if conversation.participantIds[0] == SKYContainer.default().auth.currentUser?.recordID.recordName {
                    conversationTarget = conversation.participantIds[1]
                }else {
                    conversationTarget = conversation.participantIds[0]
                }
                let userQuery = SKYQuery(recordType: "user", predicate: NSPredicate(format: "_id == %@", conversationTarget))
                SKYContainer.default().publicCloudDatabase.perform(userQuery, completionHandler: { (results, error) in
                    if let error = error {
                        Utilities.handleQueryError(error: error as NSError)
                        return
                    }
                    if let results = results {
                        if results.count > 0 {
                            let fetchedUser:SKYRecord = results[0] as! SKYRecord
                            conversationCell.conversationNameLabel.text = fetchedUser["username"] as? String
                        }
                    }
                })
            }else {
                conversationCell.conversationNameLabel.text = conversationTitle
            }
            
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

extension ConversationListViewController: UsersListViewControllerDelegate {
    func userlistViewController(didFinish conversation: SKYConversation) {
        self.selectedConversation = conversation
        self.performSegue(withIdentifier: ConversationViewSegueIdentifier, sender: self)
    }
}

extension ConversationListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "icon-conversation")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let title = NSAttributedString(string: "No Conversations")
        return title
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let font = UIFont.systemFont(ofSize: 12)
        let attrsDictionary = [NSFontAttributeName:font]
        let description = NSAttributedString(string: "You don't have any conversations at this moment. Create one now! Click the button on the upper right hand corner.", attributes: attrsDictionary)
        return description
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        if let navigationBar = navigationController?.navigationBar {
            return -navigationBar.frame.height * 0.75
        }
        return 0
    }
}
