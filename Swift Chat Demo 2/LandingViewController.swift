//
//  LandingViewController.swift
//  Swift Chat Demo 2
//
//  Created by Zachary on 26/9/2017.
//  Copyright © 2017 Skygear. All rights reserved.
//

import UIKit
import SKYKit

let RegisterSegueIdentifier: String = "Register"
let LoggedInSegueIdentifier: String = "MainScreen"

class LandingViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 1, delay: 0, options: [.curveEaseInOut], animations: {
            self.logoImageView.alpha = 1
        }) { (completion) in
            self.navigateToNextPage()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func navigateToNextPage() {
        if SKYContainer.default().auth.currentUser == nil {
            self.performSegue(withIdentifier: RegisterSegueIdentifier, sender: self)
        } else {
            self.performSegue(withIdentifier: LoggedInSegueIdentifier, sender: self)
        }
    }
}
