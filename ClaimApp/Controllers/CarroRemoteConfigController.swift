//
//  CarroRemoteConfigController.swift
//  dealers
//
//  Created by Alexander Vuong on 7/2/19.
//  Copyright © 2019 Trusty Cars. All rights reserved.
//

import Foundation
import PromiseKit

protocol RemoteConfigController {
    var remoteConfig: RemoteConfig? { get }
    var mobileVersion: MobileVersion? { get }
    func fetchRemoteConfig() -> Promise<RemoteConfig>
    func fetchMobileVersionConfig() -> Promise<MobileVersion>
    func purgeRemoteConfig()
    
    func registerFcmToken(token: String) -> Promise<Bool>
    func unregisterFcmToken() -> Promise<Bool>
}


class CarroRemoteConfigController: RemoteConfigController {
    func registerFcmToken(token: String) -> PromiseKit.Promise<Bool> {
        return remoteConfigAPIClient.registerFcmToken(token: token)
    }
    
    func unregisterFcmToken() -> PromiseKit.Promise<Bool> {
        return remoteConfigAPIClient.unregisterFcmToken()
    }
    
    var remoteConfigAPIClient: RemoteConfigApiClient!
    private(set)var remoteConfig: RemoteConfig?
    private(set)var mobileVersion: MobileVersion?
    
    func fetchRemoteConfig() -> Promise<RemoteConfig> {
        return remoteConfigAPIClient.fetchRemoteConfig().get { [weak self] config in
            self?.remoteConfig = config
        }
    }
    
    func fetchMobileVersionConfig() -> Promise<MobileVersion> {
        return remoteConfigAPIClient.fetchMobileVersionConfig().get { [weak self] config in
            self?.mobileVersion = config
        }
    }
    
    func purgeRemoteConfig() {
        remoteConfig = nil
    }
    
}
