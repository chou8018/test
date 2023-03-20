//
//  CountryCode.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 12/1/18.
//  Copyright © 2018 Trusty Cars. All rights reserved.
//

import Foundation

enum CountryCode: String {
    
    case SG = "SG"
    case TH = "TH"
    case ID = "ID"
    case MY = "MY"
    case TW = "TW"

    var id: Int {
        switch self {
        case .SG:
            return 1
        case .ID:
            return 2
        case .TH:
            return 3
        case .MY:
            return 49
        case .TW:
            return 886
        }
    }
    
    init?(phoneCode: String) {
        switch phoneCode {
        case "65":
            self = .SG
        case "62":
            self = .ID
        case "66":
            self = .TH
        case "60":
            self = .MY
        case "886":
            self = .TW
        default:
            return nil
        }
    }
    
}
