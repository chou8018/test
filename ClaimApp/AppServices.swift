//
//  AppServices.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 19/12/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation
import Swinject

class AppServices {
    
    static let shared = AppServices()
    private var container: Container!
    private var lock = NSLock()

    private init() {}
    
    func configure() {
        container = Container() { c in
            c.register(ClientAccessTokenApiClient.self, factory: { (_: Resolver) in
                CarroClientAccessTokenApiClient()
            }).inObjectScope(.container)
            
            c.register(ClientAccessTokenController.self, factory: { (r: Resolver) in
                
                let clientAccessTokenController = CarroClientAccessTokenController()
                clientAccessTokenController.clientAccessTokenApiClient = r.resolve(ClientAccessTokenApiClient.self)
                return clientAccessTokenController
                
            }).inObjectScope(.container)
            
            c.register(UserApiClient.self, factory: { (_: Resolver) in
                CarroUserApiClient()
            }).inObjectScope(.container)
            
            c.register(UserController.self, factory: { (r: Resolver) in
                
                let userController = CarroUserController()
                userController.userApiClient = r.resolve(UserApiClient.self)
                userController.userAccessTokenStore = r.resolve(UserAccessTokenStore.self)
                return userController
                
            }).inObjectScope(.container)
            
            c.register(UserAccessTokenStore.self, factory: { (_: Resolver) in
                return CarroUserAccessTokenStore()
            }).inObjectScope(.container)
            
            c.register(SellFlowApiClient.self, factory: { (_: Resolver) in
                LNSellFlowApiClient()
             }).inObjectScope(.container)
            
            c.register(SellFlowController.self, factory: { (r: Resolver) in
                
                let sellFlowController = LNSellFlowController()
                sellFlowController.sellFlowClient = r.resolve(SellFlowApiClient.self)
                return sellFlowController
                
            }).inObjectScope(.container)
            
            c.register(RemoteConfigApiClient.self, factory: { (_: Resolver) in
                CarroRemoteConfigApiClient()
            }).inObjectScope(.container)
            
            c.register(RemoteConfigController.self, factory: { (r: Resolver) in
                let remoteConfigController = CarroRemoteConfigController()
                remoteConfigController.remoteConfigAPIClient = r.resolve(RemoteConfigApiClient.self)
                return remoteConfigController
            }).inObjectScope(.container)
            
            c.register(CountryLogic.self, name: CountryCode.SG.rawValue, factory: { (_: Resolver) in
                SingaporeLogic()
            }).inObjectScope(.container)
            
            c.register(CountryLogic.self, name: CountryCode.TH.rawValue, factory: { (_: Resolver) in
                ThailandLogic()
            }).inObjectScope(.container)
            
            c.register(CountryLogic.self, name: CountryCode.ID.rawValue, factory: { (_: Resolver) in
                IndonesiaLogic()
            }).inObjectScope(.container)
            
            c.register(CountryLogic.self, name: CountryCode.MY.rawValue, factory: { (_: Resolver) in
                MalaysiaLogic()
            }).inObjectScope(.container)
            
            c.register(PushNotificationController.self, factory: { (r: Resolver) in
                
                let pushNotificationController = FirebasePushNotificationController()
                pushNotificationController.userApiClient = r.resolve(UserApiClient.self)
                pushNotificationController.userController = r.resolve(UserController.self)
                return pushNotificationController
                
            }).inObjectScope(.container)

        }
    }
    
    func find<Service>(_ serviceType: Service.Type, name: String? = nil) -> Service? {
        if let lookupName = name {
            return container.resolve(serviceType, name: lookupName)
        }
        return container.resolve(serviceType)
    }
    
    var countryLogic: CountryLogic? {
        lock.lock()
        let userController: UserController! = find(UserController.self)
        guard let user = userController.user else {
            lock.unlock()
            return nil
        }
        let logic: CountryLogic! = container.resolve(CountryLogic.self, name: user.countryCode.rawValue)
        lock.unlock()
        return logic
    }
    
    var remoteConfig: RemoteConfig? {
        return find(RemoteConfigController.self)?.remoteConfig
    }
    
    var mobileVersion: MobileVersion? {
        return find(RemoteConfigController.self)?.mobileVersion
    }
}
