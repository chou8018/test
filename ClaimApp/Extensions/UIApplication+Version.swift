//
//  UIApplication+Version.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 6/4/18.
//  Copyright © 2018 Trusty Cars. All rights reserved.
//

import Foundation

extension UIApplication {

    var appName: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "This App"
    }
    
    var versionString: String? {
        
        var versionComponents = [String]()
        
        if let info = Bundle.main.infoDictionary {
            if let version = info["CFBundleShortVersionString"] as? String {
                versionComponents.append(version)
            }
            if let build = info["CFBundleVersion"] as? String {
                versionComponents.append(build)
            }
        }
        
        var envString = ""
        switch AppConfig.environment {
        case .eks_qa:
            envString = "eks-qa"
        case .staging_dx:
            envString = "staging-dx"
        case .staging_bx:
            envString = "staging-bx"
        default:
            break
        }
        return "v\(versionComponents.joined(separator: " build ")) \(envString)"
    }
    
    var versionWithHomepage: String? {
        
        var versionComponents = [String]()
        
        if let info = Bundle.main.infoDictionary {
            if let version = info["CFBundleShortVersionString"] as? String {
                versionComponents.append(version)
            }
            if let build = info["CFBundleVersion"] as? String {
                versionComponents.append("(\(build))")
            }
        }
        var envString = ""
        switch AppConfig.environment {
        case .eks_qa:
            envString = "eks-qa"
        case .staging_dx:
            envString = "staging-dx"
        case .staging_bx:
            envString = "staging-bx"
        default:
            break
        }
        
        var usedString = "v\(versionComponents.joined(separator: " ")) "
        usedString += envString
        return usedString
    }
}
