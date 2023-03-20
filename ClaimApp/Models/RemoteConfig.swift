//
//  RemoteConfig.swift
//  dealers
//
//  Created by Alexander Vuong on 7/2/19.
//  Copyright © 2019 Trusty Cars. All rights reserved.
//

import Foundation

struct RemoteConfig: InitFailable {
    let urls: UrlsConfig?
    let contacts: ContactsConfig?
    
    init?(json: [String: Any]) {
        urls = json.jsonObject("url").flatMap { UrlsConfig(json: $0) }
        contacts = json.jsonObject("contact").flatMap{ ContactsConfig(json: $0) }
    }
}

struct UrlsConfig: InitFailable {
    let termsURL: URL?
    let aboutURL: URL?
    let faqURL: URL?
    let userManualURL: URL?

    init?(json: [String: Any]) {
        termsURL = json.string("terms").flatMap({ URL(string: $0) })
        aboutURL = json.string("about").flatMap({ URL(string: $0) })
        faqURL = json.string("faq").flatMap({ URL(string: $0) })
        userManualURL = json.string("user_manual").flatMap({ URL(string: $0) })

        if termsURL == nil
            && aboutURL == nil
            && faqURL == nil
            && userManualURL == nil {
            return nil
        }
    }
}

struct ContactsConfig: InitFailable {
    let newCarAdminContact: String?
    
    init?(json: [String : Any]) {
        newCarAdminContact = json.string("newcar_admin")
        
        if newCarAdminContact == nil {
            return nil
        }
    }
    
}
