//
//  LNOfferInfo.swift
//  dealers
//
//  Created by 付耀辉 on 2021/9/17.
//  Copyright © 2021 Trusty Cars. All rights reserved.
//

import UIKit

class CAFormListData: NSObject {
    
}
enum ExpenseStatus:String {
    case notSubmitted = "expense-draft"
    case submitted = "expense-submitted"
    case approved = "expense-approved"
    case reimbursed = "expense-reimbursed"
    case rejected = "expense-rejected"
}

class LNListData:CAFormListData, InitFailable ,ArrayBuildable{
    
    let id: NSNumber
    let vendor_name: String?
    let invoice_number: NSNumber?
    let expense_type: String?
    let gross_amount: String?
    let include_tax: Bool
    let created_at: String?
    let invoice_date: String?
    let submitted_month: String?
    let receipt_files: [LNUploadImage]?
    let currencyCode: CurrencyCode?
    let status:ExpenseStatus
    
    required init?(json: [String : Any]) {
        guard let id = json.number("id") else {
            return nil
        }
        self.id = id
        self.vendor_name = json.string("vendor_name")
        self.invoice_number = json.number("invoice_number")
        self.expense_type = json.string("expense_type")
        self.gross_amount = json.string("gross_amount")
        self.include_tax = (json.lenientNumber("include_tax") ?? 0) == 1
        self.created_at = json.string("created_at")
        self.invoice_date = json.string("invoice_date")
        self.submitted_month = json.string("submitted_month")

        self.receipt_files = LNUploadImage.array(from: json.jsonArray("files") as? [[String:Any]] ?? [[:]])
        
        if let currencyCode = json.string("currency_code").flatMap({ CurrencyCode(rawValue: $0) }) {
            self.currencyCode = currencyCode
        } else {
            self.currencyCode = nil
        }
        self.status = json.string("status.name").flatMap({  ExpenseStatus(rawValue: $0) }) ?? .notSubmitted
    }
    
    func submitTitleAndTitleBackgroundColor() -> (String?, UIColor) {
        
        switch status {
        case .notSubmitted:
            return (String.localized("my_expenses_title_status_not_submitted", comment: ""), UIColor.hexColorWithAlpha(color: "#6E7882"))
        case .submitted:
            return (String.localized("my_expenses_title_status_submitted", comment: ""), UIColor.hexColorWithAlpha(color: "#FBBD43"))
        case .approved:
            return (String.localized("my_expenses_title_status_approved", comment: ""), UIColor.hexColorWithAlpha(color: "#4082FF"))
        case .reimbursed:
            return (String.localized("my_expenses_title_status_reimbursed", comment: ""), UIColor.hexColorWithAlpha(color: "#31C891"))
        case .rejected:
            return (String.localized("my_expenses_title_status_rejected", comment: ""), UIColor.hexColorWithAlpha(color: "#F54165"))
        }
    }
    
}

class LNListMainData:NSObject, InitFailable, ArrayBuildable {
    
    var date: String? = nil
    var items: [CAFormListData]?
    var draftTitle: String? = nil
    
    var dateTitle: String? {
        DateFormatter.MMMMyyyy.date(from: date ?? "")?.string(with: DateFormatter.MMMyyyy) ?? ""
    }
    
    
    var lastMonthOfCurrentYear: String {
        
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyy"
        let dateYear = Date().string(with: dateF)
        return "Dec \(dateYear)"
    }

    
    var currentDate: Date! {
        DateFormatter.MMMMyyyy.date(from: date ?? "") ?? Date()
    }
    
    required init?(json: [String : Any]) {
        self.date = json.string("date")
        self.draftTitle = json.string("title")

        if let items = json.jsonArray("expenses") as? [[String: Any]] {
            self.items = LNListData.array(from: items)
        }
    }
    
    init(date: String, items:[CAFormListData]) {
        super.init()
        self.date = date
        self.items = items
    }
}





