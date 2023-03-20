//
//  LNFMDBManager.swift
//  ClaimApp
//
//  Created by 付耀辉 on 2022/8/29.
//

import UIKit
import FMDB

class LNFMDBManager: NSObject {
    let lock = NSLock()
    let sqliteName = "WWZLLocalDataBase"
    var dataBaseQueue : FMDatabaseQueue?
    static let `default` = LNFMDBManager()
    
    
    lazy var fmdb: FMDatabase = {
        let dataBasePath = NSHomeDirectory() + "/Documents/\(sqliteName).sqlite"
        print("dataPath = \(dataBasePath)")
        let fileManager = FileManager.default
        let sqlitePath = Bundle.main.path(forResource: sqliteName, ofType: "sqlite") ?? ""
        if !fileManager.fileExists(atPath: dataBasePath) {
            do {
                try fileManager.copyItem(atPath: sqlitePath, toPath: dataBasePath)
                LNDebugPrint(item: "The database copy succeeded")
            } catch {
                LNDebugPrint(item: "The database copy failed")
            }
        }else{
            LNDebugPrint(item: "The database already exists")
        }
        
        let _fmdb = FMDatabase.init(path: dataBasePath)
        if dataBaseQueue == nil {
            dataBaseQueue = FMDatabaseQueue.init(path: dataBasePath)
        }
        
        if _fmdb.open() {
            LNDebugPrint(item: "open succeed")
        }else{
            LNDebugPrint(item: "open failed")
            _fmdb.close()
        }
        
        return _fmdb
    }()
    
    func closeDataBase() {
        fmdb.close()
    }
    
    func beginTransaction() {
        fmdb.beginTransaction()
    }
    
    func commitTransaction() {
        fmdb.commit()
    }
    
    //Mark:- Query datas
    func selectData(sql: String) -> [Any] {
        openDBAndLock()
        var arr = [Any]()
        do {
            let result = try fmdb.executeQuery(sql, values: [])
            while result.next() {
                arr.append(result.resultDictionary as Any)
            }
        } catch  {
        }
        closeDBAndUnlock()
        return arr
    }
    
    func executeQueryFormDataBase(sql: String) -> Bool {
        openDBAndLock()
        let result = fmdb.executeStatements(sql)
        closeDBAndUnlock()
        return result
    }
    
    func isExsit(tableName: String) -> Bool {

        openDBAndLock()
        let rs = try? fmdb.executeQuery("select count(*) as 'count' from sqlite_master where type ='table' and name = ?", values: [tableName])
        while rs?.next() ?? false {
            let count = rs?.int(forColumn: "count") ?? 0
            closeDBAndUnlock()
            if count <= 0 {
                return false
            }else{
                return true
            }
        }
        closeDBAndUnlock()
        return false
    }    
    
    
    func updateStatmes(sql: String, params: [String:Any]) -> Bool {
        openDBAndLock()
        let result = fmdb.executeUpdate(sql, withParameterDictionary: params)
        closeDBAndUnlock()
        return result
    }
    
    private func openDBAndLock() {
        lock.lock()
        if !fmdb.isOpen {
            fmdb.open()
        }
    }
    
    private func closeDBAndUnlock() {
        fmdb.close()
        lock.unlock()
    }
    
}

var stopDebugPrint = false
//调试模式输出
public func LNDebugPrint<T>(item message:T, file:String = #file, function:String = #function,line:Int = #line) {
    
    if stopDebugPrint {
        return
    }
    #if DEBUG
    //获取文件名
    let fileName = (file as NSString).lastPathComponent
    //打印日志内容
    print("\(fileName):\(line) | 🐴🐴🐴🐴🐴🐴 \(message)")
    #endif
}
