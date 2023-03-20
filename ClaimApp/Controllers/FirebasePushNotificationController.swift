//
//  FirebasePushNotificationController.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 21/9/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation
import FirebaseCore
import PromiseKit
import FirebaseMessaging

class FirebasePushNotificationController: NSObject, PushNotificationController {
    
    var userApiClient: UserApiClient!
    var userController: UserController!
    
    var lastNotification: [String: Any]?
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FirebasePushNotificationController.handleAppDidFetchUserNotification), name: AppDidFetchUserNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FirebasePushNotificationController.handleAppDidClearUserNotification(notification:)), name: AppDidClearUserNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FirebasePushNotificationController.applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FirebasePushNotificationController.applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
    }
    
    @objc func handleAppDidFetchUserNotification() {
        registerFcmToken()
    }
    
    @objc func handleAppDidClearUserNotification(notification: Notification) {
        unregisterFcmToken()
    }
    
    func setup() {
        Messaging.messaging().delegate = self
        
        if let _ = userController.user {
            registerFcmToken()
        }
    }
    
    func getLastNotification() -> [String : Any]? {
        return self.lastNotification
    }
    
    func setLastNotification(lastNotification: [String : Any]?) {
        self.lastNotification = lastNotification
    }
    
    func handleInitialNotification(_ notificationInfo: [String : Any]) {
        //lastNotification = notificationInfo
    }
    
    func handleBackgroundNotification(_ notificationInfo: [String : Any]) {
        lastNotification = notificationInfo
        DispatchQueue.main.async{
            NotificationCenter.default.post(name: AppDidReceiveBackgroundNotification, object: nil, userInfo: notificationInfo)
        }
    }
    
    func handleForegroundNotification(_ notificationInfo: [String : Any]) {
        //lastNotification = notificationInfo
        DispatchQueue.main.async{
            NotificationCenter.default.post(name: AppDidReceiveForegroundNotification, object: nil, userInfo: notificationInfo)
        }
    }
    
    @objc private func registerFcmToken() {
        guard userController.isUserAuthenticated,
            let fcmToken = Messaging.messaging().fcmToken else {
            return
        }
        print("fcmToken = \(fcmToken)")
        
        let remoteConfigController: RemoteConfigController! = AppServices.shared.find(RemoteConfigController.self)
        
        remoteConfigController.registerFcmToken(token: fcmToken).done { (registered: Bool) -> Void in
            //no op
            print("Successfully registered fcm token...")
        }.catch { _ in
            print("Failed to register fcm token, retrying in 20 seconds...")
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(FirebasePushNotificationController.registerFcmToken), object: nil)
            self.perform(#selector(FirebasePushNotificationController.registerFcmToken), with: nil, afterDelay: 20)
        }
    }
    
    @objc private func unregisterFcmToken() {
        guard userController.isUserAuthenticated else {
            return
        }
        
        let remoteConfigController: RemoteConfigController! = AppServices.shared.find(RemoteConfigController.self)
        
        remoteConfigController.unregisterFcmToken().done { (registered: Bool) -> Void in
            //no op
            print("Successfully unregistered fcm token...")
        }.catch { _ in
            print("Failed to unregister fcm token, retrying in 20 seconds...")
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(FirebasePushNotificationController.unregisterFcmToken), object: nil)
            self.perform(#selector(FirebasePushNotificationController.unregisterFcmToken), with: nil, afterDelay: 20)
        }
    }
    
    @objc fileprivate func applicationDidBecomeActive(_ notification: Notification) {
    }
    
    @objc fileprivate func applicationDidEnterBackground(_ notification: Notification) {
    }
    
}

extension FirebasePushNotificationController: MessagingDelegate {
 
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        print("FCM token refreshed, registering with server")
        
        if let _ = userController.user {
            registerFcmToken()
        }
        
    }
    
}
