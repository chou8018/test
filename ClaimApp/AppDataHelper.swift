//
//  AppDataHelper.swift
//  dealers
//
//  Created by mac on 2020/2/12.
//  Copyright © 2020 Trusty Cars. All rights reserved.
//

import Foundation

struct AppDataHelper {
    
    static var userController: UserController! {
        return AppServices.shared.find(UserController.self)
    }
    
    static var _user: User?
    static var user: User? {
        if let user = _user {
            return user
        }
        return userController.user
    }
    
    static var countryCode: CountryCode {
        if let currentCode = user?.countryCode  {
            return currentCode
        }
        return .SG
    }
    
    static var currencyCode: CurrencyCode {
        if let currencyCode = user?.country?.currencyCode  {
            return currencyCode
        }
        return .SGD
    }
    
    static var languageCode: LanguageCode? {
        if let currencyCode = user?.locale?.languageCode  {
            return currencyCode
        }
        return LanguageCode.english
    }
    
    static var separator: String {
        var separator = ","
        if countryCode == .ID {
            separator = "."
        }
        return separator
    }
    
    static var countryLogic: CountryLogic? {
        if let countryLogic = AppServices.shared.countryLogic {
            return countryLogic
        }
        return nil
    }

    static func getSeparator(_ currency_code: String?) -> String {
        if currency_code?.isEmpty ?? true {
            if AppDataHelper.currencyCode == .IDR {
                return "."
            }
            return ","
        }
        if let currency = CurrencyCode.init(rawValue: currency_code ?? "") {
            if currency == .IDR {
                return "."
            }
        }
        return ","
    }

    
}
