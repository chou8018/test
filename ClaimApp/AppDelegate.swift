//
//  AppDelegate.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/26.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import FirebaseRemoteConfig

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var notificationController: PushNotificationController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: CALoginViewController())
        window?.makeKeyAndVisible()
        
        AppTheme.applyTheme()
        IQKeyboardManager.shared.enable = true
        AppServices.shared.configure()
        fetchClientAccessToken()
        
        initFirebase()
        
        registerForPushNotifications(application: application)
        notificationController = AppServices.shared.find(PushNotificationController.self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.handleClientOrUserAccessTokenDidExpire), name: AppClientAccessTokenDidExpireNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.handleClientOrUserAccessTokenDidExpire), name: AppUserAccessTokenDidExpireNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.handleAppDidFetchUser), name: AppDidFetchUserNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.fetchClientAccessToken), name: AppShouldRefreshClientAccessTokenNotification, object: nil)
        
        return true
    }
    
    func initFirebase() {
        
        var fileName = "GoogleService-Info"
        if AppConfig.environment == .production {
            fileName = "prod-GoogleService-Info"
        }
        guard let plistPath = Bundle.main.path(forResource: fileName, ofType: "plist"),
                let options =  FirebaseOptions(contentsOfFile: plistPath)
        else { return }
        FirebaseApp.configure(options: options)
        
        
//        let remoteConfig = FirebaseRemoteConfig.RemoteConfig.remoteConfig()
//        remoteConfig.setDefaults(fromPlist: "FBRemoteConfigDefaults")
//        let remoteConfigSettings = RemoteConfigSettings()
//        remoteConfigSettings.minimumFetchInterval = AppConfig.fbRemoteConfigMinimumFetchIntervalSeconds
//        remoteConfig.configSettings = remoteConfigSettings
//
//        FirebaseApp.configure()
    }
    
    
    
    @objc private func handleClientOrUserAccessTokenDidExpire() {
        
        guard let _ = window?.rootViewController else { return }
        
        if let userController = AppServices.shared.find(UserController.self) {
            userController.logoutWithoutFcmToken()
        }
        self.window?.rootViewController = UINavigationController(rootViewController: CALoginViewController())
        
    }
    
    @objc private func fetchClientAccessToken() {
        
        let clientAccessTokenController: ClientAccessTokenController! = AppServices.shared.find(ClientAccessTokenController.self)
        clientAccessTokenController.fetchClientAccessToken().catch { [weak self] error in
            self?.window?.makeToast(error.localizedDescription)
        }
    }
    
    @objc private func handleAppDidFetchUser() {
        print("Successfully fetched user profile!")
        
        let userController: UserController! = AppServices.shared.find(UserController.self)
        
        guard let vc = window?.rootViewController, let user = userController.user else { return }
        
        if let languageCode = user.locale?.languageCode {
            SystemStoreService.shared().setLanguageCode(value: languageCode.rawValue)
        }
        
        UserDefaults.standard.set(user.name, forKey: AppConfig.currentUserNameKey)
        UserDefaults.standard.set(user.phone, forKey: AppConfig.currentUserPhoneKey)
        UserDefaults.standard.set(user.email, forKey: AppConfig.currentUserEmailKey)
        UserDefaults.standard.set(user.id, forKey: AppConfig.currentUserIdKey)
        UserDefaults.standard.set(user.profileImageUrl, forKey: AppConfig.currentUserImageKey)
        UserDefaults.standard.synchronize()
        
        fetchMobileVersion()
    }
    
    private func fetchMobileVersion() {
        let remoteConfigController: RemoteConfigController! = AppServices.shared.find(RemoteConfigController.self)
        remoteConfigController.fetchMobileVersionConfig().catch({error in print("Error: " + error.localizedDescription)})
    }
    
    func registerForPushNotifications(application: UIApplication) {
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        if let notificationPayload = notification.request.content.userInfo as? [String: Any] {
            notificationController.handleForegroundNotification(notificationPayload)
        }
        completionHandler([.alert])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let notificationPayload = response.notification.request.content.userInfo as? [String: Any] {
            notificationController.handleBackgroundNotification(notificationPayload)
        }
        completionHandler()
    }
}
