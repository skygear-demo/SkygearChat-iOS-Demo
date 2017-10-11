//
//  CreateGroupConversationViewController.swift
//  Swift Chat Demo 2
//
//  Created by Zachary on 1/10/2017.
//  Copyright © 2017 Skygear. All rights reserved.
//

import UIKit
import SKYKit
import SKYKitChat
import JSQMessagesViewController
import SVProgressHUD

class CreateGroupConversationViewController: UIViewController {

    @IBOutlet weak var conversationNameTextField: UITextField!
    @IBOutlet weak var groupIconImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedUsers:[SKYRecord] = []
    var delegate:UsersListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewDidLayoutSubviews() {
        self.groupIconImageView.layer.cornerRadius = self.groupIconImageView.frame.size.height / 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        if conversationNameTextField.text?.characters.count == 0 {
            SVProgressHUD.showError(withStatus: "Please enter a conversation name.")
            SVProgressHUD.dismiss(withDelay: 1)
        }else {
            var participantsIDs:[String] = []
            for user in selectedUsers {
                participantsIDs.append(user.recordID.recordName)
            }
            SKYContainer.default().chatExtension?.createConversation(participantIDs: participantsIDs, title: self.conversationNameTextField.text, metadata: nil, completion: { (conversation, error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: "Error when create conversation")
                    SVProgressHUD.dismiss(withDelay: 1)
                    print(error)
                    return
                }
                self.delegate?.userlistViewController(didFinish: conversation!)
                self.dismiss(animated: true)
            })
        }
    }
}

extension CreateGroupConversationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.selectedUsers.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
}

extension CreateGroupConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "User") as! UsersListTableViewCell
        if let username = self.selectedUsers[indexPath.row]["username"] as? String {
            cell.userAvatarImageView.image = Utilities.avatarImage(withString: Utilities.getInitials(withString: username), color: Utilities.avatarColor(number: indexPath.row % 4), diameter: 28)
            cell.usernameLabel.text = username
        }else {
            cell.usernameLabel.text = "Unknown username"
        }
        return cell
    }
}
