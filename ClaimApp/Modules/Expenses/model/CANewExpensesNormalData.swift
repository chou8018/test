//
//  CANewExpensesNormalData.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/27.
//

import UIKit


class CAFormData: NSObject {
    var isNecessary = false
}

class CANewExpensesNormalData: CAFormData {
    var title: String?
    var placeholder: String?
    var icon: UIImage?
    var text: String?
    
    init(title: String? ,placeholder: String? , icon: UIImage? ,text: String?) {
        self.title = title
        self.placeholder = placeholder
        self.icon = icon
        self.text = text
    }
}

class CANewExpensesAmountData: CAFormData {
    var amount: NSNumber?
    var dec: String?
    var category: String?
    var invoiceNo: String?
    
    init(amount: NSNumber? ,dec: String?) {
        self.amount = amount
        self.dec = dec
    }
}
