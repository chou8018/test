//
//  LNSellFlowClient.swift
//  dealers
//
//  Created by 付耀辉 on 2021/9/28.
//  Copyright © 2021 Trusty Cars. All rights reserved.
//

import UIKit
import PromiseKit
import Alamofire

protocol SellFlowApiClient {
    func fecthLeadListWithType(type: String, page: Int) -> Promise<[LNListMainData]>
    func uploadLeadImage(url: String, params:[String:Any]) -> Promise<LNUploadImage>
    func deleteFormImage(params:[String:Any]) -> Promise<LNUploadImage>
    func fecthSuggestions(params:[String:Any]) -> Promise<[CADropdownItem]>
    func formOptions(params:[String:Any]) -> Promise<CAExpenceDropInfo>
    func submitForm(params:[String:Any], id:String) -> Promise<LNUploadImage>
    func fecthDraftDetail(id:String) -> Promise<CAExpenseDraft>
    func deleteDraft(id:String) -> Promise<Bool>
    func fetchCity(countryCode: CountryCode) -> Promise<[CATitleValueItem]>
    func createProfile(profile: UserProfile) -> Promise<Bool>
    func requestOTPEmail(email: String) -> Promise<Bool>
    func resetPasswordOTP(email: String,otp: String) -> Promise<String>
    func resetPassword(email: String,pwd: String , confirmPwd: String ,token: String) -> Promise<Bool>
    func fetchUserInformation(phone: String) -> Promise<User>

}

class LNSellFlowApiClient:SellFlowApiClient, ApiClient {
    
    func fecthLeadListWithType(type: String, page: Int) -> Promise<[LNListMainData]> {
        return Promise { seal in
            self.request(LNSellFlowApiRouter.leadListWithType(type: type, page: page)).checkedResponseJSON(seal.reject, success: self.makeHandlerForArrayResult(seal.fulfill, seal.reject))
        }
    }
    
    
    func uploadLeadImage(url: String, params:[String:Any]) -> Promise<LNUploadImage> {
        return Promise { seal in
            self.request(LNSellFlowApiRouter.uploadLeadImage(url: url, params: params)).checkedResponseJSON(seal.reject, success: self.makeHandlerForSingleResult(seal.fulfill, seal.reject))
        }
    }
    
    func deleteFormImage(params:[String:Any]) -> Promise<LNUploadImage> {
        return Promise { seal in
            self.request(LNSellFlowApiRouter.deleteFormImage(params: params)).checkedResponseJSON(seal.reject, success: self.makeHandlerForSingleResult(seal.fulfill, seal.reject))
        }
    }
    
    func formOptions(params:[String:Any]) -> Promise<CAExpenceDropInfo> {
        return Promise { seal in
            self.request(LNSellFlowApiRouter.formOptions(params: params)).checkedResponseJSON(seal.reject, success: self.makeHandlerForSingleResult(seal.fulfill, seal.reject))
        }
    }
    
    func fecthSuggestions(params:[String:Any]) -> Promise<[CADropdownItem]> {
        return Promise { seal in
            self.request(LNSellFlowApiRouter.fecthSuggestions(params: params)).checkedResponseJSON(seal.reject, success: self.makeHandlerForArrayResult(seal.fulfill, seal.reject))
        }
    }
    
    func submitForm(params:[String:Any], id:String) -> Promise<LNUploadImage> {
        return Promise { seal in
            self.request(LNSellFlowApiRouter.submitForm(params: params, id: id)).checkedResponseJSON(seal.reject, success: self.makeHandlerForSingleResult(seal.fulfill, seal.reject))
        }
    }
    
    func fecthDraftDetail(id:String) -> Promise<CAExpenseDraft> {
        return Promise { seal in
            self.request(LNSellFlowApiRouter.fecthDraftDetail(id: id)).checkedResponseJSON(seal.reject, success: self.makeHandlerForSingleResult(seal.fulfill, seal.reject))
        }
    }
    
    func deleteDraft(id:String) -> Promise<Bool> {
        return Promise { seal in
            
            self.request(LNSellFlowApiRouter.deleteDraft(id: id)).checkedResponseJSON(seal.reject, success: { (statusCode, response) in
                
                switch statusCode {
                    
                case HttpStatusCode.ok.rawValue: fallthrough
                case HttpStatusCode.createdOrUpdated.rawValue:
                    
                    seal.fulfill(true)
                    
                default:
                    seal.reject(ApiError.unknown)
                }
                
            })
        }
    }
    
    func fetchCity(countryCode: CountryCode) -> Promise<[CATitleValueItem]> {
        return Promise { seal in
            self.request(LNSellFlowApiRouter.fetchCity(CountryCode: countryCode))
                .checkedResponseJSON(seal.reject, success: makeHandlerForArrayResult(seal.fulfill, seal.reject))
        }
    }
    
    func createProfile(profile: UserProfile) -> Promise<Bool> {
        return Promise { seal in
            
            self.request(LNSellFlowApiRouter.createProfile(profile: profile)).checkedResponseJSON(seal.reject, success: { (statusCode, response) in
                
                switch statusCode {
                    
                case HttpStatusCode.ok.rawValue: fallthrough
                case HttpStatusCode.createdOrUpdated.rawValue:
                    
                    seal.fulfill(true)
                    
                default:
                    seal.reject(ApiError.unknown)
                }
                
            })
        }
    }
    
