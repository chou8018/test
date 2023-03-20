//
//  CarroUserApiClient.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 20/12/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//
import Foundation
import PromiseKit
import Alamofire

protocol UserApiClient {
    
    func bypass(passCode: String, phone: String?, countryCode: String?) -> Promise<(AccessToken, User)>
    func fetchUserAccessToken(phoneCode: String, phoneNumber: String, accessToken: String) -> Promise<AccessToken>
    func smsloginRequest(params: [String:Any]) -> Promise<String>
    func smsloginVerify(params: [String:Any]) -> Promise<User>
    func deleteUser(params: [String:Any]) -> Promise<DeleteUser>

    func changeLanguage(languageCode: String) -> Promise<Bool>
    func fetchLanguages() -> Promise<[Language]>
    
    func registerFcmToken(token: String) -> Promise<Bool>
    func unregisterFcmToken() -> Promise<Bool>
    
    func fetchUserCountries() -> Promise<[UserCountry]>

}

final class CarroUserApiClient: UserApiClient, ApiClient {
    
    func bypass(passCode: String, phone: String?, countryCode: String?) -> Promise<(AccessToken, User)> {
        
        return Promise { seal in
            
            self.request(CarroUserApiRouter.bypass(passCode: passCode, phone: phone, countryCode: countryCode))
                .basicCheckedResponseJSON(seal.reject, success: { (statusCode, response) in
                    
                    switch statusCode {
                        
                    case HttpStatusCode.ok.rawValue:
                        
                        guard
                            let json = response.result.value as? [String: Any],
                            let dataJson = json["data"] as? [String: Any],
                            let userJson = dataJson["user"] as? [String: Any],
                            let user = User(json: userJson),
                            let token = dataJson["access_token"] as? String
                        else {
                            seal.reject(ApiError.unknown)
                            return
                        }
                        
                        let accessToken = AccessToken(type: "Bearer", value: token)
                        seal.fulfill((accessToken, user))
                        
                    case HttpStatusCode.invalid.rawValue:
                        let value = response.result.value as? [String: Any]
                        let message = value?.values.first as? String
                        seal.reject(ApiError.generalError(message:message ?? "unknow error"))
                    case HttpStatusCode.unprocessable.rawValue:
                        NotificationCenter.default.post(name: AppClientAccessTokenDidExpireNotification, object: nil)
                        seal.reject(ApiError.unauthorized)
                    case HttpStatusCode.unauthorized.rawValue:
                        let value = response.result.value as? [String: Any]
                        let message = value?.values.first as? String
                        seal.reject(ApiError.generalError(message: message ?? "Unauthorized"))
                    default:
                        seal.reject(ApiError.unknown)
                    }
                    
                })
            
        }
        
    }
    
    
    func fetchUserAccessToken(phoneCode: String, phoneNumber: String, accessToken: String) -> Promise<AccessToken> {
        
        return Promise { seal in
            
            self.request(CarroUserApiRouter.userAccessToken(phoneCode: phoneCode, phoneNumber: phoneNumber, accessToken: accessToken))
                .basicCheckedResponseJSON(seal.reject, success: { (statusCode, response) in
                    
                    switch statusCode {
                        
                    case HttpStatusCode.ok.rawValue:
                        
                        guard
                            let json = response.result.value as? [String: Any],
                            let dataJson = json["data"] as? [String: Any],
                            let token = dataJson["token"] as? String
                        else {
                            seal.reject(ApiError.unknown)
                            return
                        }
                        
                        seal.fulfill(AccessToken(type: "Bearer", value: token))
                    case HttpStatusCode.invalid.rawValue:
                        let value = response.result.value as? [String: Any]
                        let message = value?.values.first as? String
                        seal.reject(ApiError.generalError(message:message ?? "unknow error"))

                    default:
                        seal.reject(ApiError.unknown)
                    }
                    
                })
        }
    }
    
    func changeLanguage(languageCode: String) -> Promise<Bool> {
        return Promise { seal in
            
            self.request(CarroUserApiRouter.changeLanguage(languageCode: languageCode))
                .checkedResponseJSON(seal.reject, success: makeHandlerForBooleanResult(seal.fulfill, seal.reject))
        }
    }
    
