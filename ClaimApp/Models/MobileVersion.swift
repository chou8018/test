//
//  MobileVersion.swift
//  dealers
//
//  Created by Warren Frederick Balcos on 31/3/20.
//  Copyright © 2020 Trusty Cars. All rights reserved.
//

import Foundation

struct MobileVersion: InitFailable {
    
    let versionUpdate : VersionUpdate?
    
    init?(json: [String: Any]) {
        versionUpdate = json.jsonObject("version_update").flatMap { VersionUpdate(json: $0) }
    }
    
}

struct VersionUpdate {

    let latestVersionCode : NSNumber?
    let latestVersion : String?
    let forceUpdateVersion : NSNumber?
    let updateTitle : String?
    let updateDesc: String?
    let isForceUpdate: Bool

    init?(json: [String: Any]) {
        
        latestVersionCode = json["latest_version_code"] as? NSNumber ?? 0
        latestVersion = json.string("latest_version")
        forceUpdateVersion = json["force_update_version_code"] as? NSNumber ?? 0
        updateTitle = json.string("update_title")
        updateDesc = json.string("update_description")
        isForceUpdate = json["is_force_update"] as? Bool ?? false
    }
    
}
