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
        super.viewWillAppear(animated)
        self.fetchConversations(successBlock: {
            print("Fetched Conversations")
        }) { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
        subscribeUserChannel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeUserChannel()
        super.viewWillDisappear(animated)
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
    
    func fetchConversation(conversation: SKYConversation, successBlock: @escaping (()->Void), failureBlock: @escaping ((Error)->Void)) {
        SKYContainer.default().chatExtension?.fetchConversation(conversationID: conversation.recordID().recordName, fetchLastMessage: true, completion: { (conversation, error) in
            if let conversation = conversation {
                self.updateConversation(conversation: conversation)
            }
        })
    }
    
    func updateConversation(conversation: SKYConversation) {
        let updatedConversationIndex = self.conversations?.index(where: { (item) -> Bool in
            item.recordName() == conversation.recordName()
        })
        if var conversations = self.conversations, let updatedConversationIndex = updatedConversationIndex {
            self.conversations?.remove(at: updatedConversationIndex)
            self.conversations?.insert(conversation, at: 0)
            self.conversationlistTableView.reloadData()
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
    
    func subscribeUserChannel() {
        
        self.unsubscribeUserChannel()
        SKYContainer.default().chatExtension?.subscribeToUserChannelWithCompletion(completion: nil)
        
        NotificationCenter.default.addObserver(forName: Notification.Name("SKYChatDidReceiveRecordChangeNotification"), object: nil, queue: OperationQueue.main) { (notification) in
            if let r = notification.userInfo?["recordChange"] {
                let recordChange = r as! SKYChatRecordChange
                if recordChange.event == .create {
//                    Will Change to this method (update certain conversation only) when fetchConversation last message bug is fixed
//                    let record = recordChange.record
//                    if record.recordType == "message" {
//                        let conversationRef = record["conversation"] as! SKYReference
//                        let conversationRecord = SKYRecord(recordType: "conversation", name: conversationRef.recordID.recordName)
//                        let conversation = SKYConversation(recordData: conversationRecord)
//                        self.fetchConversation(conversation: conversation, successBlock: {
//
//                        }, failureBlock: { (error) in
//
//                        })
//                    }

                }
            }
            self.fetchConversations(successBlock: {
                print("Fetched Conversations")
            }) { (error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }
        }
    }
    
    func unsubscribeUserChannel() {
        SKYContainer.default().chatExtension?.unsubscribeFromUserChannel()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("SKYChatDidReceiveRecordChangeNotification"), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == UserListSegueIdentifier {
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
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedConversation = self.conversations?[indexPath.row]

        let vc = CustomSKYChatConversationViewController()
        vc.conversation = self.selectedConversation
        self.navigationController?.pushViewController(vc, animated: true)
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
                
                let targetUser = ChatHelper.shared.userRecord(userID: conversationTarget)
                if let targetUser = targetUser {
                    conversationCell.conversationNameLabel.text = targetUser["username"] as? String
                }else {
                    ChatHelper.shared.fetchUserRecords(userIDs: [conversationTarget], completion: { (results, error) in
                        if let error = error {
                            Utilities.handleQueryError(error: error as NSError)
                            return
                        }
                        if let results = results {
                            if results.count > 0 {
                                let fetchedUser:SKYRecord = results[0]
                                conversationCell.conversationNameLabel.text = fetchedUser["username"] as? String
                            }
                        }
                    })
                }
            }else {
                conversationCell.conversationNameLabel.text = conversationTitle
            }
            
            if conversation.unreadCount > 0 {
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
        let vc = CustomSKYChatConversationViewController()
        vc.conversation = self.selectedConversation
        self.navigationController?.pushViewController(vc, animated: true)
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
