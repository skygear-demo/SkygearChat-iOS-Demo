//
//  SKYQueryHelper.swift
//  Swift Chat Demo 2
//
//  Created by Zachary on 28/9/2017.
//  Copyright © 2017 Skygear. All rights reserved.
//

import SKYKit
import SVProgressHUD

class SKYQueryHelper: NSObject {
    static func performQuery(query: SKYQuery, completionBlock: @escaping ([SKYRecord])->Void) {
        SVProgressHUD.show()
        SKYContainer.default().publicCloudDatabase.perform(query) { (results, error) in
            if let error = error as NSError? {
                print(error)
                Utilities.handleQueryError(error: error)
                return
            }
            if let results = results as? [SKYRecord] {
                SVProgressHUD.dismiss()
                completionBlock(results)
            }
        }
    }
}
