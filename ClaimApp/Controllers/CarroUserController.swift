//
//  CarroUserController.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 20/12/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation
import PromiseKit

let DraftDescriptionIsChanged = Notification.Name(rawValue: "DraftDescriptionIsChanged")
let SearchFieldDidBeginSearch = Notification.Name(rawValue: "SearchFieldDidBeginSearch")

let AppUserAccessTokenDidExpireNotification = Notification.Name(rawValue: "AppUserAccessTokenDidExpire")
let AppDidFetchUserNotification = Notification.Name(rawValue: "AppDidFetchUser")

let DraftDidChooseCurrency = Notification.Name(rawValue: "DraftDidChooseCurrency")
let DraftDidChooseCurrencyForTotalCell = Notification.Name(rawValue: "DraftDidChooseCurrencyForTotalCell")

let AppDidClearUserNotification = Notification.Name(rawValue: "AppDidClearUser")

let CountryChooseLastOption = Notification.Name(rawValue: "CountryChooseLastOption")
let AmountDidUpdateNotification = Notification.Name(rawValue: "AmountDidUpdateNotification")
let AmountDidUpdateToVCNotification = Notification.Name(rawValue: "AmountDidUpdateToVCNotification")

protocol UserController {
 
    var userAccessToken: AccessToken? { get set}
    var user: User? { get set}
    var isUserAuthenticated: Bool { get }
    var languageCode: String? { get }

    func bypass(passCode: String, phone: String?, countryCode: String?) -> Promise<(AccessToken, User)>
    func fetchUserAccessToken(phoneCode: String, phoneNumber: String, accessToken: String) -> Promise<AccessToken>
    func smsloginRequest(params: [String:Any]) -> Promise<String>
    func smsloginVerify(params: [String:Any]) -> Promise<User>
    func deleteUser(params: [String:Any]) -> Promise<DeleteUser>

    func changeLanguage(languageCode: String) -> Promise<Bool>
    func fetchLanguages() -> Promise<[Language]>
    
    func fetchUserCountries() -> Promise<[UserCountry]>

    func cleanUserToken()
    func logout()
    func logoutWithoutFcmToken()
}

class CarroUserController: UserController {
    
    var userApiClient: UserApiClient!
    var userAccessTokenStore: UserAccessTokenStore!
    var user: User?
    
    var languageCode: String? {
        get {
            if let code = SystemStoreService.shared().getLanguageCode() {
                return code
            } else {
                return AppServices.shared.countryLogic?.defaultLanguageCode
            }
//            return SystemStoreService.shared().getLanguageCode() ?? AppServices.shared.countryLogic?.defaultLanguageCode
        }
    }
    
    var userAccessToken: AccessToken? {
        get {
            return userAccessTokenStore.userAccessToken
        }
        set {
            userAccessTokenStore.userAccessToken = newValue
        }
    }
    
    var isUserAuthenticated: Bool {
        return userAccessToken != nil
    }
    
    func cleanUserToken() {
        userAccessTokenStore.cleanAccessTokenToKeychain()
    }
    
    func bypass(passCode: String, phone: String?, countryCode: String?) -> Promise<(AccessToken, User)> {
        
        return userApiClient.bypass(passCode: passCode, phone: phone, countryCode: countryCode).get { (tokenAndUser: (token: AccessToken, user: User)) in
            self.userAccessToken = tokenAndUser.token
            self.user = tokenAndUser.user
            
//            let usedPassCode = MZRSA.encryptString(passCode, privateKey: PRIVATE_KEY)
            
            UserDefaults.standard.set(passCode, forKey: AppConfig.currentUserPasscode)
            NotificationCenter.default.post(name: AppDidFetchUserNotification, object: nil)

        }
    }
    
    
    func smsloginRequest(params: [String:Any]) -> Promise<String> {
        return userApiClient.smsloginRequest(params:params)
    }
    func smsloginVerify(params: [String:Any]) -> Promise<User> {
        return userApiClient.smsloginVerify(params:params)
    }
    func deleteUser(params: [String:Any]) -> Promise<DeleteUser> {
        return userApiClient.deleteUser(params:params)
    }

    
    func fetchUserAccessToken(phoneCode: String, phoneNumber: String, accessToken: String) -> Promise<AccessToken> {
        
        guard let `userAccessToken` = userAccessToken else {
            
            return userApiClient.fetchUserAccessToken(phoneCode: phoneCode, phoneNumber: phoneNumber, accessToken: accessToken).get { userAccessToken in
                self.userAccessToken = userAccessToken
            }
        }
        
        return Promise { seal in
            seal.fulfill(userAccessToken)
        }
        
    }
    
    func changeLanguage(languageCode: String) -> Promise<Bool> {
        return userApiClient.changeLanguage(languageCode: languageCode)
    }
    
    func fetchLanguages() -> Promise<[Language]> {
        return userApiClient.fetchLanguages()
    }
    
    func fetchUserCountries() -> Promise<[UserCountry]> {
        return userApiClient.fetchUserCountries()
    }
    
    func logout() {
        NotificationCenter.default.post(name: AppDidClearUserNotification, object: nil)
        cleanUserToken()
        cleanUser()
    }
    
    func logoutWithoutFcmToken() {
        cleanUserToken()
        cleanUser()
    }
    
    func cleanUser() {
        UserDefaults.standard.removeObject(forKey: AppConfig.currentUserNameKey)
        UserDefaults.standard.removeObject(forKey: AppConfig.currentUserPhoneKey)
        UserDefaults.standard.removeObject(forKey: AppConfig.currentUserEmailKey)
        UserDefaults.standard.removeObject(forKey: AppConfig.currentUserIdKey)
        UserDefaults.standard.removeObject(forKey: AppConfig.currentUserImageKey)
        UserDefaults.standard.removeObject(forKey: AppConfig.currentUserPasscode)
        UserDefaults.standard.synchronize()
    }
}

