//
//  UsersListTableViewCell.swift
//  Swift Chat Demo 2
//
//  Created by Zachary on 28/9/2017.
//  Copyright © 2017 Skygear. All rights reserved.
//

import UIKit

class UsersListTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userAvatarImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