    func fetchLanguages() -> Promise<[Language]> {
        return Promise { seal in
            self.request(CarroUserApiRouter.languages)
                .checkedResponseJSON(seal.reject, success: makeHandlerForArrayResult(seal.fulfill, seal.reject))
        }
    }
    
    func registerFcmToken(token: String) -> Promise<Bool> {
        return Promise { seal in
            self.request(CarroUserApiRouter.registerFcmToken(token: token)).checkedResponseJSON(seal.reject, success: makeHandlerForBooleanResult(seal.fulfill, seal.reject))
        }
    }
    
    func unregisterFcmToken() -> Promise<Bool> {
        return Promise { seal in
            self.request(CarroUserApiRouter.unregisterFcmToken).checkedResponseJSON(seal.reject, success: makeHandlerForBooleanResult(seal.fulfill, seal.reject))
        }
    }
    
    func smsloginRequest(params: [String:Any]) -> Promise<String> {
        
        return Promise { seal in
                        
            let clientAccessTokenController: ClientAccessTokenController! = AppServices.shared.find(ClientAccessTokenController.self)
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + (clientAccessTokenController?.clientAccessToken?.value ?? "")
            ]
            Alamofire.request(AppConfig.carroApiV2BaseUrl+"/mobile/sms-login/request", method: .post, parameters: params, headers: headers).basicCheckedResponseJSON(seal.reject, success: { (statusCode, response) in
                
                switch statusCode {
                case HttpStatusCode.createdOrUpdated.rawValue: fallthrough
                case HttpStatusCode.ok.rawValue:
                    
                    guard let json = response.result.value as? [String: Any]
                        else {
                        seal.reject(ApiError.generalError(message: "Account authentication failed. Please try again."))
                            return
                    }
                    seal.fulfill(json.number("data.code")?.stringValue ?? "")
                    
                default:
                    
                    if let json = response.result.value as? [String: Any], let data = json.jsonObject("data"), (data.number("max_attempt_phone") == 1 || data.number("max_attempt_ip") == 1 ) {
                        seal.reject(ApiError.unconventionalError(message: json.string("errors") ?? "", errorInfo: data))
                        return
                    }
                    
                    guard let json = response.result.value as? [String: Any], let error = json.string("errors")
                        else {
                        seal.reject(ApiError.unknown)
                            return
                    }
                    seal.reject(ApiError.generalError(message: error))
                }
                
            })
        }
    }
    func smsloginVerify(params: [String:Any]) -> Promise<User> {
        return Promise { seal in
            self.request(CarroUserApiRouter.smsloginVerify(params: params)).checkedResponseJSON(seal.reject, success: self.makeHandlerForSingleResult(seal.fulfill, seal.reject))
        }
    }

    func deleteUser(params: [String:Any]) -> Promise<DeleteUser> {
        
        return Promise { seal in
                        
            guard let loginController = AppServices.shared.find(UserController.self), let token = loginController.userAccessToken?.value  else { return }
            var headers: HTTPHeaders = [
                "Authorization": "Bearer " + token
            ]
            if let appId = AppConfig.appId {
                headers["X-App"] = appId
            }

            Alamofire.request(AppConfig.carroApiBaseUrl+"/mobile/account/deletion", method: .delete, parameters: params, headers: headers).basicCheckedResponseJSON(seal.reject, success: { (statusCode, response) in
                
                switch statusCode {
                case HttpStatusCode.createdOrUpdated.rawValue: fallthrough
                case HttpStatusCode.ok.rawValue:
                    
                    guard let json = response.result.value as? [String: Any], let data = json["data"] as? [String: Any]
                        else {
                        seal.reject(ApiError.generalError(message: "Account authentication failed. Please try again."))
                            return
                    }
                    if let user = DeleteUser(json: data){
                        seal.fulfill(user)
                    }else{
                        seal.reject(ApiError.unknown)
                    }
                default:
                    if let json = response.result.value as? [String: Any], let data = json.jsonObject("data") {
                        seal.reject(ApiError.unconventionalError(message: json.string("errors") ?? "", errorInfo: data))
                        return
                    }
                    guard let json = response.result.value as? [String: Any], let error = json.string("errors")
                        else {
                        seal.reject(ApiError.unknown)
                            return
                    }
                    seal.reject(ApiError.generalError(message: error))
                }
            })
        }
    }

    func fetchUserCountries() -> Promise<[UserCountry]> {
        return Promise { seal in
            self.request(CarroUserApiRouter.userCountries)
                .checkedResponseJSON(seal.reject, success: makeHandlerForArrayResult(seal.fulfill, seal.reject))
        }
    }
}

