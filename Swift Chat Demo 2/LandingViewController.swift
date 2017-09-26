//
//  LandingViewController.swift
//  Swift Chat Demo 2
//
//  Created by Zachary on 26/9/2017.
//  Copyright © 2017 Skygear. All rights reserved.
//

import UIKit
import SKYKit

let RegisterSegueIdentifier:String = "Register"
let LoggedInSegueIdentifier:String = "LoggedIn"

class LandingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.perform(#selector(self.navigateToNextPage), with: nil, afterDelay: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func navigateToNextPage() {
        if SKYContainer.default().auth.currentUser == nil {
            self.performSegue(withIdentifier: RegisterSegueIdentifier, sender: self)
        }else {
            self.performSegue(withIdentifier: LoggedInSegueIdentifier, sender: self)
        }
    }
}
