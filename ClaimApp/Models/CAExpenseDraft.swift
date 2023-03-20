//
//  CAExpenseDraft.swift
//  ClaimApp
//
//  Created by 付耀辉 on 2022/8/30.
//

import UIKit


class CAExpenseDraft: InitFailable {
    let id: String
    let invoice_date: String
    let due_date: String
    let expense_type: String?
    let invoice_number: String?
    let items: [ExpenseItem]?
    let vendor: CAVendorInfo?
    let payee: CATitleValueItem?
    let currencyCode: CurrencyCode?
    let receipt_files: [LNUploadImage]?
    let status:ExpenseStatus
    let total:TotalAmountInfo?
    var description: String?
    let toggle_copy_item: NSNumber?
    var rowHeight: CGFloat = 0
    var approvedCounts = 0
    let is_automate_data: Bool


    required init?(json: [String : Any]) {
        
        guard let id = json.number("id") else {
            return nil
        }
        if let date = json.string("invoice_date") {
            self.invoice_date = date
        }else{
            self.invoice_date = json.string("expenditure_date") ?? ""
        }
        self.due_date = json.string("due_date") ?? ""
        self.expense_type = json.string("expense_type")
        self.invoice_number = json.string("invoice_number")
        self.id = id.stringValue
        self.vendor = CAVendorInfo(json: json.jsonObject("vendor") ?? [:])
        self.payee = CATitleValueItem(json: json.jsonObject("payee") ?? [:])
        self.total = TotalAmountInfo(json: json.jsonObject("total") ?? [:])
        self.items = ExpenseItem.array(from: json.jsonArray("items") as? [[String:Any]] ?? [[:]])
        self.receipt_files = LNUploadImage.array(from: json.jsonArray("files") as? [[String:Any]] ?? [[:]])
        self.description = json.string("description")
        self.is_automate_data = (json.lenientNumber("is_automate_data") ?? 0) == 1
        self.toggle_copy_item = json.lenientNumber("toggle_copy_item")
        self.status = json.string("status.name").flatMap({  ExpenseStatus(rawValue: $0) }) ?? .notSubmitted

        if let currency_code = self.items?.first?.currency?.currency_code {
            self.currencyCode = CurrencyCode(rawValue: currency_code)
        }else{
            self.currencyCode = nil
        }
        
        var approvedCounts = 0
        if let usedItems = self.items {
            for item in usedItems {
                if item.status == .approved_lark || item.status == .approved {
                    approvedCounts += 1
                }
            }
        }
        self.approvedCounts = approvedCounts
        
        if self.description?.isEmpty == true , self.status == .approved , self.approvedCounts > 0 {
            if self.approvedCounts == self.items?.count {
                self.description = String.localized("expense_detail_head_title_all_approved", comment: "")
            } else {
                self.description = String.localized("expense_detail_head_title_partial_approved", comment: "").replacingOccurrences(of: "{approved_number}", with: "\(self.approvedCounts)")
            }
        }
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


enum CurrencyItemStatus:String {
    case pending = "expense-item-pending"
    case approved = "expense-item-approved"
    case rejected = "expense-item-rejected"
    
    case approved_lark = "expense-item-approved-lark"
    case rejected_lark = "expense-item-rejected-lark"
}

struct ExpenseItem {
    
    let id: NSNumber
    let amount: String?
    let tax_amount: String?
    let gross_amount: String?
    let category: CATitleValueItem?
    let carplate_number: CATitleValueItem?
    let currency: CACurrencyInfo?
    let description: String?
    let expense_id: NSNumber
    let inventory: CATitleValueItem?
    let status: CurrencyItemStatus
}

extension ExpenseItem: InitFailable, ArrayBuildable {
    
    init?(json: [String : Any]) {
        guard let id = json.lenientNumber("id"),
              let expense_id = json.lenientNumber("expense_id") else { return nil }
        
        self.id = id
        self.expense_id = expense_id
        self.amount = json.string("amount")
        self.tax_amount = json.string("tax_amount")
        self.gross_amount = json.string("gross_amount")
        self.category = CATitleValueItem(json: json.jsonObject("category") ?? [:])
        self.carplate_number = CATitleValueItem(json: json.jsonObject("carplate_number") ?? [:])
        self.description = json.string("description")
        self.inventory = CATitleValueItem(json: json.jsonObject("inventory") ?? [:])
        self.currency = CACurrencyInfo(json: json.jsonObject("currency") ?? [:])
        self.status = json.string("status.name").flatMap({  CurrencyItemStatus(rawValue: $0) }) ?? .pending
    }
    
}


struct CATitleValueItem {
    
    let value: NSNumber
    let title: String
    
    var bank: CABankInfo? = nil

}

extension CATitleValueItem: InitFailable, ArrayBuildable {
    
    init?(json: [String : Any]) {
        if let value = json.lenientNumber("value") {
            self.value = value
        } else if let value = json.lenientNumber("id") {
            self.value = value
        } else{
            return nil
        }
        
        if let title = json.string("title") {
            self.title = title
        } else {
            self.title = json.string("name") ?? ""
        }
        
        self.bank = CABankInfo(json: json.jsonObject("bank") ?? [:])
    }
}

struct CAVendorInfo: InitFailable {
    
    let value: NSNumber
    let title: String
    let bank: CABankInfo?

    init?(json: [String : Any]) {
        if let value = json.lenientNumber("value") {
            self.value = value
        }else{
            return nil
        }
        self.title = json.string("title") ?? ""
        
        self.bank = CABankInfo(json: json.jsonObject("bank") ?? [:])
    }
}


struct CABankInfo: InitFailable  {
    
    let id: NSNumber
    let account_no: String?
    var display_name: String?
    
    
    init?(json: [String : Any]) {
        self.id = json.lenientNumber("id") ?? 0
        self.account_no = json.string("account_no")
        self.display_name = json.string("bank.display_name")
        
        if self.display_name == nil {
            self.display_name = json.string("display_name")
        }
    }

}



struct TotalAmountInfo {
    
    let amount: NSNumber
    let tax_amount: NSNumber
    let gross_amount: NSNumber
    let currency_code: String?
}

extension TotalAmountInfo: InitFailable {
    
    init?(json: [String : Any]) {

        self.amount = json.lenientNumber("amount") ?? 0
        self.tax_amount = json.lenientNumber("tax_amount") ?? 0
        self.gross_amount = json.lenientNumber("gross_amount") ?? 0
        self.currency_code = json.string("currency_code")

    }
}
