//
//  CarroClientAccessTokenController.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 20/12/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation
import PromiseKit

let AppClientAccessTokenDidExpireNotification = Notification.Name(rawValue: "AppClientAccessTokenDidExpire")
let AppDidFetchClientAccessTokenNotification = Notification.Name(rawValue: "AppDidFetchClientAccessToken")

let AppDidFetchClientAPIAccessTokenNotification = Notification.Name(rawValue: "AppDidFetchClientAPIAccessTokenNotification")

let AppShouldRefreshClientAccessTokenNotification = Notification.Name(rawValue: "AppShouldRefreshClientAccessToken")

protocol ClientAccessTokenController {
    var isClientAuthorized: Bool { get }
    var clientAccessToken: AccessToken? { get }
    func fetchClientAccessToken() -> Promise<AccessToken>
    func resetClientAccessToken()
    func purgeClientAccessToken()
}

final class CarroClientAccessTokenController: ClientAccessTokenController {
    
    var clientAccessTokenApiClient: ClientAccessTokenApiClient!
    
    private(set) var clientAccessToken: AccessToken? {
        get {
            return accessTokenFromUserDefaults(typeKey: AppConfig.clientTokenTypeKey, valueKey: AppConfig.clientAccessTokenKey)
        }
        set {
            UserDefaults.standard.set(newValue?.type, forKey: AppConfig.clientTokenTypeKey)
            UserDefaults.standard.set(newValue?.value, forKey: AppConfig.clientAccessTokenKey)
        }
    }
    
    func resetClientAccessToken() {
        clientAccessToken = nil
    }
    
    var isClientAuthorized: Bool {
        return clientAccessToken != nil
    }
    
    func fetchClientAccessToken() -> Promise<AccessToken> {
        
        guard let `clientAccessToken` = clientAccessToken else {
            return clientAccessTokenApiClient.fetchClientAccessToken().get { clientAccessToken in
                self.clientAccessToken = clientAccessToken
                NotificationCenter.default.post(name: AppDidFetchClientAPIAccessTokenNotification, object: nil)
            }
        }
        
        let accessTokenPromise: Promise<AccessToken> = .value(clientAccessToken)
        
        return  accessTokenPromise.get { clientAccessToken in
            NotificationCenter.default.post(name: AppDidFetchClientAccessTokenNotification, object: nil)
        }
        
    }
    
    @objc func purgeClientAccessToken() {
        print("Purging client access token")
        UserDefaults.standard.set(nil, forKey: AppConfig.clientTokenTypeKey)
        UserDefaults.standard.set(nil, forKey: AppConfig.clientAccessTokenKey)
    }
    
    private func accessTokenFromUserDefaults(typeKey: String, valueKey: String) -> AccessToken? {
        
        guard
            let value = UserDefaults.standard.string(forKey: valueKey),
            let type = UserDefaults.standard.string(forKey: typeKey)
            else {
                return nil
        }
        
        return AccessToken(type: type, value: value)
        
    }
    
}
