//
//  Language.swift
//  dealers
//
//  Created by Warren Frederick Balcos on 16/6/20.
//  Copyright © 2020 Trusty Cars. All rights reserved.
//

import Foundation

struct Language: InitFailable, ArrayBuildable {
    
    let title : String?
    let value : String?
    
    init?(json: [String : Any]) {
        title = json.string("title")
        value = json.string("value")
    }
    
    init(title: String?, value: String?) {
        self.title = title
        self.value = value
    }
}

enum LanguageCode: String {
    case english = "en"
    case thai = "th"
    case indonesian = "id"
}
