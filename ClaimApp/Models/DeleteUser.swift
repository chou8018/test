//
//  DeleteUser.swift
//  dealers
//
//  Created by 付耀辉 on 2022/6/14.
//  Copyright © 2022 Trusty Cars. All rights reserved.
//

import UIKit

struct DeleteUser: InitFailable {
    
    let id: NSNumber
    let is_active: Bool
    
    init?(json: [String : Any]) {
        guard let id = json["id"] as? NSNumber,
              let is_active = json.number("is_active")
            else {
                return nil
        }
        self.id = id
        self.is_active = is_active.boolValue
    }
    
}
