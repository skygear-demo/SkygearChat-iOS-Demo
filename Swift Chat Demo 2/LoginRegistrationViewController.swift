//
//  LoginRegistrationViewController.swift
//  Swift Chat Demo 2
//
//  Created by Zachary on 26/9/2017.
//  Copyright © 2017 Skygear. All rights reserved.
//

import UIKit
import SKYKit
import SVProgressHUD
import UserNotifications

let LoginRegistrationTableViewCellIdentifier: String = "UserDetail"
let MainScreenSegueIdentifier: String = "MainScreen"

public enum LoginRegistrationMode: String {
    case SignUp = "Sign Up"
    case Login = "Login"
}

class LoginRegistrationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!

    let formDetails: [String] = ["User Name", "Password"]
    var mode: LoginRegistrationMode = .Login

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.title = self.mode.rawValue
        self.doneButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func donePressed(_ sender: UIBarButtonItem) {

        let usernameCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? LoginRegistrationTableViewCell
        let passwordCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? LoginRegistrationTableViewCell

        let handler: SKYContainerUserOperationActionCompletion = { (record, error) in
            if let error = error {
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                SVProgressHUD.dismiss(withDelay: 3)
                return
            }
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: MainScreenSegueIdentifier, sender: self)
        }

        if let username = usernameCell?.detailTextField.text, let password = passwordCell?.detailTextField.text {
            SVProgressHUD.show()
            if self.mode == LoginRegistrationMode.SignUp {
                SKYContainer.default().auth.signup(withUsername: username, password: password, completionHandler: handler)
            } else if self.mode == LoginRegistrationMode.Login {
                SKYContainer.default().auth.login(withUsername: username, password: password, completionHandler: handler)
            }
        } else {
            SVProgressHUD.showError(withStatus: "Username and password cannot be empty.")
        }
    }
}

extension LoginRegistrationViewController: UITableViewDelegate {

}

extension LoginRegistrationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formDetails.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LoginRegistrationTableViewCellIdentifier) as! LoginRegistrationTableViewCell
        cell.titleLabel.text = formDetails[indexPath.row]
        cell.detailTextField.placeholder = formDetails[indexPath.row]
        cell.detailTextField.isSecureTextEntry = formDetails[indexPath.row].lowercased() == "password"
        cell.detailTextField.delegate = self
        return cell
    }
}

extension LoginRegistrationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text != "" {
            self.doneButton.isEnabled = true
        }
        return true
    }
}
