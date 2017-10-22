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
let CreateGroupConversationViewControllerSegueIdentifier:String = "group"
let ChangeToGroupSelectionSegueIdentifier:String = "groupconversation"


protocol UsersListViewControllerDelegate: class {
    func userlistViewController(didFinish conversation: SKYConversation)
}

class UsersListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var delegate: UsersListViewControllerDelegate?
    var users: [SKYRecord] = []
    var selectedUsers: [SKYRecord] = []
    var groupSelection:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.performUserQuery()

        self.tableView.allowsMultipleSelection = groupSelection
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if let selectedRow = self.tableView.indexPathsForSelectedRows {
            if selectedRow.count > 1 {
                self.performSegue(withIdentifier: CreateGroupConversationViewControllerSegueIdentifier, sender: self)
                return
            }else if selectedRow.count == 1 && self.selectedUsers.count > 0{
                let selectedUser:SKYRecord = self.selectedUsers[0]
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
        let query = SKYQuery(recordType: "user", predicate: NSPredicate(format: "username != nil"))
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
        if segue.identifier == CreateGroupConversationViewControllerSegueIdentifier {
            let vc = segue.destination as! CreateGroupConversationViewController
            vc.selectedUsers = self.selectedUsers
            vc.delegate = self.delegate
        }else if segue.identifier == ChangeToGroupSelectionSegueIdentifier {
            let vc = segue.destination as! UsersListViewController
            vc.groupSelection = true
            vc.delegate = self.delegate
        }
    }
}

extension UsersListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if groupSelection == true {
            self.selectedUsers.append(self.users[indexPath.row])
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            if indexPath.row != 0 {
                self.selectedUsers = [self.users[indexPath.row - 1]]
                let section = indexPath.section
                let numberOfRows = tableView.numberOfRows(inSection: section)
                for row in 0..<numberOfRows {
                    if let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) {
                        cell.accessoryType = row == indexPath.row ? .checkmark : .none
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if groupSelection == true {
            if let index = self.selectedUsers.index(of: self.users[indexPath.row]) {
                self.selectedUsers.remove(at: index)
            }
        }else {
            self.selectedUsers = []
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none

    }
}

extension UsersListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groupSelection == true {
            return self.users.count
        }else {
            return self.users.count + 1
        }
    }
    
    func configureCell(cell: UsersListTableViewCell, indexPath: IndexPath) -> UsersListTableViewCell {
        var user:SKYRecord
        if groupSelection == true {
            user = self.users[indexPath.row]
        }else {
            user = self.users[indexPath.row - 1]
        }
        let username = user["username"] as? String
        if let username = username {
            cell.usernameLabel.text = username
            cell.userAvatarImageView.image = Utilities.avatarImage(withString: Utilities.getInitials(withString: username), color: Utilities.avatarColor(number: indexPath.row % 4), diameter: 28)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if groupSelection == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: UsersListTableViewCellIdentifier) as! UsersListTableViewCell
            return configureCell(cell: cell, indexPath: indexPath)
        } else {
            if indexPath.row == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "groupconversation")!
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: UsersListTableViewCellIdentifier) as! UsersListTableViewCell
                return configureCell(cell: cell, indexPath: indexPath)
            }
        }
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
