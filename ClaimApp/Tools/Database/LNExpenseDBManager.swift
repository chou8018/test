//
//  LNExpenseDBManager.swift
//  ClaimApp
//
//  Created by 付耀辉 on 2022/8/29.
//

import UIKit

class LNExpenseDBManager: NSObject {
    
    static let kExpenseTableName = "kExpenseFormTable"
    
    static func checkExpenseTable() {
        let isExist = LNFMDBManager.default.isExsit(tableName: kExpenseTableName)
        if !isExist {
            let result = LNFMDBManager.default.executeQueryFormDataBase(sql:"create table \(kExpenseTableName)(userId text, expenseType text, vendor text, selectedDate text, receiptFile text, status text, createDate text, ItemInfo text, paymentTo text, invoiceNo text, id text)")
            LNDebugPrint(item: result)
        }
    }
    
    
    static func insertExpenseData(data: CAExpenseListData) -> Bool {
        checkExpenseTable()
        
        let sql = "insert into \(kExpenseTableName) VALUES(:userId, :expenseType, :vendor, :selectedDate, :receiptFile, :status, :createDate, :ItemInfo, :paymentTo, :invoiceNo, :id)"
        
        if var dic = data.dicValue() {
            dic["createDate"] = "\(Date().timeIntervalSince1970)"
            let flag = LNFMDBManager.default.updateStatmes(sql: sql, params: dic)
            if flag {
                LNDebugPrint(item: "save Expense Data succeed")
                return true
            }
            return false
        }
        LNDebugPrint(item: "save Expense Data failed")
        return false
    }
    
    static func updateExpenseData(data: CAExpenseListData) -> Bool {
        checkExpenseTable()
        let sql = "update \(kExpenseTableName) SET userId = '\(data.userId)', expenseType = '\(data.expenseType)', vendor = '\(data.vendor.jsonString())', selectedDate = '\(data.selectedDate.jsonString())', receiptFile = '\(data.receiptFile ?? "")', status = '\(data.status)', createDate = '\(data.createDate)',ItemInfo = '\(data.itemJson())', paymentTo = '\(data.paymentTo.jsonString())', invoiceNo = '\(data.invoiceNo.jsonString())', id = '\(data.id)' where createDate = '\(data.createDate)'"
        let flag = LNFMDBManager.default.executeQueryFormDataBase(sql: sql)
        if flag {
            LNDebugPrint(item: "update Expense Data succeed")
        }else{
            LNDebugPrint(item: "update Expense Data failed")
        }
        return flag
    }
    
    
    static func deleteExpenceData(data: CAExpenseListData)  -> Bool {
        checkExpenseTable()
        let sql = "DELETE FROM \(kExpenseTableName) where createDate = '\(data.createDate)'"
//        let sql = "DELETE FROM \(kExpenseTableName) where id = '\(data.id)'"
        let flag = LNFMDBManager.default.executeQueryFormDataBase(sql: sql)
        if flag {
            LNDebugPrint(item: "delete Expense Data succeed")
        }else{
            LNDebugPrint(item: "delete Expense Data failed")
        }
        return flag
    }
    
    
    static func getExpenseData(expenseType: String) -> [CAExpenseListData] {
        
        checkExpenseTable()
        var datas = [CAExpenseListData]()
        
        guard let userController = AppServices.shared.find(UserController.self)  else {
            return []
        }
        var userId = ""
        if let uId = userController.user?.id {
            userId = uId
        } else {
            userId = AppConfig.localUserId ?? ""
        }
        
        if userId.isEmpty {
            return []
        }
        
        let resultArr = LNFMDBManager.default.selectData(sql: "SELECT *FROM \(kExpenseTableName) where userId = '\(userId)' and expenseType = '\(expenseType)'  order by createDate asc")
        LNDebugPrint(item: "get \(resultArr.count) datas")
        for obj in resultArr {
            if let dic = obj as? [String:Any] {
                if let dataDic = CAExpenseListData.decodeDic(params: dic) {
                    datas.append(dataDic)
                }
            }
        }
        return datas
    }
}
