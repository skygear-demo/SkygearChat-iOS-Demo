//
//  StartupViewController
//  Swift Chat Demo 2
//
//  Created by Zachary on 26/9/2017.
//  Copyright © 2017 Skygear. All rights reserved.
//

import UIKit

let LoginSegueIdentifier: String = "Login"
let SignupSegueIdentifier: String = "Signup"

class StartupViewController: UIViewController {

    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.signupButton.layer.cornerRadius = 12
        self.loginButton.layer.cornerRadius = 12
        self.loginButton.layer.borderWidth = 1
        self.loginButton.layer.borderColor = UIColor(red: 0/255, green: 118/255, blue: 255/255, alpha: 1.0).cgColor
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! LoginRegistrationViewController
        if segue.identifier == LoginSegueIdentifier {
            vc.mode = LoginRegistrationMode.Login
        } else if segue.identifier == SignupSegueIdentifier {
            vc.mode = LoginRegistrationMode.SignUp
        } else {
            return
        }
    }
}
