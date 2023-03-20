//
//  CAListPresenter.swift
//  dealers
//
//  Created by 付耀辉 on 2021/2/26.
//  Copyright © 2021 Trusty Cars. All rights reserved.
//

import UIKit

protocol CAListPresenterDelegate: AnyObject {
    
    func handleListDidLoad()
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func startRefreshing()
    func stopRefreshing()
    func hideErrorOrEmptyState()
    func willLoadsList()
    func showEmptyState()
    func showErrorState(error: Error)

}

class CAListPresenter {
    
    public var dataSource = [LNListMainData]()
    weak var delegate: CAListPresenterDelegate?
    private var page = 1
    private var haveNextPage = true

    private var isRefreshing: Bool = false {
        didSet {
            if !isRefreshing {
                delegate?.stopRefreshing()
            } else {
                delegate?.startRefreshing()
            }
        }
    }
    
    fileprivate var loadState: LoadState = .notLoaded {
        didSet {
            
            delegate?.hideErrorOrEmptyState()
            
            switch loadState {
            case .loading where isRefreshing:
                ()
            case .loading, .loadingMore:
                delegate?.showLoadingIndicator()
                
            case .loaded:
            
                isRefreshing = false
                delegate?.hideLoadingIndicator()
                delegate?.handleListDidLoad()
                
                if dataSource.isEmpty {
                    delegate?.showEmptyState()
                }
                
            case .error(let error):
                isRefreshing = false
                delegate?.hideLoadingIndicator()
                
                delegate?.showErrorState(error: error)
                
            case .notLoaded: fallthrough
            default:
                isRefreshing = false
                delegate?.hideLoadingIndicator()
            }
            
        }
    }
                
    func loadList(type: CAExpensesType) {
        isRefreshing = false
        haveNextPage = true
        self.page = 1
        loadListWithType(type: type)
    }
    
    
    func refreshList(type: CAExpensesType) {
        haveNextPage = true
        self.page = 1
        loadListWithType(type: type)
    }

    private func loadListWithType(type: CAExpensesType) {
        if !haveNextPage {
            return
        }
        delegate?.willLoadsList()
        self.loadState = .loading
        
        let sellFlowController: SellFlowController! = AppServices.shared.find(SellFlowController.self)
        var typeString = ""
        if type == .personal {
            typeString = "personal"
        } else {
            typeString = "inventory"
        }
        sellFlowController.fecthLeadListWithType(type: typeString, page: self.page).done { [weak self] list -> Void in
            
            guard let self = self else { return }
            if self.page == 1 {
                self.dataSource = list
            }else{
                self.dataSource.append(contentsOf: list)
            }
//            self.readListDataFromDataBase(type: type)
            self.loadState = .loaded
            if list.count < 20 {
                self.haveNextPage = false
            }else{
                self.page += 1
            }
            
        }.catch { [weak self] error in
            guard self != nil else { return }
            self?.loadState = .error(error)
        }
    }
    
    func loadMoreListWithType(type: CAExpensesType) {
        loadListWithType(type: type)
    }
    
    private func readListDataFromDataBase(type: CAExpensesType) {
//        self.sectionDatas.removeAll()
        
        let listDatas = LNExpenseDBManager.getExpenseData(expenseType: "\(type.rawValue)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        for listData in listDatas {
            if let interval = TimeInterval(listData.createDate) {
                
                let date = Date(timeIntervalSince1970: interval)
                let dateStr = dateFormatter.string(from: date)
                
                if let dic = containDateDic(dateStr: dateStr) {
                    var datas = dic.items
                    datas?.insert(listData, at: 0)
                    dic.items = datas
                }else{
                    let data = LNListMainData(date: dateStr, items: [listData])
                    self.dataSource.append(data)
                }
            }
        }
        
        self.dataSource = self.dataSource.sorted { data1, data2 in
            
            guard let interval1 = Date.init(string: data1.date ?? "", formatter: dateFormatter)?.timeIntervalSince1970,
                  let interval2 = Date.init(string: data2.date ?? "", formatter: dateFormatter)?.timeIntervalSince1970 else {
                return false
            }
            return interval1 > interval2
        }
    }
    
    
    func containDateDic(dateStr: String) -> LNListMainData? {
        for data in self.dataSource {
            if data.date == dateStr {
                return data
            }
        }
        return nil
    }
}
