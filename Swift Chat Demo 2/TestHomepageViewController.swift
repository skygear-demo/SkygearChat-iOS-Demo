//
//  TestHomepageViewController.swift
//  Swift Chat Demo 2
//
//  Created by Zachary on 25/9/2017.
//  Copyright © 2017 Skygear. All rights reserved.
//

import SKYKit
import SKYKitChat

class TestHomepageViewController: UIViewController {

    @IBOutlet weak var loginasLabel: UILabel!
    var conversation:SKYConversation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKYContainer.default().auth.login(withUsername: "zachary1", password: "zachary") { (record, error) in
            SKYContainer.default().chatExtension?.fetchConversation(conversationID: "1a42811c-0d5b-4319-b886-c54fce7a0330", fetchLastMessage: true, completion: { (conversation, error) in
                self.loginasLabel.text = SKYContainer.default().auth.currentUser?["username"] as? String
                self.conversation = conversation
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func nextPage(_ sender: Any) {
        self.performSegue(withIdentifier: "conversationlist", sender: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
