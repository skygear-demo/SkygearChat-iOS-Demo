//
//  Utilities.swift
//  Swift Chat Demo 2
//
//  Created by Zachary on 28/9/2017.
//  Copyright © 2017 Skygear. All rights reserved.
//

import JSQMessagesViewController
import SVProgressHUD

class Utilities: NSObject {

    static func handleQueryError(error: NSError) {
        SVProgressHUD.showError(withStatus: "Oops error occured: \(error.code) - \(error.userInfo["SKYErrorMessage"] ?? "Unknown")")
    }
    
    static func getInitials(withString string:String) -> String {
        return string.components(separatedBy: " ").reduce("") {
            return ($0 == "" ? "" : "\($0.characters.first!)") + "\($1.characters.first!)"
        }
    }
    
    static func avatarColor(number: Int) -> UIColor{
        let colors = [UIColor.jsq_messageBubbleRed(), UIColor.jsq_messageBubbleBlue(), UIColor.jsq_messageBubbleGreen(), UIColor.jsq_messageBubbleLightGray()]
        if let color = colors[number] {
            return color
        }else {
            return UIColor.clear
        }
    }
    
    static func avatarImage(withString string: String, color: UIColor, diameter: UInt) -> UIImage {
        return JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: string, backgroundColor: color, textColor: UIColor.white, font: UIFont.systemFont(ofSize: 14), diameter: diameter).avatarImage
    }
    
    
}
