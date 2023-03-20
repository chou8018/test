//
//  CACurrencyView.swift
//  ClaimApp
//
//  Created by 付耀辉 on 2022/9/22.
//

import UIKit
//import SVGKit

class CACurrencyView: UIView {
    public var target: Target?
    private var selectedIndex:IndexPath?
    private var maxCount = 6
    private var pointView: UIView!
    
    public var isShowing: Bool {
        alpha > 0
    }
    
    var resource : CACurrency! {
        didSet{
            mainTableView.reloadData()
        }
    }
    
    var totalCount : Int {
        self.resource.all.count+1
    }
    
    fileprivate let identifier = "UITableViewIdentifier";
    fileprivate var mainTableView : UITableView!
    private var rowHeight:CGFloat = 36
                
    override init(frame:CGRect) {
        super.init(frame: frame)
        configSubViews()
    }
    
    fileprivate func configSubViews() {
        self.height = rowHeight*CGFloat(maxCount)
        backgroundColor = .white
        mainTableView = UITableView.init(frame: bounds, style: .grouped)
        mainTableView.estimatedRowHeight = 100
        mainTableView.register(CACurrencyCell.self, forCellReuseIdentifier: identifier)
        mainTableView.delegate = self
        mainTableView.separatorColor = .clear
        mainTableView.dataSource = self
        mainTableView.cornerRadius = 5
        addSubview(mainTableView)
        mainTableView.backgroundColor = .white
        mainTableView.snp.makeConstraints { (ls) in
            ls.left.right.equalToSuperview()
            ls.top.equalToSuperview().priority(100)
            ls.bottom.equalToSuperview().priority(101)
            ls.height.equalTo(rowHeight*CGFloat(maxCount))
        }
        
        self.setShadow(sColor: UIColor.lightGray, offset: .zero, opacity: 0.56, radius: 5)
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
        self.mainTableView.reloadData()
    }
    
    func show(pointView: UIView?=nil) {
        
        guard let superView = self.viewContainingController()?.view else { return }
        
        var currentHeight: CGFloat = 0
        if self.totalCount < self.maxCount {
            currentHeight = self.rowHeight*CGFloat(self.totalCount) + 40*2
        }else{
            currentHeight = self.rowHeight*CGFloat(self.maxCount) + 40*2
        }
        
        if let pointView = pointView {
            let rect = pointView.convert(pointView.bounds, to: superView)
            self.snp.remakeConstraints { (ls) in
                ls.left.equalToSuperview().offset(28)
                ls.right.equalToSuperview().offset(-28)
                if superView.height - rect.maxY - 44 > currentHeight {
                    ls.top.equalTo(pointView.snp.bottom).offset(8)
                }else{
                    ls.bottom.equalTo(pointView.snp.top).offset(-8)
                }
            }
        }
        
        superview?.bringSubviewToFront(self)
        UIView.animate(withDuration: 0.15) { [self] in
            self.mainTableView.snp.updateConstraints { (ls) in
                ls.height.equalTo(currentHeight)
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
    
    @objc func didSelectModel(obj: Any) {
        if let indexPath = obj as? IndexPath {
            if indexPath.section == 1 {
                target?.perform(object: resource.all[indexPath.row])
            }else{
                target?.perform(object: resource.default)
            }
            selectedIndex = indexPath
            self.mainTableView.reloadData()
        }
    }
}

extension CACurrencyView:UITableViewDelegate, UITableViewDataSource {
        
    func numberOfSections(in tableView: UITableView) -> Int {
        if resource == nil {
            return 0
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return resource.all.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CACurrencyCell
        if indexPath.section == 1 {
            cell.model = resource.all[indexPath.row]
        }else{
            cell.model = resource.default
        }
        cell.backgroundColor = .white
        if selectedIndex == indexPath {
            cell.backgroundColor = .hexColorWithAlpha(color: "#F1F8FF")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        hide()
        if let superVc = self.viewContainingController() as? CANewExpensesViewController, !superVc.isItemEmpty() {
            let tipVc = LNOfferExitTipViewController(target: Target(target: self, selector: #selector(CACurrencyView.didSelectModel(obj:))), indexPath: indexPath)
            self.viewContainingController()?.present(tipVc, animated: false)
        }else if let superVc = self.viewContainingController() as? THNewExpensesViewController, !superVc.isItemEmpty() {
            let tipVc = LNOfferExitTipViewController(target: Target(target: self, selector: #selector(CACurrencyView.didSelectModel(obj:))), indexPath: indexPath)
            self.viewContainingController()?.present(tipVc, animated: false)
        }else{
            didSelectModel(obj: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView.init(frame: CGRect(x: 0, y: 0, width: self.width, height: 40))
        header.backgroundColor = .white
        let label = UILabel(frame: CGRect(x: 12, y: 0, width: self.width, height: 40))
        label.font = .mediumCustomFont(ofSize: 14)
        label.textColor = .init(hexValue: 0x6E7882)
        if section == 0 {
            label.text = "Default"
        }else{
            label.text = "All"
        }
        header.addSubview(label)
        return header
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}


class CACurrencyCell: UITableViewCell {
    
    var svgView = UIImageView()
    var currencyName = UILabel()
    var currencyCode = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configSubviews() {
        _=self.contentView.subviews.map { subview in
            subview.removeFromSuperview()
        }
        
        self.contentView.addSubview(svgView)
        self.contentView.addSubview(currencyName)
        self.contentView.addSubview(currencyCode)
        
        currencyCode.font = .mediumCustomFont(ofSize: 14)
        currencyCode.textColor = .init(hexValue: 0x161C24)
        
        currencyName.font = .mediumCustomFont(ofSize: 14)
        currencyName.textColor = .init(hexValue: 0x6E7882)
        svgView.borderWidth = 1
        svgView.borderColor = .init(hexValue: 0xc4cdd5)

        svgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(30)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }

        currencyCode.snp.makeConstraints { make in
            make.left.equalTo(svgView.snp.right).offset(8)
            make.bottom.top.equalTo(svgView)
            make.width.greaterThanOrEqualTo(0).priority(100)
        }
        
        currencyName.snp.makeConstraints { make in
            make.left.equalTo(currencyCode.snp.right).offset(8)
            make.bottom.top.equalTo(svgView)
            make.right.equalToSuperview().offset(-16)
            make.width.greaterThanOrEqualTo(50)
        }
    }
    
    var model : CACurrencyInfo! {
        didSet {
            guard let url = URL(string: model.flag) else {
                return
            }
            self.svgView.af_setImage(withURL: url)
            currencyCode.text = model.currency_name
            currencyName.text = "(\(model.currency_code))"
//            currencyCode.text = model.currency_code
//            currencyName.text = model.currency_name
        }
    }
}
