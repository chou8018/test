//
//  SystemStoreService.swift
//  dealers
//
//  Created by Warren Frederick Balcos on 24/4/20.
//  Copyright © 2020 Trusty Cars. All rights reserved.
//

import Foundation

final class SystemStoreService {
 
    let LANGUAGE_NAMES = ["English", "Thai", "Bahasa"]
    let LANGUAGE_CODES = ["en", "th", "id"]
    let LANGUAGE_LOCALIZE_KEYS = ["language_name_english", "language_name_thai", "language_name_bahasa"]
    
    private static var systemStore: SystemStoreService = {
        return SystemStoreService()
    }()
    
    class func shared() -> SystemStoreService {
        return systemStore
    }
    
    private let userDefaults: UserDefaults
    
    private init(userDefaults : UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func saveValue(forKey key: String, value: Any) {
        self.userDefaults.set(value, forKey: key)
    }
    
    func readValue<T>(forKey key: String) -> T? {
        return self.userDefaults.value(forKey: key) as? T
    }
    
    func getLanguageCode() -> String? {
        return self.readValue(forKey: "language")
    }
    
    func setLanguageCode(value: String) {
        self.saveValue(forKey: "language", value: value)
    }
    
    func getDefaultLanguages() -> [Language] {
        var languages: [Language] = []
        for i in LANGUAGE_NAMES.indices {
            let title = String.localized(LANGUAGE_LOCALIZE_KEYS[i], comment:LANGUAGE_NAMES[i])
            languages.append(Language(title: title, value: LANGUAGE_CODES[i]))
        }
        return languages
    }
}
