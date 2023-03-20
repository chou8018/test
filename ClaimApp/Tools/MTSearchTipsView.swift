//
//  MTSearchTipsView.swift
//  dealers
//
//  Created by 付耀辉 on 2021/5/17.
//  Copyright © 2021 Trusty Cars. All rights reserved.
//

import UIKit
import PromiseKit

class MTSearchTipsView: UIView {
    private var target: Target?
    private var selectedIndex = 0
    private var maxCount = 5

    var keyword : String {
        searchText ?? ""
    }
        
    private var isEmpty = false {
        didSet {
            if isEmpty {
                self.mainTableView.tableFooterView = footerView
            }else{
                self.mainTableView.tableFooterView = nil
            }
        }
    }
    
    var datas = [CADropdownItem]() {
        didSet{
            filterDatas = datas
            mainTableView.reloadData()
        }
    }
    private var filterDatas = [CADropdownItem]()

    fileprivate let identifier = "UITableViewIdentifier";
    fileprivate var mainTableView : UITableView!
    private var rowHeight:CGFloat = 42
    
    private lazy var footerView: UIView = {
        let footer = UIView.init(frame: CGRect(x: 0, y: 0, width: self.width, height: 36))
//        footer.backgroundColor = .red
        let label = UILabel(frame: CGRect(x: 16, y: 8, width: self.width-32, height: footer.height-16))
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.text = "Sorry, we don't have this car now."
        label.numberOfLines = 0
        footer.addSubview(label)
        return footer
    }()
    
    public func reset(searchText:String, expensesType: CAExpensesType, include:CAIncludeType) {
        
        self.searchText = searchText
        
        func searchTextPurifier() {
            if let sText = self.searchText {
                if sText.hasSuffix(" ") {
                    let endIndex = sText.index(sText.endIndex, offsetBy: -1)
                    self.searchText = String(searchText[..<endIndex])
                }
                if self.searchText?.hasSuffix(" ") ?? false {
                    searchTextPurifier()
                }
            }
        }
        
        searchTextPurifier()
        
        if searchText.count < 3 {return}
        guard let view = self.superview, let vc = viewContainingController() else {return}
        let userController: SellFlowController! = AppServices.shared.find(SellFlowController.self)
        userController.fecthSuggestions(params: ["expense_type": expensesType.rawValue, "include": include.rawValue, "query": searchText]).done { [weak self] infos in
            guard let self = self else { return }
            self.filterDatas = infos
        }.catch { (error) in
            UIAlertController.showErrorMessage(error: error, from: vc)
        }.finally { [weak self] in
            guard let self = self else { return }
            LoadingView.hideLoadingViewInView(view: view)
            
            self.isEmpty = self.filterDatas.count == 0
            if self.filterDatas.count < self.maxCount {
                if self.isEmpty {
                    self.mainTableView.snp.updateConstraints { (ls) in
                        ls.height.equalTo(self.rowHeight)
                    }
                }else{
                    self.mainTableView.snp.updateConstraints { (ls) in
                        ls.height.equalTo(self.rowHeight*CGFloat(self.filterDatas.count))
                    }
                }
                self.show()
            }else{
                self.mainTableView.snp.updateConstraints { (ls) in
                    ls.height.equalTo(self.rowHeight*CGFloat(self.maxCount))
                }
                self.show()
            }
            self.mainTableView.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            
        }
    }
    
    init(frame:CGRect, target:Target?) {
        super.init(frame: frame)
        self.target = target
        configSubViews()
    }
    
    fileprivate func configSubViews() {
        self.height = rowHeight*CGFloat(maxCount)
        backgroundColor = .white
        mainTableView = UITableView.init(frame: bounds, style: .plain)
        mainTableView.estimatedRowHeight = 100
        mainTableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        mainTableView.delegate = self
        mainTableView.separatorColor = .clear
        mainTableView.dataSource = self
        mainTableView.tableFooterView = UIView()
        mainTableView.cornerRadius = 5
        addSubview(mainTableView)
        
        mainTableView.snp.makeConstraints { (ls) in
            ls.left.right.equalToSuperview()
            ls.top.equalToSuperview().priority(100)
            ls.bottom.equalToSuperview().priority(101)
            ls.height.equalTo(rowHeight*CGFloat(maxCount))
        }
        
    }
    
    func hide(isFirst: Bool = false) {
        if self.alpha == 0 {
            return
        }
        if isFirst {
            self.mainTableView.snp.updateConstraints { (ls) in
                ls.height.equalTo(0)
            }
            self.alpha = 0
        } else {
            UIView.animate(withDuration: 0.15) {
                self.mainTableView.snp.updateConstraints { (ls) in
                    ls.height.equalTo(0)
                }
            } completion: { (_) in
                self.alpha = 0
            }
        }

        layoutIfNeeded()
        self.filterDatas.removeAll()
        self.mainTableView.reloadData()
    }
    
    func show() {
        superview?.bringSubviewToFront(self)
        UIView.animate(withDuration: 0.15) {
            if self.filterDatas.count < self.maxCount {
                self.mainTableView.snp.updateConstraints { (ls) in
                    ls.height.equalTo(self.rowHeight*CGFloat(self.filterDatas.count))
                }
            }else{
                self.mainTableView.snp.updateConstraints { (ls) in
                    ls.height.equalTo(self.rowHeight*CGFloat(self.maxCount))
                }
            }
        } completion: { (_) in
            self.alpha = 1
        }
        layoutIfNeeded()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MTSearchTipsView:UITableViewDelegate, UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if filterDatas.count > indexPath.row {
            cell.textLabel?.attributedText = attributteTitle(content: filterDatas[indexPath.row].title)
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.numberOfLines = 2
        if selectedIndex == indexPath.row {
//            cell.backgroundColor = UIColor.init(hexValue: 0xfc5600).withAlphaComponent(0.1)
        }else{
            cell.backgroundColor = .white
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        target?.perform(object: filterDatas[indexPath.row])
        selectedIndex = indexPath.row
        mainTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return rowHeight
    }
    
    func attributteTitle(content: String) -> NSAttributedString {
        let c = NSString(string: content)
        
        let attribute = NSMutableAttributedString(string: content)
        guard let searchText = searchText else {
            return attribute
        }
        let range = NSString(string: c.uppercased).range(of: searchText.uppercased())
        attribute.addAttributes([NSAttributedString.Key.foregroundColor:UIColor.init(hexValue: 0x4082FF)], range: range)
        return attribute
    }
}


