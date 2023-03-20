//
//  LNSellFlowController.swift
//  dealers
//
//  Created by 付耀辉 on 2021/9/28.
//  Copyright © 2021 Trusty Cars. All rights reserved.
//

import PromiseKit
import ObjectiveC
import Alamofire

let FormTextDidChanged = Notification.Name(rawValue: "FormTextDidChanged")

protocol SellFlowController {
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

class LNSellFlowController: SellFlowController {
    
    var sellFlowClient: SellFlowApiClient!

    func fecthLeadListWithType(type: String, page: Int) -> Promise<[LNListMainData]> {
        return sellFlowClient.fecthLeadListWithType(type: type, page: page)
    }
    
    func uploadLeadImage(url: String, params:[String:Any]) -> Promise<LNUploadImage> {
        return sellFlowClient.uploadLeadImage(url: url, params: params)
    }
    
    func deleteFormImage(params:[String:Any]) -> Promise<LNUploadImage> {
        return sellFlowClient.deleteFormImage(params: params)
    }

    
    func formOptions(params:[String:Any]) -> Promise<CAExpenceDropInfo> {
        return sellFlowClient.formOptions(params: params)
    }
        
    func fecthSuggestions(params:[String:Any]) -> Promise<[CADropdownItem]> {
        return sellFlowClient.fecthSuggestions(params: params)
    }


    func submitForm(params:[String:Any], id:String) -> Promise<LNUploadImage> {
        return sellFlowClient.submitForm(params: params, id: id)
    }
    
    func fecthDraftDetail(id:String) -> Promise<CAExpenseDraft> {
        return sellFlowClient.fecthDraftDetail(id: id)
    }
    
    func deleteDraft(id: String) -> Promise<Bool> {
        return sellFlowClient.deleteDraft(id: id)
    }
    
    func fetchCity(countryCode: CountryCode) -> Promise<[CATitleValueItem]> {
        return sellFlowClient.fetchCity(countryCode: countryCode)
    }
    
    func createProfile(profile: UserProfile) -> Promise<Bool> {
        return sellFlowClient.createProfile(profile: profile)
    }
    
    func requestOTPEmail(email: String) -> Promise<Bool> {
        return sellFlowClient.requestOTPEmail(email: email)
    }
    
    func resetPasswordOTP(email: String,otp: String) -> Promise<String> {
        return sellFlowClient.resetPasswordOTP(email: email, otp: otp)
    }
    
    func resetPassword(email: String,pwd: String , confirmPwd: String ,token: String) -> Promise<Bool> {
        return sellFlowClient.resetPassword(email: email,pwd: pwd , confirmPwd: confirmPwd ,token: token)
    }
    
    func fetchUserInformation(phone: String) -> Promise<User> {
        return sellFlowClient.fetchUserInformation(phone: phone)
    }
}
