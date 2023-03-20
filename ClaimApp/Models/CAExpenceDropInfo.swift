//
//  CAExpenceDropInfo.swift
//  ClaimApp
//
//  Created by 付耀辉 on 2022/8/30.
//

import UIKit

struct CAExpenceDropInfo: InitFailable {
    let payees: [DropdownItem]
    let currencies: CACurrency?
    
    init?(json: [String : Any]) {
        
        guard
            let payees = json.jsonArray("payees") as? [[String:Any]] else {
            return nil
        }
        
        var items = [DropdownItem]()
        for payee in payees {
            let item = DropdownItem(id: payee.number("value") ?? 0, name: payee.string("title") ?? "")
            items.append(item)
        }
        self.payees = items
        if let currencies = json.jsonObject("currencies") {
            self.currencies = CACurrency(json: currencies)
        }else{
            self.currencies = nil
        }
    }
}


struct CADropdownItem {
    
    let value: String
    let title: String

    var bank: CABankInfo? = nil
    
    init(value: String, title: String) {
        self.value = value
        self.title = title
    }
}

extension CADropdownItem: InitFailable, ArrayBuildable {
    
    init?(json: [String : Any]) {
        guard let title = json.string("title"), let value = json.lenientNumber("value") else { return nil }
        self.title = title
        self.value = value.stringValue
        
        self.bank = CABankInfo(json: json.jsonObject("bank_account") ?? [:])

    }
}

struct CACurrency: InitFailable {
    let all: [CACurrencyInfo]
    let `default`: CACurrencyInfo?
    
    init?(json: [String : Any]) {
        
        guard let all = json.jsonArray("all") as? [[String:Any]],
              let payees = json.jsonObject("default") else {
            return nil
        }
        
        if let `default` = CACurrencyInfo(json: payees) {
            self.default = `default`
        }else{
            self.default = nil
        }
        self.all = CACurrencyInfo.array(from: all)
    }
}




struct CACurrencyInfo {
    
    let currency_code: String
    let flag: String
    let currency_name: String
    let amount_separator: String
    let decimal_places_count: NSNumber
    let default_amount: String
}

extension CACurrencyInfo: InitFailable, ArrayBuildable {
    
    init?(json: [String : Any]) {
        guard let currency_code = json.string("currency_code"),
              let flag = json.string("flag"),
              let currency_name = json.string("currency_name"),
              let amount_separator = json.string("amount_separator"),
              let decimal_places_count = json.lenientNumber("decimal_places_count"),
              let default_amount = json.string("default_amount") else { return nil }
        self.currency_code = currency_code
        self.flag = flag
        self.currency_name = currency_name
        self.amount_separator = amount_separator
        self.decimal_places_count = decimal_places_count
        self.default_amount = default_amount
    }
}
