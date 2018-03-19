//
//  SettingViewController.swift
//  Swift Chat Demo 2
//
//  Created by Zachary on 30/10/2017.
//  Copyright © 2017 Skygear. All rights reserved.
//

import UIKit
import SKYKit
import SVProgressHUD

class SettingViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension SettingViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userinfo") as! SettingUserInfoTableViewCell
            if let username = SKYContainer.default().auth.currentUser?["username"] {
                let initials = Utilities.getInitials(withString: username as! String)
                cell.userImageView.image = Utilities.avatarImage(withString: initials, color: Utilities.avatarColor(number: 0), diameter: 63)
                cell.usernameTextField.text = username as? String
            } else {
                cell.userImageView.image = Utilities.avatarImage(withString: "Skygear", color: Utilities.avatarColor(number: 0), diameter: 63)
            }
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "button")
                cell?.textLabel?.text = "Logout"
                return cell!
            } else {
                return UITableViewCell()
            }
        }
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            SVProgressHUD.show()
            SKYContainer.default().auth.logout(completionHandler: { (record, error) in
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "startup", sender: self)
            })
        }
    }
}
