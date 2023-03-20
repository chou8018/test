//
//  CarroUserAccessTokenStore.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 15/7/19.
//  Copyright © 2019 Trusty Cars. All rights reserved.
//

import Foundation
import KeychainAccess

class CarroUserAccessTokenStore: UserAccessTokenStore {
    
    var userAccessToken: AccessToken? {
        get {
            return accessTokenFromKeychain
        }
        set {
            saveAccessTokenToKeychain(type: newValue?.type, value: newValue?.value)
        }
    }
    
    lazy var keychain: Keychain = {
        guard let bundleId = AppConfig.bundleId else { fatalError("Unable to setup keychain") }
        return Keychain(service: bundleId)
    }()
    
    private var accessTokenFromKeychain: AccessToken? {
//        guard
//            let type = try? keychain.getString(AppConfig.userTokenTypeKey),
//            let value = try? keychain.getString(AppConfig.userAccessTokenKey) else {
//                return nil
//        }
        
        guard
            let type = UserDefaults.standard.value(forKey: AppConfig.userTokenTypeKey) as? String,
            let value = UserDefaults.standard.value(forKey: AppConfig.userAccessTokenKey) as? String else {
            return nil
        }
        
        return AccessToken(type: type, value: value)
    }
    
    private func saveAccessTokenToKeychain(type: String?, value: String?) {
//        guard let type = type, let value = value else {
//            try? keychain.remove(AppConfig.userTokenTypeKey)
//            try? keychain.remove(AppConfig.userAccessTokenKey)
//            return
//        }
//        try? keychain.set(type, key: AppConfig.userTokenTypeKey)
//        try? keychain.set(value, key: AppConfig.userAccessTokenKey)
        
        guard let type = type, let value = value else {
            return
        }
        UserDefaults.standard.set(type, forKey: AppConfig.userTokenTypeKey)
        UserDefaults.standard.set(value, forKey: AppConfig.userAccessTokenKey)
        UserDefaults.standard.synchronize()
    }
    
    func cleanAccessTokenToKeychain() {
        UserDefaults.standard.removeObject(forKey: AppConfig.userTokenTypeKey)
        UserDefaults.standard.removeObject(forKey: AppConfig.userAccessTokenKey)
        UserDefaults.standard.synchronize()
    }
}
