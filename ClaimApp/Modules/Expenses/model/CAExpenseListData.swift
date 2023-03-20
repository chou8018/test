//
//  CAExpenseListData.swift
//  ClaimApp
//
//  Created by 付耀辉 on 2022/8/29.
//

import UIKit

class CAExpenseListData: CAFormListData, Codable {

    var userId: String {
        guard let userController = AppServices.shared.find(UserController.self) , let user = userController.user else {
            return AppConfig.localUserId ?? ""
        }
        return user.id
    }
    var expenseType: String = "0"
    var vendor: CATextFormItem!
    var selectedDate: CATextFormItem!
    var invoiceNo: CATextFormItem!
    var amountItems = [AmountItem]()
//    var receiptFile: LNUploadImage?
    var receiptFile: String?
    var paymentTo: CADropFormItem!
    var status: String = "1"
    var createDate: String = ""
    var create_at: String {
        if let interval = TimeInterval(createDate) {
            let date = Date(timeIntervalSince1970: interval)
            return date.string(with: .dd_MM_yyyy)
        }
        return ""
    }
    
    var id = "0"

    func itemJson() -> String {
        
        var items = [[String:Any]]()
        for amountItem in amountItems {
            if let dic = amountItem.dicValue() {
                items.append(dic)
            }
        }
        return getJSONStringFromData(obj: items)
    }
    
    
    func dicValue() -> [String:String]? {
        return ["userId":userId,
                "expenseType":expenseType,
                "vendor":vendor.jsonString(),
                "selectedDate":selectedDate.jsonString(),
                "paymentTo":paymentTo.jsonString(),
                "invoiceNo":invoiceNo.jsonString(),
                "receiptFile":receiptFile ?? "",
                "status":status,
                "id":id,
                "createDate":createDate,
                "ItemInfo": itemJson()]
    }
    
    
    static func decodeDic(params: [String:Any]) -> CAExpenseListData? {
        
        guard let expenseType = params["expenseType"] as? String,
              let vendor = params["vendor"] as? String,
              let selectedDate = params["selectedDate"] as? String,
              let paymentTo = params["paymentTo"] as? String,
              let invoiceNo = params["invoiceNo"] as? String,
//              let receiptFile = params["receiptFile"] as? String,
              let status = params["status"] as? String,
              let createDate = params["createDate"] as? String,
              let ItemInfo = params["ItemInfo"] as? String,
              let id = params["id"] as? String
//              let id = params["id"] as? Int
        else {
            return nil
        }
        let listData = CAExpenseListData()
        listData.expenseType = expenseType
        listData.vendor = CATextFormItem.decodeDic(params: getJson(str: vendor))
        listData.selectedDate = CATextFormItem.decodeDic(params: getJson(str: selectedDate))
        listData.paymentTo = CADropFormItem.decodeDropDic(params: getJson(str: paymentTo))
        listData.invoiceNo = CADropFormItem.decodeDic(params: getJson(str: invoiceNo))
        listData.receiptFile = params.string("receiptFile")
        listData.status = status
        listData.createDate = createDate
        listData.id = id
        
        if let arr = getArrayOrDicFromJSONString(jsonString: ItemInfo) as? [[String:Any]] {
            var items = [AmountItem]()
            for info in arr {
                if let item = AmountItem.decodeDic(params: info) {
                    items.append(item)
                }
            }
            listData.amountItems = items
        }
        return listData
    }
}

class CATextFormItem: NSObject, Codable {
    var required = ""
    var title = ""
    var placeholder: String? = nil
    var text = ""
    var selectedId: String?
    
    init(title: String, required: String, placeholder: String, text: String, selectedId: String? = nil) {
        self.required = required
        self.title = title
        self.placeholder = placeholder
        self.text = text
        self.selectedId = selectedId
    }
    
    func jsonString() -> String {
        if let dic = dicValue() {
            return getJSONStringFromData(obj: dic)
        }
        return ""
    }
    
    func dicValue() -> [String:Any]? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            do {
                guard let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else {return nil}
                return dict
            } catch {
                return nil
            }
        } catch  {
            return nil
        }
    }
    
    static func decodeDic(params: [String:Any]) -> CATextFormItem? {
        guard let required = params["required"] as? String,
              let title = params["title"] as? String,
              let placeholder = params["placeholder"] as? String,
              let text = params["text"] as? String
        else {
            return nil
        }
        let item = CATextFormItem(title: title, required: required, placeholder: placeholder, text: text, selectedId: params["selectedId"] as? String)
        return item
    }

}

class CADropFormItem: CATextFormItem {
    var dropDownData:[[String:String]] = []
    var selectedIndex: String = ""
    
    var currentIndex : Int? {
        if let index = Int(selectedIndex), index >= 0 {
            return index
        }
        return nil
    }
    init(title: String, required: String, placeholder: String, text: String, dropDownData: [[String:String]]?, selectedIndex: Int?) {
        super.init(title: title, required: required, placeholder: placeholder, text: text, selectedId: nil)
        self.dropDownData = dropDownData ?? []
        self.selectedIndex = "\(selectedIndex ?? -1)"
    }
    