extension ApiRouter {
    
    var additionalTrackingProperties: [String: Any] {
        
        var params: [String: Any] = [
            "device_os": "ios",
            "device_os_version": UIDevice.current.systemVersion
        ]
        
        if let info = Bundle.main.infoDictionary {
            if let version = info["CFBundleShortVersionString"] as? String {
                params["app_version"] = version
            }
        }
        
        return params
        
    }
    
}

fileprivate enum CarroUserApiRouter: ApiRouter {
    
    case bypass(passCode: String, phone: String?, countryCode: String?)
    case userAccessToken(phoneCode: String, phoneNumber: String, accessToken: String)
    case changeLanguage(languageCode: String)
    case languages
    case smsloginRequest (params: [String:Any])
    case smsloginVerify (params: [String:Any])
    case deleteUser(params: [String:Any])

    case registerFcmToken(token: String)
    case unregisterFcmToken
    case userCountries
    case userInformation(phone: String)
    
    var baseUrlString: String {
        
        switch self {
        case .smsloginRequest, .smsloginVerify, .userInformation:
            return AppConfig.carroApiV2BaseUrl
        default:
            return AppConfig.carroApiBaseUrl
        }
    }
    
    var authorizationFieldValue: String? { //client oauth token
        
        if let type = UserDefaults.standard.string(forKey: AppConfig.clientTokenTypeKey),
           let value = UserDefaults.standard.string(forKey: AppConfig.clientAccessTokenKey) {
            return "\(type) \(value)"
        }
        
        return nil
        
    }
    
    var requestConfiguration: (method: HTTPMethod, route: String, parameters: Parameters?, requiresAuthorization: Bool) {
        switch self {
            
        case let .bypass(passCode, phone, countryCode):
            
            var params = [String: Any]()
            
            params["password"] = passCode
            
            if let `phone` = phone {
                params["email"] = phone
            }
            
            params["include"] = "locale"
        
            return (.post, "mobile/loginByEmail", params, true)
        case let .userAccessToken(phoneCode, phoneNumber, accessToken):

            var params = [String: Any]()

            params["phone_code"] = phoneCode
            params["phone"] = phoneNumber
            params["access_token"] = accessToken

            return (.post, "mobile/firebase_login", params.merging(additionalTrackingProperties, uniquingKeysWith: {$1}), true)
            
        case .languages:
            return (.get, "mobile/config/languages", nil, true)
        case let .changeLanguage(languageCode):
            let params: [String: Any] = ["language": languageCode]
            return (.put, "mobile/account/language", params, true)
            
        case let .registerFcmToken(token):
            
            let params: [String: Any] = [
                "fcm_uuid": token
            ]
            
            return (.post, "mobile/fcm", params.merging(additionalTrackingProperties, uniquingKeysWith: {$1}), true)
            
        case .unregisterFcmToken:
            return (.post, "mobile/fcm/unregister", nil, true)
        case .deleteUser(params: let params):
            return (.delete, "mobile/account/deletion", params, true)
        case let .smsloginRequest(params):
            return (.post, "mobile/sms-login/request", params, true)
        case let .smsloginVerify(params):
            return (.post, "mobile/sms-login/verify", params, true)
            
        case .userCountries:
            return (.get, "mobile/config/countries", nil, false)
            
        case let .userInformation(phone):
            
            var params = [String: Any]()
            params["phone"] = phone
            
            return (.put, "mobile/account/retrieve", params.merging(additionalTrackingProperties, uniquingKeysWith: {$1}), false)
        }
        
    }
    
}
