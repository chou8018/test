//
//  AppConfig.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 19/12/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation

typealias Minute = Int
typealias CC = Int

enum Environment:String {
    case production = "production"
    case staging_dx = "staging_dx"
    case eks_qa = "eks_qa"
    case staging_bx = "staging_bx"
}

struct AppConfig {
    
//    static var baseProdUrl = "https://wsapi.carro.sg/"
    static var baseProdUrl = "https://captain-api.carro.sg/"
    static var baseEksQA = "https://ws-api-eks.getcars.dev/"
    static var baseStagingDxUrl = "https://dx-wsapi.getcarsstaging.com/"
    static var baseStagingBxUrl = "https://bx-wsapi.getcarsstaging.com/"

    static var defaultEnv:Environment {
        return .staging_dx
    }
    
    static var currentEnv:Environment = defaultEnv {
        didSet {
            UserDefaults.standard.set(currentEnv.rawValue, forKey: "AppConfig_currentEnv")
            UserDefaults.standard.synchronize()
            let clientAccessTokenController: ClientAccessTokenController! = AppServices.shared.find(ClientAccessTokenController.self)
            clientAccessTokenController.resetClientAccessToken()
            NotificationCenter.default.post(name: AppShouldRefreshClientAccessTokenNotification, object: nil)
        }
    }
    
    static var selectEnv:Environment {
        if let env = UserDefaults.standard.value(forKey: "AppConfig_currentEnv") as? String {
            let storageEnv = Environment.init(rawValue: env)
            if currentEnv != storageEnv {
//                return currentEnv
            }
            return Environment.init(rawValue: env) ?? defaultEnv
        }
        return defaultEnv
    }
    
    static var testEnvironment: Environment?
    static var environment: Environment {
        if let env = testEnvironment {
            return env
        }
        if let environmentString = Bundle.main.infoDictionary?["Environment"] as? String {
            if environmentString.lowercased() == "production" {
                stopDebugPrint = true
                return .production
            }
        }
        return selectEnv
    }
    
    static var clientOAuthUrlString: String {
        if environment == .production {
            return "\(baseProdUrl)oauth/token"
        } else if environment == .staging_dx {
            return "\(baseStagingDxUrl)oauth/token"
        } else if environment == .staging_bx {
            return "\(baseStagingBxUrl)oauth/token"
        } else if environment == .eks_qa {
            return "\(baseEksQA)oauth/token"
        }
        fatalError()
    }
    
    static var carroApiBaseUrl: String {
        return carroNoAuctionApiBaseUrlFromVersion("v1")
    }
    
    static var carroApiV2BaseUrl: String {
        return carroNoAuctionApiBaseUrlFromVersion("v2")
    }
    
    static func carroNoAuctionApiBaseUrlFromVersion(_ version: String) -> String {
        if environment == .production {
            return "\(baseProdUrl)api/\(version)"
        }  else if environment == .staging_dx {
            return "\(baseStagingDxUrl)api/\(version)"
        } else if environment == .staging_bx {
            return "\(baseStagingBxUrl)api/\(version)"
        } else if environment == .eks_qa {
            return "\(baseEksQA)api/\(version)"
        }
        fatalError()
    }
    
    static var fbRemoteConfigMinimumFetchIntervalSeconds: Double {
        switch environment {
        case .staging_dx:
            return 10
        default:
            return 3600
        }
    }

    static let app_store_review = "app_tester@carro.com"
    
    static let userTokenTypeKey = "v1.userTokenType"
    static let userAccessTokenKey = "v1.userAccessToken"
    static let clientTokenTypeKey = "clientTokenType"
    static let clientAccessTokenKey = "clientAccessToken"
    
    static let currentUserNameKey = "current_user_name"
    static let currentUserPhoneKey = "current_user_phone"
    static let currentUserEmailKey = "current_user_email"
    static let currentUserIdKey = "current_user_id"
    static let currentUserImageKey = "current_user_image"
    static let currentUserPasscode = "current_user_passcode"

    static var appId: String? {
        return Bundle.main.infoDictionary?["App"] as? String
    }
    
    static var bundleId: String? {
        return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    }
    
    static var version: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static var localUserId: String? {
        return UserDefaults.standard.string(forKey: AppConfig.currentUserIdKey)
    }
    
    static var userAccount: String {
        return Bundle.main.infoDictionary?["USER_ACCOUNT"] as? String ?? ""
    }
    
    static var userPassword: String {
        let user_password = Bundle.main.infoDictionary?["USER_PASSWORD"] as? NSDictionary
        if defaultEnv == .eks_qa {
            return user_password?["eks_qa"] as? String ?? ""
        } else {
            return user_password?["staging_dx"] as? String ?? ""
        }
    }
    
    static let dateFormatInYearMonthDayWithSlash = "dd/MMM/yyyy"
    
    static let kScreenWidth = UIScreen.main.bounds.size.width
    static let kScreenHeight = UIScreen.main.bounds.size.height
    
    static let isPhone = Bool(UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone)
    static let isPhone6 = Bool(kScreenHeight == 568 && isPhone)
    static let isPhone8 = Bool(kScreenHeight == 667 && isPhone)
    static let isPhone8Plus = Bool(kScreenHeight == 736 && isPhone)
    static let isPhoneX = Bool(kScreenHeight == 812.0 && isPhone)
    static let isPhoneXSeries = Bool(kScreenWidth >= 375.0 && kScreenHeight >= 812.0 && isPhone)
    
    static let isPhone11 = Bool(kScreenWidth == 414.0 && kScreenHeight == 896.0 && isPhone)
    static let isPhone12 = Bool(kScreenWidth == 390.0 && kScreenHeight == 844.0 && isPhone)
    static let isPhone11Width = Bool(kScreenWidth == 414.0 && isPhone)
    static let isPhone12ProMax = Bool(kScreenWidth >= 428.0 && isPhone)
    static let isGreaterPhone11Width = Bool(kScreenWidth >= 414.0 && isPhone)

    static let kNavigationHeight = CGFloat(isPhoneXSeries ? 88 : 64)
    static let kStatusBarHeight = CGFloat(isPhoneXSeries ? 44 : 20)
    static let kTabBarHeight = CGFloat(isPhoneXSeries ? (49 + 34) : 49)
    static let kTopSafeHeight = CGFloat(isPhoneXSeries ? 44 : 0)
    static let kBottomSafeHeight = CGFloat(isPhoneXSeries ? 34 : 0)
    
    static let scale_height = kScreenHeight * 1.0/667
    
    static let kHeightWithNavigationAndTab: CGFloat = kScreenHeight - (kNavigationHeight + kTabBarHeight)
    
    static let kHeightWithNavigation: CGFloat = kScreenHeight - kNavigationHeight
}
