
//  SettingUserInfoTableViewCell.swift
//  Swift Chat Demo 2
//
//  Created by Zachary on 16/10/2017.
//  Copyright © 2017 Skygear. All rights reserved.
//

import UIKit

class SettingUserInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