    func requestOTPEmail(email: String) -> Promise<Bool> {
        return Promise { seal in
            
            self.request(LNSellFlowApiRouter.requestOTPEmail(email: email)).checkedResponseJSON(seal.reject, success: { (statusCode, response) in
                
                switch statusCode {
                    
                case HttpStatusCode.ok.rawValue: fallthrough
                case HttpStatusCode.createdOrUpdated.rawValue:
                    
                    seal.fulfill(true)
                    
                default:
                    seal.reject(ApiError.unknown)
                }
                
            })
        }
    }
    
    func resetPasswordOTP(email: String,otp: String) -> Promise<String> {
        return Promise { seal in
            
            self.request(LNSellFlowApiRouter.resetPasswordOTP(email: email, otp: otp)).checkedResponseJSON(seal.reject){
                (statusCode, response) in
                
                switch statusCode {
                
                case HttpStatusCode.createdOrUpdated.rawValue: fallthrough
                case HttpStatusCode.ok.rawValue:
                    
                    guard
                        let json = response.result.value as? [String: Any],
                        let dataJson = json["data"] as? [String: Any],
                        let token = dataJson["token"] as? String
                    else {
                        seal.reject(ApiError.unknown)
                        return
                    }
                    
                    seal.fulfill("\(token)")
                    
                default:
                    seal.reject(ApiError.unknown)
                }
                
            }
        }
    }
    
    func resetPassword(email: String,pwd: String , confirmPwd: String ,token: String) -> Promise<Bool> {
        return Promise { seal in
            
            self.request(LNSellFlowApiRouter.resetPassword(email: email, pwd: pwd, confirmPwd: confirmPwd, token: token)).checkedResponseJSON(seal.reject, success: { (statusCode, response) in
                
                switch statusCode {
                    
                case HttpStatusCode.ok.rawValue: fallthrough
                case HttpStatusCode.createdOrUpdated.rawValue:
                    
                    seal.fulfill(true)
                    
                default:
                    seal.reject(ApiError.unknown)
                }
                
            })
        }
    }
    
    func fetchUserInformation(phone: String) -> Promise<User> {
        return Promise { seal in
            self.request(LNSellFlowApiRouter.userInformation(phone: phone)).checkedResponseJSON(seal.reject, success: self.makeHandlerForSingleResult(seal.fulfill, seal.reject))
        }
    }
    
    enum LNSellFlowApiRouter: CarroApiRouter {
        
        case leadListWithType(type: String, page: Int)
        case uploadLeadImage(url: String, params:[String:Any])
        case formOptions(params:[String:Any])
        case submitForm(params:[String:Any], id:String)
        case deleteFormImage(params:[String:Any])
        case fecthSuggestions(params:[String:Any])
        case fecthDraftDetail(id: String)
        case deleteDraft(id: String)
        case fetchCity(CountryCode: CountryCode)
        case createProfile(profile: UserProfile)
        case requestOTPEmail(email: String)
        case resetPasswordOTP(email: String, otp: String)
        case resetPassword(email: String, pwd: String ,confirmPwd: String , token: String)
        case userInformation(phone: String)

        var baseUrlString: String {
            return AppConfig.carroApiV2BaseUrl
        }
        
        var requestConfiguration: (method: HTTPMethod, route: String, parameters: Parameters?, requiresAuthorization: Bool) {
            
            switch self {
            case let .leadListWithType(type, page):
                var params = [String: Any]()
                params["expense_type"] = type
                return (.get, "mobile/expense/expenses", params, true)
                
            case let .uploadLeadImage(url, params):
                return (.post, "mobile/expense/expense-forms/\(url)/files", params, true)
            case let .formOptions(params):
                return (.get, "mobile/expense/expense-forms/options", params, true)
            case let .fecthSuggestions(params):
                return (.get, "mobile/expense/expense-forms/suggestions", params, true)
            case .submitForm(let params, _):
                return (.post, "mobile/expense/expense-forms/submit-claim", params, true)
            case .deleteFormImage(let params):
                return (.delete, "mobile/expense/expense-forms/\(params["id"] ?? "")/files/\(params["imageId"] ?? "")", params, true)
            case .fecthDraftDetail(id: let id):
                return (.get, "mobile/expense/\(id)", nil, true)
            case .deleteDraft(id: let id):
                return (.delete, "mobile/expense/\(id)", nil, true)
                
            case .fetchCity(let countryCode):
                var params = [String: Any]()
                params["country_code"] = countryCode.rawValue
                return (.get, "mobile/config/cities-by-country-code", params, true)
                
            case .createProfile(let userProfile):
                
                let params: [String: Any] = ["name": userProfile.name ?? "",
                                             "email": userProfile.email ?? "",
                                             "password": userProfile.password ?? "",
                                             "password_confirmation": userProfile.password_confirmation ?? "",
                                             "country_code": userProfile.country_code ?? "",
                                             "city_id": userProfile.city_id ?? "",
                                             "phone": userProfile.phone ?? ""]
                
                return (.post, "mobile/account/profile", params, true)
                
            case .requestOTPEmail(let email):
                let params: [String: Any] = ["email": email]
                return (.post, "mobile/account/request-otp-email", params, true)
                
            case .resetPasswordOTP(let email, let otp):
                let params: [String: Any] = ["email": email,"otp_code":otp]
                
                return (.post, "mobile/account/request-reset-password-otp", params, true)
                
            case let .resetPassword(email, pwd , confirmPwd, token):
                let params: [String: Any] = ["email": email,
                                             "token": token,
                                             "password": pwd,
                                             "password_confirmation":confirmPwd]
                return (.post, "mobile/account/reset-password", params, true)
            case let .userInformation(phone):
                
                var params = [String: Any]()
                params["phone"] = phone
                
                return (.put, "mobile/account/retrieve", params.merging(additionalTrackingProperties, uniquingKeysWith: {$1}), true)
            
            }
        }
    }
}


