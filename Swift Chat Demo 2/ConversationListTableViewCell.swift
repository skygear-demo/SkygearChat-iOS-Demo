//
//  ConversationListTableViewCell.swift
//  Swift Chat Demo 2
//
//  Created by Zachary on 26/9/2017.
//  Copyright © 2017 Skygear. All rights reserved.
//

import UIKit

class ConversationListTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var conversationNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var lastMessageTimeLabel: UILabel!
    @IBOutlet weak var unreadCountLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
