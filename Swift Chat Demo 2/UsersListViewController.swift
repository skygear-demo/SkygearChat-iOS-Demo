//
//  UsersListViewController.swift
//  Swift Chat Demo 2
//
//  Created by Zachary on 28/9/2017.
//  Copyright © 2017 Skygear. All rights reserved.
//

import UIKit
import SKYKit
import SKYKitChat
import SVProgressHUD

let UsersListTableViewCellIdentifier:String = "User"
let CreateGroupConversationViewControllerIdentifier:String = "group"

protocol UsersListViewControllerDelegate: class {
    func userlistViewController(didFinish conversation: SKYConversation)
}

class UsersListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var delegate: UsersListViewControllerDelegate?
    var users: [SKYRecord] = []
    var selectedUsers: [SKYRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.performUserQuery()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if let selectedRow = self.tableView.indexPathsForSelectedRows {
            if selectedRow.count > 1 {
                self.performSegue(withIdentifier: CreateGroupConversationViewControllerIdentifier, sender: self)
                return
            }else if selectedRow.count == 1{
                let selectedUser:SKYRecord = self.users[selectedRow[0].row]
                SVProgressHUD.show()
                SKYContainer.default().chatExtension?.createDirectConversation(userID: selectedUser.recordID.recordName, title: selectedUser["username"] as? String, metadata: nil, completion: { (conversation, error) in
                    SVProgressHUD.dismiss()
                    if let error = error as NSError?{
                        SVProgressHUD.showError(withStatus: "Error when create conversation.")
                        print(error)
                        return
                    }
                    self.delegate?.userlistViewController(didFinish: conversation!)
                    self.dismiss(animated: true)
                })
            }else {
                self.dismiss(animated: true)
            }
        }else {
            self.dismiss(animated: true)
        }
    }
    
    func performUserQuery() {
        let query = SKYQuery(recordType: "user", predicate: nil)
        let sortDescriptor = NSSortDescriptor(key: "username", ascending: true)
        query.sortDescriptors = [sortDescriptor]
        SKYQueryHelper.performQuery(query: query) { (results) in
            self.users = results
            ChatHelper.shared.cacheUserRecords(results)
            self.tableView.reloadData()
        }
    }
    
    func resetUsersRecord() {
        let cachedUsersRecord = ChatHelper.shared.fetchAllUsersRecord()
        self.users = cachedUsersRecord
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == CreateGroupConversationViewControllerIdentifier {
            let vc = segue.destination as! CreateGroupConversationViewController
            vc.selectedUsers = self.selectedUsers
            vc.delegate = self.delegate
        }
    }
}

extension UsersListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedUsers.append(self.users[indexPath.row])
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let index = self.selectedUsers.index(of: self.users[indexPath.row]) {
            self.selectedUsers.remove(at: index)
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
    }
}

extension UsersListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UsersListTableViewCellIdentifier) as! UsersListTableViewCell
        let user = self.users[indexPath.row]
        let username = user["username"] as? String
        if let username = username {
            cell.usernameLabel.text = username
            cell.userAvatarImageView.image = Utilities.avatarImage(withString: Utilities.getInitials(withString: username), color: Utilities.avatarColor(number: indexPath.row % 4), diameter: 28)
        }
        return cell
    }
}

extension UsersListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.resetUsersRecord()
            return
        } else {
            self.users = ChatHelper.shared.fetchAllUsersRecord().filter { (record) -> Bool in
                let username = record["username"] as? String
                if let username = username {
                    return username.lowercased().contains(searchText.lowercased())
                }else {
                    return false
                }
            }
            self.tableView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.resetUsersRecord()
    }
    
}
