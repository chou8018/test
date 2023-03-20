//
//  User.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 27/8/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation

struct User: InitFailable {
    
    let id: String
    var name: String?
    let phone: String?
    let email: String?
    let profileImageUrl: String?
    var countryCode: CountryCode = .SG
    let locale: UserLocale?
    var isActive: Bool = false
    var isVerified: Bool = false
    let country: UserCountry?

    init?(json: [String: Any]) {
        
        guard let idAsNumber = json.lenientNumber("id") else {
               return nil
        }
        
        self.id = idAsNumber.stringValue
        self.name = json.string("name")
        self.email = json.string("email")
        self.phone = json.string("phone")
        self.profileImageUrl = json.string("profile_image.cdn_thumbnail_url")
        let countryCodeString = json.string("country.country_code") ?? "SG"
        if let countryCode = CountryCode(rawValue: countryCodeString) {
            self.countryCode = countryCode
        }
        
        self.locale = json.jsonObject("locale").flatMap { UserLocale(json: $0) }
        if let isActive = json.lenientNumber("is_active") {
            self.isActive = isActive.boolValue
        }
        
        if let isVerified = json.lenientNumber("is_verified") {
            self.isVerified = isVerified.boolValue
        }
        
        self.country = json.jsonObject("country").flatMap { UserCountry(json: $0) }
    }
}

struct UserLocale: InitFailable {
    
    let languageCode: LanguageCode?
    
    init?(json: [String : Any]) {
        
        if let languageCode = json.string("language").flatMap({ LanguageCode(rawValue: $0) }) {
            self.languageCode = languageCode
        } else {
            return nil
        }
    }
}

enum CurrencyCode: String {
    case SGD = "SGD"
    case IDR = "IDR"
    case THB = "THB"
    case MYR = "MYR"
    case JPY = "JPY"
    case MMK = "MMK"
    case TWD = "TWD"
    case USD = "USD"
    case VND = "VND"
    case CNY = "CNY"
}

struct UserCountry: InitFailable ,ArrayBuildable {
    
    let id: NSNumber?
    let countryCode: String?
    let displayName: String?
    let currencyCode: CurrencyCode?
    let phoneCode: String?

    init?(json: [String : Any]) {
        
//        guard let id = json.lenientNumber("id") else {
//               return nil
//        }
        self.id = json.lenientNumber("id")
        self.countryCode = json.string("country_code")
        self.displayName = json.string("display_name")
        self.phoneCode = json.string("phone_code")

        if let currencyCode = json.string("currency_code").flatMap({ CurrencyCode(rawValue: $0) }) {
            self.currencyCode = currencyCode
        } else {
            self.currencyCode = nil
        }
    }
}

struct UserCity: InitFailable ,ArrayBuildable {
    
    let id: NSNumber
    let countryCode: String?
    let displayName: String?
    let currencyCode: CurrencyCode?

    init?(json: [String : Any]) {
        
        guard let id = json.lenientNumber("id") else {
               return nil
        }
        self.id = id
        self.countryCode = json.string("country_code")
        self.displayName = json.string("display_name")
        
        if let currencyCode = json.string("currency_code").flatMap({ CurrencyCode(rawValue: $0) }) {
            self.currencyCode = currencyCode
        } else {
            return nil
        }
    }
}

struct UserProfile {
    
    let name: String?
    let email: String?
    let password: String?
    let password_confirmation: String?
    let country_code: String?
    let city_id: String?
    let phone: String?

    init(name: String? = nil, email: String?, password: String?, password_confirmation: String? = nil, country_code: String? = nil, city_id: String? = nil, phone: String? = nil) {
        self.name = name
        self.email = email
        self.password = password
        self.password_confirmation = password_confirmation
        self.country_code = country_code
        self.city_id = city_id
        self.phone = phone
    }
}