    override init(title: String, required: String, placeholder: String, text: String, selectedId: String? = nil) {
        super.init(title: title, required: required, placeholder: placeholder, text: text, selectedId: selectedId)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override func dicValue() -> [String:Any]? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            do {
                guard var dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else {return nil}
                dict["dropDownData"] = getJSONStringFromData(obj: dropDownData)
                dict["selectedIndex"] = selectedIndex
                return dict
            } catch {
                return nil
            }
        } catch  {
            return nil
        }
    }

    
    static func decodeDropDic(params: [String:Any]) -> CADropFormItem? {
        guard let required = params["required"] as? String,
              let placeholder = params["placeholder"] as? String,
              let title = params["title"] as? String,
              let text = params["text"] as? String
        else {
            return nil
        }
        let dropDownData = params["dropDownData"] as? String ?? ""
        let item = CADropFormItem(title: title, required: required, placeholder: placeholder, text: text, dropDownData: getArrayOrDicFromJSONString(jsonString: dropDownData) as? [[String:String]], selectedIndex: Int((params["selectedIndex"] as? String) ?? ""))
        item.selectedId = params["selectedId"] as? String
        return item
    }
}

class AmountItem: NSObject, Codable {
    var title = ""
    var isPersonal = ""
    var amount: CATextFormItem!
    var carplate: CADropFormItem!
    var category: CADropFormItem!
    var descrip: CATextFormItem!
    var rowHeight:String = ""
    var currency_code: String = ""
    var country_id: String = ""
    var country_code: String = ""

    func jsonString() -> String {
        if let dic = dicValue() {
            return getJSONStringFromData(obj: dic)
        }
        return ""
    }
    
    func dicValue() -> [String:Any]? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            do {
                guard var dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else {return nil}
                dict["category"] = category.dicValue()
                if currency_code.isEmpty {
                    dict["currency_code"] = AppDataHelper.currencyCode.rawValue
                }
                if country_id.isEmpty {
                    dict["country_id"] = AppDataHelper.user?.country?.id?.stringValue ?? "1"
                }
                if country_code.isEmpty {
                    dict["country_code"] = AppDataHelper.user?.country?.countryCode ?? "1"
                }
                return dict
            } catch {
                return nil
            }
        } catch  {
            return nil
        }
    }
    
    static func decodeDic(params: [String:Any]) -> AmountItem? {
        guard let category = params["category"] as? [String:String],
              let carplate = params["carplate"] as? [String:String],
              let title = params["title"] as? String,
              let amount = params["amount"] as? [String:String],
              let isPersonal = params["isPersonal"] as? String,
              let rowHeight = params.string("rowHeight")
        else {
            return nil
        }
                
        let item = AmountItem()
        item.title = title
        item.isPersonal = isPersonal
        item.rowHeight = rowHeight
        item.category = CADropFormItem.decodeDropDic(params: category)
        item.carplate = CADropFormItem.decodeDropDic(params:  carplate)
        item.amount = CATextFormItem.decodeDic(params:  amount)
        item.descrip = CATextFormItem.decodeDic(params: (params["descrip"] as? [String:String]) ?? [:])
        item.currency_code = params.string("currency_code") ?? ""
        item.country_id = params.lenientNumber("country_id")?.stringValue ?? ""
        item.country_code = params.string("country_code") ?? ""
        return item
    }
}



@objc public class Target: NSObject {
    @objc weak var target : NSObject?
    @objc var selector : Selector?
    
    @objc func perform(object: Any!) {
        target?.perform(selector, with: object)
    }
    
    @objc func perform(object1: Any!, object2: Any!) {
        target?.perform(selector, with: object1, with: object2)
    }
    
    @objc init(target:NSObject?, selector:Selector?) {
        super.init()
        self.selector = selector
        self.target = target
    }
    
}


class CASectionData: NSObject {
    var sectionTitle: String = ""
    var datas = [CAExpenseListData]()
}


func getJson(str: String) -> [String:Any] {
    if let json = getArrayOrDicFromJSONString(jsonString: str) as? [String:Any] {
        return json
    }
    return [:]
}


//将数组/字典 转化为字符串
func getJSONStringFromData(obj:Any) -> String {
    
    if (!JSONSerialization.isValidJSONObject(obj)) {
        print("无法解析出JSONString")
        return ""
    }
    
    if let data : NSData = try? JSONSerialization.data(withJSONObject: obj, options: []) as NSData? {
        if let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue) {
            return JSONString as String
        }
    }
    return ""
}

//将字符串转化为 数组/字典
func getArrayOrDicFromJSONString(jsonString:String) -> Any {
    
    let jsonData:Data = jsonString.data(using: .utf8)!
    
    //可能是字典也可能是数组，再转换类型就好了
    if let info = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) {
        return info
    }
    return ""
}
