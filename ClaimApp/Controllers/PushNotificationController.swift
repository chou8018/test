//
//  PushNotificationController.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 21/9/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation
import PromiseKit

let AppDidReceiveBackgroundNotification = Notification.Name(rawValue: "AppDidReceiveBackgroundNotification")
let AppDidReceiveForegroundNotification = Notification.Name(rawValue: "AppDidReceiveForegroundNotification")

protocol PushNotificationController {
    func setup()
    
    /// Get last notification
    ///
    /// - Return lastNotification: notification
    func getLastNotification() -> [String: Any]?
    
    /// Set last notification
    ///
    /// - Parameter lastNotification: notification
    func setLastNotification(lastNotification: [String: Any]?)
    
    /// Handles notifications that launched the app
    ///
    /// - Parameter notificationInfo: notification payload
    func handleInitialNotification(_ notificationInfo: [String: Any])
 
    
    /// Handles notifications received in the background
    ///
    /// - Parameter notificationInfo: notification payload
    func handleBackgroundNotification(_ notificationInfo: [String: Any])
    
    
    /// Handles notifications received in the foreground
    ///
    /// - Parameter notificationInfo: notification payload
    func handleForegroundNotification(_ notificationInfo: [String: Any])
    
}
