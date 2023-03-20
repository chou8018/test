//
//  CANewExpensesViewController.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/27.
//

import UIKit
import TLPhotoPicker
import AlamofireImage
import SnapKit
import CoreMedia
import PromiseKit
import IQKeyboardManagerSwift
let normalSection = 0
let amountSection = 1
let captureSection = 2

enum CAExpensesTextFieldTag: Int {
    case category = 100
    case merchant
    case carplate
    case vendor
    case date
}

enum CAExpensesSectionType: Int {
    case normal = 0
    case amount
    case capture
}

class CANewExpensesViewController: CABaseViewController {
    
    private let tableIdentifierCell = "tableIdentifierCell"
    private let tableAmountIdentifierCell = "tableAmountIdentifierCell"
    private let tableAmountFootIdentifierCell = "tableAmountFootIdentifierCell"
    private let tableCaptureHeaderIdentifierCell = "tableCaptureHeaderIdentifierCell"
    private let tableCapturePhotoIdentifierCell = "tableCapturePhotoIdentifierCell"
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var personalButton: UIButton!
    @IBOutlet weak var inventoryButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var submitMark: PaddingLabel!
//    @IBOutlet weak var topSpace: NSLayoutConstraint!
//    @IBOutlet weak var tableViewSpace: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var navTitleLabel: UILabel!

    private var selectingCell: UITableViewCell?
    private var selectingIncludeType: CAIncludeType?

    var dropInfo: CAExpenceDropInfo!
    var currencyInfo:CACurrencyInfo?
    
    var expensesType: CAExpensesType = .inventory {
        didSet{
            
            guard datas.count > 1 else { return }
            for formData in datas[1] {
                if let data = formData as? ItemsFormFieldData {
                    data.isPersonal = expensesType == .personal
                }
            }
            
            self.tableView.reloadData()
        }
    }
    var datas: [[FormFieldData]] = []
        
    lazy var footView: UIView = {
        
        let foot = UIView(frame:CGRect(x:0, y:0, width: UIScreen.main.bounds.width-13*2, height: 100))
        foot.backgroundColor = .white
        foot.addCorner(conrners: [UIRectCorner.bottomLeft,UIRectCorner.bottomRight], radius: radius)
        
        let label = UILabel.init()
        label.font = UIFont.mediumCustomFont(ofSize: 12)
        label.textAlignment = .center
        label.tag = 100
        label.textColor = .cRemindRed
        label.text = .localized("new_expenses_title_valid_information", comment: "")
        label.isHidden = true
        foot.addSubview(label)
        label.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(20)
        }
        
        let button = UIButton.init()
        button.backgroundColor = .cPrimary
        button.setTitleColor(.white, for: .normal)
        button.cornerRadius = 6
        button.titleLabel?.font = .demiBoldCustomFont(ofSize: 14)
        button.setTitle(String.localized("new_expenses_button_title_make_claim", comment: ""), for: .normal)
        button.tag = 100
        button.addTarget(self, action: #selector(CANewExpensesViewController.submitExpense), for: .touchUpInside)
        foot.addSubview(button)
        
        button.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(30)
            make.height.equalTo(36)
        }
        
        return foot
        
    }()
    
    var shadowView:UIView?
    var radius: CGFloat = 8
    lazy var headerView: UIView = {
        
//        let header = UIView(frame:CGRect(x:0, y:0, width:tableView.width, height: notSubmitData == nil ? 50:20))
        let header = UIView(frame:CGRect(x:0, y:0, width:UIScreen.main.bounds.width-13*2, height: 50))
        header.backgroundColor = .white
        header.addCorner(conrners: [UIRectCorner.topLeft, UIRectCorner.topRight] , radius: radius)

//        let shadowView = UIView(frame: CGRect(x: 0, y: 0, width: header.width, height: 20))
//        shadowView.backgroundColor = .white
//        shadowView.setShadow(sColor: .lightGray, offset: .zero, opacity: 0.3, radius: radius)
//        header.addSubview(shadowView)
//        shadowView.snp.makeConstraints { make in
//            make.left.top.right.equalToSuperview()
//            make.height.equalTo(20)
//        }
//        self.shadowView = shadowView
//
//        let coverView = UIView(frame: CGRect(x: 0, y: 0, width: header.width, height: 30))
//        coverView.backgroundColor = .white
//        coverView.addCorner(conrners: [UIRectCorner.topLeft, UIRectCorner.topRight] , radius: radius)
//        header.addSubview(coverView)
//        coverView.snp.makeConstraints { make in
//            make.left.bottom.right.equalToSuperview()
//            make.top.equalTo(shadowView).offset(6)
//        }
//        if notSubmitData == nil {
//        submitMark = PaddingLabel.init(frame: CGRect(x: 0, y: 0, width: 100, height: 18))
//        submitMark.text = String.localized("new_expenses_title_not_saved", comment: "")
//        submitMark.textAlignment = .center
//        submitMark.textColor = .white
//        if AppDataHelper.languageCode == .thai {
//            submitMark.font = .customFont(ofSize: 11)
//            submitMark.textInsets = UIEdgeInsets(top: 2.5, left: 0, bottom: 2, right: 0)
//        }else if AppDataHelper.languageCode == .indonesian {
//            submitMark.snp.updateConstraints() { make in
//                make.width.equalTo(108)
//            }
//        }else{
//            submitMark.font = .customFont(ofSize: 12)
//        }
//        submitMark.backgroundColor = UIColor.hexColorWithAlpha(color: "#6E7882")
//        header.addSubview(submitMark)
//        submitMark.snp.makeConstraints { make in
//            make.trailing.equalToSuperview().offset(-16)
//            make.centerY.equalToSuperview()
//            make.height.equalTo(18)
//            make.width.equalTo(100)
//        }
//        submitMark.cornerRadius = submitMark.height/2
////        }
        return header
        
    }()
    
    
    private var footLabel: UILabel? {
        footView.viewWithTag(100) as? UILabel
    }
    
    lazy var searchTipsView: MTSearchTipsView = {
        let tipsView = MTSearchTipsView(frame: CGRect(x: 37, y: 0, width: view.width-37-71, height: 0), target: Target.init(target: self, selector: #selector(didShowResult(obj:))))
        tipsView.setShadow(sColor: .gray, offset: .zero, opacity: 0.5, radius: 5)
        tipsView.hide(isFirst: true)
        return tipsView
    }()
    
    lazy var currencyView: CACurrencyView = {
        let currencyView = CACurrencyView.init(frame: CGRect(x: 37, y: 0, width: view.width-37-71, height: 0))
        currencyView.hide(isFirst: true)
        return currencyView
    }()

    var target: Target?
    var notSubmitData: LNListData?
    var draftInfo: CAExpenseDraft?

    init(type: CAExpensesType, data: LNListData? = nil, target:Target? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.expensesType = type
        self.target = target
        self.notSubmitData = data
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initLocalString() {
        super.initLocalString()
        
        navTitleLabel.text = String.localized("new_expenses_nav_title", comment: "")
        cancelButton.setTitle(String.localized("new_expenses_button_title_cancel", comment: ""), for: .normal)
        saveButton.setTitle(String.localized("new_expenses_button_title_save", comment: ""), for: .normal)
//        tableView.tableHeaderView = headerView
        
        submitMark.text = String.localized("new_expenses_title_not_saved", comment: "")
        submitMark.textAlignment = .center
        submitMark.textColor = .white
        if AppDataHelper.languageCode == .thai {
            submitMark.font = .customFont(ofSize: 11)
            submitMark.textInsets = UIEdgeInsets(top: 2.5, left: 0, bottom: 2, right: 0)
        }else if AppDataHelper.languageCode == .indonesian {
            submitMark.snp.updateConstraints() { make in
                make.width.equalTo(108)
            }
        }else{
            submitMark.font = .customFont(ofSize: 12)
        }
        submitMark.backgroundColor = UIColor.hexColorWithAlpha(color: "#6E7882")
//        header.addSubview(submitMark)
        submitMark.cornerRadius = submitMark.height/2

        view.viewWithTag(200)?.backgroundColor = view.backgroundColor
        personalButton.setTitle(String.localized("new_expenses_button_title_personal", comment: ""), for: .normal)
        inventoryButton.setTitle(String.localized("new_expenses_button_title_inventory", comment: ""), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        initData()
        registerCell()
        initDraftData()
        addObserver()
        view.insertSubview(searchTipsView, at: 1)
        view.insertSubview(currencyView, at: 1)
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(CANewExpensesViewController.draftDescriptionDidChanged(noti:)), name: DraftDescriptionIsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CANewExpensesViewController.dropListDidBeginTpyeIn(noti:)), name: SearchFieldDidBeginSearch, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillHideNotification, object: nil)
        tableView.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if tableView.contentOffset.y > -20 {
            shadowView?.setShadow(sColor: .lightGray, offset: .zero, opacity: 0.3, radius: radius)
        }else{
            shadowView?.setShadow(sColor: .lightGray, offset: .zero, opacity: 0, radius: radius)
        }
    }
    
    private func initDraftData() {
        
//        topSpace.constant = 56
        
        let userController: SellFlowController! = AppServices.shared.find(SellFlowController.self)
        LoadingView.showLoadingViewInView(view: self.view)
        var request: [Promise<Any>] = []
        let p1: Promise<Any> = userController.formOptions(params: ["expense_type":self.expensesType.rawValue]).map{ $0 }
        request = [p1]
        if let saveData = notSubmitData {
            let p2: Promise<Any> = userController.fecthDraftDetail(id: saveData.id.stringValue).map{ $0 }
            request = [p1, p2]
        }

        when(resolved:request).done { [weak self] results in
            
            guard let self = self else { return }
            
            switch results[0] {
            case .fulfilled(let value):
                if let dropInfo = value as? CAExpenceDropInfo {
                    self.dropInfo = dropInfo
                    if let currency = dropInfo.currencies {
                        self.currencyView.resource = currency
                        self.currencyInfo = currency.default
                    }
                }
            case .rejected(let error):
                UIAlertController.showErrorMessage(error: error, from: self)
            }
            if results.count > 1 {
                switch results[1] {
                case .fulfilled(let value):
                    if let info = value as? CAExpenseDraft {
                        self.draftInfo = info
                    }
                case .rejected(let error):
                    UIAlertController.showErrorMessage(error: error, from: self)
                }
            }
            
        }.catch { [weak self] (error) in
            guard let self = self else { return }
            LoadingView.hideLoadingViewInView(view: self.view)
            UIAlertController.showErrorMessage(error: error, from: self)
        }.finally { [weak self] in
            guard let self = self else { return }
            LoadingView.hideLoadingViewInView(view: self.view)
            self.initResourceData()
            if let draftInfo = self.draftInfo {
                self.expensesType = CAExpensesType.init(rawValue: draftInfo.expense_type ?? "") ?? .personal
            }
        }
    }
    
    private func initData() {
        mainView.setShadow(sColor: .lightGray, offset: .zero, opacity: 0.3, radius: radius)
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = .clear
        if self.expensesType == .personal {
            highlightButton(sender: personalButton, unselectButton: inventoryButton)
        } else {
            highlightButton(sender: inventoryButton, unselectButton: personalButton)
        }
        
        if let _ = notSubmitData {

            if expensesType == .personal {
                personalButton.snp.updateConstraints() { make in
                    make.trailing.equalToSuperview().offset(-16)
                }
                personalButton.isEnabled = false
                inventoryButton.isHidden = true
            } else {
                inventoryButton.snp.updateConstraints() { make in
                    make.leading.equalToSuperview().offset(16)
                }
                inventoryButton.isEnabled = false
                personalButton.isHidden = true
            }

        }
    }
    
    private func registerCell() {
        tableView.register(UINib.init(nibName: "CANewExpensesNormalCell", bundle: nil), forCellReuseIdentifier: tableIdentifierCell)
        tableView.register(UINib.init(nibName: "CANewExpensesAmountCell", bundle: nil), forCellReuseIdentifier: tableAmountIdentifierCell)
        tableView.register(UINib.init(nibName: "CAExpensesAmountFootView", bundle: nil), forHeaderFooterViewReuseIdentifier: tableAmountFootIdentifierCell)
        tableView.register(UINib.init(nibName: "CAExpensesAmountFootView", bundle: nil), forHeaderFooterViewReuseIdentifier: tableCaptureHeaderIdentifierCell)
        tableView.register(UINib.init(nibName: "CAExpensesCaptureCell", bundle: nil), forCellReuseIdentifier: tableCapturePhotoIdentifierCell)
        
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.tableFooterView = footView
    }
    
    
    func initResourceData() {
        if dropInfo == nil {
            return
        }
        
        datas.removeAll()
        
        let formData1 = SearchFormFieldData(localizedTitleKey: .localized("new_expenses_title_vendor", comment: ""))
        formData1.required = true
        formData1.placeholder = .localized("new_expenses_title_vendor_placeholder", comment: "")
        if let draftInfo = draftInfo {
            formData1.text = draftInfo.vendor?.title
            if let vendor = draftInfo.vendor {
                formData1.selectedItem = CADropdownItem(value: vendor.value.stringValue, title: vendor.title)
            }
        }
        
        let formData2 = TextFormFieldData(localizedTitleKey: .localized("new_expenses_title_invoice_no.", comment: ""))
        formData2.placeholder = .localized("new_expenses_title_invoice_no._placeholder", comment: "")
        if let draftInfo = draftInfo {
            formData2.text = draftInfo.invoice_number
        }

        let formData_invoiceDate = DateFormFieldData(localizedTitleKey: .localized("new_expenses_title_date", comment: ""))
        formData_invoiceDate.placeholder = .localized("new_expenses_title_date_placeholder", comment: "")
        formData_invoiceDate.required = true
        if expensesType == .personal {
            formData_invoiceDate.title = "Date of Expenditure"
            formData_invoiceDate.placeholder = "Select the date of expenditure"
        }
        let formatter = DateFormatter.makeCurrencyDateFormatter()
        formatter.dateFormat = "dd MMMM, yyyy"
        formData_invoiceDate.dateFormatter = formatter
        if let draftInfo = draftInfo {
            let formater = DateFormatter.dd_MM_yyyy
            formater.locale = Locale.init(identifier: AppDataHelper.languageCode?.rawValue ?? "en")
            if let country_code = draftInfo.currencyCode {
                switch country_code {
                case .THB:
                    formater.locale = Locale.init(identifier: AppDataHelper.languageCode?.rawValue ?? "TH")
                case .IDR:
                    formater.locale = Locale.init(identifier: AppDataHelper.languageCode?.rawValue ?? "ID")
                default:
                    break
                }
            }
            if let date = Date.init(string: draftInfo.invoice_date, formatter: .dashSeparatedYearMonthDay) {
                formData_invoiceDate.text = date.string(with: formatter)
            }else if let date = draftInfo.invoice_date.dateFromISO8601 {
                formData_invoiceDate.text = date.string(with: formatter)
            }
        }
        
        
        let formData_due = DateFormFieldData(localizedTitleKey: .localized("new_expenses_title_due_date", comment: ""))
        formData_due.placeholder = .localized("new_expenses_title_due_date_placeholder", comment: "")
        formData_due.dateFormatter = formatter
        if let draftInfo = draftInfo {
            let formater = DateFormatter.dd_MM_yyyy
            formater.locale = Locale.init(identifier: AppDataHelper.languageCode?.rawValue ?? "en")
            if let country_code = draftInfo.currencyCode {
                switch country_code {
                case .THB:
                    formater.locale = Locale.init(identifier: AppDataHelper.languageCode?.rawValue ?? "TH")
                case .IDR:
                    formater.locale = Locale.init(identifier: AppDataHelper.languageCode?.rawValue ?? "ID")
                default:
                    break
                }
            }
            if let date = Date.init(string: draftInfo.due_date, formatter: .dashSeparatedYearMonthDay) {
                formData_due.text = date.string(with: formatter)
            }else if let date = draftInfo.due_date.dateFromISO8601 {
                formData_due.text = date.string(with: formatter)
            }
        }

        if expensesType == .personal {
            datas.append([formData_invoiceDate, formData_due])
        }else{
            datas.append([formData1, formData2, formData_invoiceDate, formData_due])
        }
        
        if let draftInfo = draftInfo {
            let amountItems = draftInfo.items ?? []
            var amounts = [ItemsFormFieldData]()

            for index in 0..<amountItems.count {
                let amountItem = amountItems[index]
                
                let itemFormData = ItemsFormFieldData(localizedTitleKey: "\(String.localized("new_expenses_title_Item", comment: "")) \(index+1)")
                itemFormData.shouldCopy = draftInfo.toggle_copy_item == 1
                var items = [FormFieldData]()

                let item1 = TextFormFieldData(localizedTitleKey: "amount")
                item1.required = true
                item1.placeholder = "0.00"
                if AppDataHelper.countryCode == .ID {
                    item1.placeholder = "0"
                }
                item1.keyboardType = .decimalPad
                if let amount = amountItem.amount?.replacingOccurrences(of: amountItem.currency?.amount_separator ?? ",", with: ""),  let double = Double(amount), double > 0.00 {
                    item1.text = amountItem.amount
                }
                items.append(item1)
                
                let item2 = TextFormFieldData(localizedTitleKey: "amount")
                item2.placeholder = "0.00"
                if AppDataHelper.countryCode == .ID {
                    item2.placeholder = "0"
                }
                item2.keyboardType = .decimalPad
                if let tax_amount = amountItem.tax_amount?.replacingOccurrences(of: amountItem.currency?.amount_separator ?? ",", with: ""),  let double = Double(tax_amount), double > 0.00 {
                    item2.text = amountItem.tax_amount
                }
                items.append(item2)
                
                let item3 = SearchFormFieldData(localizedTitleKey: "carplate")
                item3.required = true
                item3.placeholder = .localized("new_expenses_title_carplate_placeholder", comment: "")
                item3.text = amountItem.inventory?.title
                if let inventory = amountItem.inventory {
                    item3.selectedItem = CADropdownItem(value: inventory.value.stringValue, title: inventory.title)
                }
                items.append(item3)
                
                let item4 = SearchFormFieldData(localizedTitleKey: "category")
                item4.required = true
                item4.placeholder = .localized("new_expenses_title_category_placeholder", comment: "")
                item4.text = amountItem.category?.title
                if let category = amountItem.category {
                    item4.selectedItem = CADropdownItem(value: category.value.stringValue, title: category.title)
                }
                items.append(item4)

                let item5 = TextFormFieldData(localizedTitleKey: "description")
                item5.placeholder = .localized("new_expenses_title_description_placeholder", comment: "")
                item5.text = amountItem.description
                items.append(item5)
                
                itemFormData.currencyCode = amountItem.currency?.currency_code ?? ""
                itemFormData.items = items
                itemFormData.currencyInfo = amountItem.currency
                itemFormData.isPersonal = expensesType == .personal
                
                amounts.append(itemFormData)
            }
            datas.append(amounts)
        }else{
            let formData4 = ItemsFormFieldData(localizedTitleKey: .localized("new_expenses_title_Item", comment: "") + " 1")
            formData4.currencyCode = AppDataHelper.currencyCode.rawValue
            formData4.currencyInfo = dropInfo.currencies?.default
            
            var items = [FormFieldData]()
            
            let item1 = TextFormFieldData(localizedTitleKey: "amount")
            item1.required = true
            item1.placeholder = "0.00"
            if AppDataHelper.countryCode == .ID {
                item1.placeholder = "0"
            }
            
            item1.keyboardType = .decimalPad
            items.append(item1)
            
            let item2 = TextFormFieldData(localizedTitleKey: "amount")
            item2.placeholder = "0.00"
            if AppDataHelper.countryCode == .ID {
                item2.placeholder = "0"
            }
            item2.keyboardType = .decimalPad
            items.append(item2)
            
            let item3 = SearchFormFieldData(localizedTitleKey: "carplate")
            item3.required = true
            item3.placeholder = .localized("new_expenses_title_carplate_placeholder", comment: "")
            items.append(item3)
            
            let item4 = SearchFormFieldData(localizedTitleKey: "category")
            item4.required = true
            item4.placeholder = .localized("new_expenses_title_category_placeholder", comment: "")
            items.append(item4)

            let item5 = TextFormFieldData(localizedTitleKey: "description")
            item5.placeholder = .localized("new_expenses_title_description_placeholder", comment: "")
            items.append(item5)

            formData4.items = items
            formData4.isPersonal = expensesType == .personal
            datas.append([formData4])
        }
        
        let formData5 = PhotoFormFieldData(localizedTitleKey: "")
        formData5.required = false
        datas.append([formData5])
        if let draftInfo = draftInfo, let files = draftInfo.receipt_files, !files.isEmpty {
            formData5.images = files
        }
        let formData6 = DropdownFormFieldData(localizedTitleKey: .localized("new_expenses_title_payment", comment: ""))
        formData6.required = true
        formData6.placeholder = .localized("new_expenses_title_payment_placeholder", comment: "")
        datas.append([formData6])
        
        formData6.items = dropInfo.payees
        if let draftInfo = draftInfo {
            formData6.text = draftInfo.payee?.title
            
            for index in 0..<dropInfo.payees.count {
                if (dropInfo.payees[index].id as! NSObject) == draftInfo.payee?.value ?? -1{
                    formData6.selectedIndex = index
                }
            }
        }

        tableView.reloadData()
    }
    
    
    @IBAction func switchButtonClicked(_ sender: UIButton) {
        
//        if let _ = saveData {
//            return
//        }
        if sender.isSelected == true {
            return
        }
        searchTipsView.hide()

        if let _ = draftInfo {
            let tipVc = LNOfferExitTipViewController(target: Target(target: self, selector: #selector(CANewExpensesViewController.dismissAction2(obj:))), selectType: self.expensesType.rawValue)
            self.present(tipVc, animated: false, completion: nil)
            return
        }

        if isEmpty() {
            if sender.tag == 100 {
                dismissAction2(obj: CAExpensesType.inventory.rawValue)
            } else {
                dismissAction2(obj: CAExpensesType.personal.rawValue)
            }
            
            return
        }
        
        let tipVc = LNOfferExitTipViewController(target: Target(target: self, selector: #selector(CANewExpensesViewController.dismissAction2(obj:))), selectType: self.expensesType.rawValue)
        self.present(tipVc, animated: false, completion: nil)
    }
    
    private func highlightButton(sender: UIButton ,unselectButton: UIButton) {
        unselectButton.setTitleColor(.personalButtonUnselect, for: .normal)
        unselectButton.borderWidth = 0.4
        unselectButton.borderColor = .personalButtonUnselect
        unselectButton.isSelected = false
        sender.setTitleColor(.cPrimary, for: .normal)
        sender.borderColor = .cPrimary
        sender.borderWidth = 0.8
        sender.isSelected  = true
    }

    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        if isEmpty() {
            dismissAction(obj: "")
            return
        }
        let tipVc = LNOfferExitTipViewController(target: Target(target: self, selector: #selector(CANewExpensesViewController.dismissAction(obj:))))
  
        self.present(tipVc, animated: false, completion: nil)
    }
    
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        
        if self.datas.count == 0 {
            return
        }
                
        if !canSave() {
            footLabel?.isHidden = false
            footView.subviews.last?.isUserInteractionEnabled = true
            self.tableView.reloadData()
            return
        }
        
        submitForm(isDraft: true)
    }

    func isItemEmpty() -> Bool {
        
        if datas.count > 1 {
            for item in datas[1] {
                if let item = item as? ItemsFormFieldData, let amount = item.items.first, let text = amount.text, !text.isEmpty {
                    return false
                }
            }
        }
        return true
    }

    func canSave() -> Bool {
        var isCanSave = true
        for sections in datas {
            for sectionData in sections {
                if let itemData = sectionData as? ItemsFormFieldData {
                    for item in itemData.items {
                        if let data = item as? SearchFormFieldData {
                            if data.selectedItem == nil, !(data.text?.isEmpty ?? true), data.required {
                                if expensesType == .personal, data.title == "carplate" {
                                }else{
                                    data.isShowErrorMsg = true
                                    isCanSave = false
                                }
                            }
                        }else{
                            item.isShowErrorMsg = false
                        }
                    }
                }
                if let data = sectionData as? SearchFormFieldData {
                    if data.selectedItem == nil, !(data.text?.isEmpty ?? true), data.required {
                        data.isShowErrorMsg = true
                        isCanSave = false
                    }
                }else{
                    sectionData.isShowErrorMsg = false
                }
            }
        }
        return isCanSave
    }
    
    func canSumit(isDraft: Bool) -> Bool {
        if isDraft {
            return true
        }
        var isCanSubmit = true
        for sections in datas {
            for sectionData in sections {
                
                if let itemData = sectionData as? ItemsFormFieldData {
                    for item in itemData.items {
                                                
                        if let data = item as? SearchFormFieldData {
                            if data.selectedItem == nil, data.required {
                                if expensesType == .personal, data.title == "carplate" {
                                }else{
                                    data.isShowErrorMsg = true
                                    isCanSubmit = false
                                }
                            }
                        }else if (item.text?.isEmpty ?? true || itemData.currencyInfo?.default_amount == item.text) && item.required {
                            item.isShowErrorMsg = true
                            isCanSubmit = false
                        }
                    }
                }
                
                if let data = sectionData as? PhotoFormFieldData, data.required {
                    if data.images.isEmpty {
                        sectionData.isShowErrorMsg = true
                        isCanSubmit = false
                    }
                }else if let data = sectionData as? SearchFormFieldData {
                    if data.selectedItem == nil {
                        data.isShowErrorMsg = true
                        isCanSubmit = false
                    }
                }else if let data = sectionData as? DropdownFormFieldData, data.required {
                    if data.selectedIndex == nil {
                        sectionData.isShowErrorMsg = true
                        isCanSubmit = false
                    }
                }else if sectionData.text?.isEmpty ?? true, sectionData.required {
                    sectionData.isShowErrorMsg = true
                    isCanSubmit = false
                }
            }
        }
        return isCanSubmit
    }
    
    
    func isEmpty() -> Bool {
        
        if let _ = draftInfo {
            for sections in datas {
                for sectionData in sections {
                    if sectionData.hasBeenEdited {
                        return false
                    }
                }
            }
        }else{
            for sections in datas {
                for sectionData in sections {
                    
                    if let itemData = sectionData as? ItemsFormFieldData {
                        for item in itemData.items {
                            if !item.isEmpty{
                                return false
                            }
                        }
                        
                    }else if let data = sectionData as? PhotoFormFieldData {
                        if !data.images.isEmpty {
                            return false
                        }
                    }else{
                        if !sectionData.isEmpty, sectionData.title != "Payment to"{
                            return false
                        }
                    }
                }
            }
        }
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        tableView.removeObserver(self, forKeyPath: "contentOffset")
    }
}

extension CANewExpensesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == captureSection {
            if let fieldData = datas[section].first as? PhotoFormFieldData, fieldData.images.count > 0 {
            }else{
                return 0
            }
        }
        return datas[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let fieldData = datas[indexPath.section][indexPath.row]
        
        if let photoData = fieldData as? PhotoFormFieldData, photoData.images.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: tableCapturePhotoIdentifierCell, for: indexPath) as! CAExpensesCaptureCell
            cell.selectionStyle = .none
            cell.bind(data: photoData)
            cell.removeButton.addTarget(self, action: #selector(removePhoto) , for: .touchUpInside)
            return cell
      }else if let itemData = fieldData as? ItemsFormFieldData {
          let cell = tableView.dequeueReusableCell(withIdentifier: tableAmountIdentifierCell, for: indexPath) as! CANewExpensesAmountCell
          cell.bind(data: itemData)
          cell.removeButton.isHidden = indexPath.row <= 0
          cell.removeButton.tag = indexPath.row+100
          cell.removeButton.addTarget(self, action: #selector(removeAmount(_:)) , for: .touchUpInside)
          cell.selectionStyle = .none
          return cell
      }else{
          let cell = tableView.dequeueReusableCell(withIdentifier: tableIdentifierCell, for: indexPath) as! CANewExpensesNormalCell
          cell.selectionStyle = .none
          cell.bind(data: fieldData)
          return cell
      }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
//            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            datas[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.none)
        }
    }
}

extension CANewExpensesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == amountSection {
            if let data = datas[amountSection][indexPath.row] as? ItemsFormFieldData {
                return data.rowHeight - (data.isPersonal ? 36+10 : 0)
            }
        } else if indexPath.section == captureSection {
            
            if let formData = datas[2].first as? PhotoFormFieldData, formData.images.count > 0 {
                return 160 + 16
            }
            return 0
        }
        return 69
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == captureSection, let formData = datas[2].first as? PhotoFormFieldData, formData.images.count == 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: tableCaptureHeaderIdentifierCell) as! CAExpensesAmountFootView
            header.sectionType = captureSection
            header.addNewItemButton.addTarget(self, action: #selector(captureItem) , for: .touchUpInside)
            if let formData = datas[2].first as? PhotoFormFieldData, formData.isShowErrorMsg{
                header.bgView.borderColor = .cRemindRed
            }else{
                header.bgView.borderColor = .init(hexValue: 0x4082FF)
            }
            header.optionView.isHidden = true
            return header
        }
        let view = UIView()
        view.backgroundColor = .white
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        switch section {
        case normalSection:
            return 0.01
        case amountSection:
            return 0
        case captureSection:
            if let formData = datas[2].first as? PhotoFormFieldData, formData.images.count > 0 {
                return 0
            }
            return 36 + 8
        default:
            return 12
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == amountSection {
            let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: tableAmountFootIdentifierCell) as! CAExpensesAmountFootView
            footer.sectionType = amountSection
            footer.addNewItemButton.addTarget(self, action: #selector(addNewItem) , for: .touchUpInside)
            footer.switchButton.addTarget(self, action: #selector(switchCopyState), for: .valueChanged)
            footer.bgView.borderColor = .init(hexValue: 0x4082FF)
            footer.optionView.isHidden = false
            if datas.count > 1, let itemsData = datas[1].last as? ItemsFormFieldData {
                footer.switchButton.isOn = itemsData.shouldCopy
            }
            return footer
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == amountSection {
            return 36+44
        }
        return 0
    }
}

extension CANewExpensesViewController: TLPhotosPickerViewControllerDelegate {
    
    func showImagePicker() {
        
        let vc = TLPhotosPickerViewController()
        vc.delegate = self
        var config  = TLPhotosPickerConfigure()
        config.cancelTitle = String.localized("new_expenses_button_title_cancel", comment: "")
        config.doneTitle = String.localized("new_expenses_button_title_done", comment: "")
        config.tapHereToChange = String.localized("new_expenses_button_title_tap_change", comment: "")
        config.allowedLivePhotos = true
        config.allowedVideo = false
        config.autoPlay = false
        config.allowedVideoRecording = false
        config.muteAudio = true
        config.maxSelectedAssets = 1
        config.mediaType = .image
        vc.configure = config
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
        
    }
    
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        
        guard let asset = withTLPHAssets.first else { return }
        
        switch asset.type {
        case .livePhoto: fallthrough
        case .photo:
            
            guard let image = asset.fullResolutionImage else { return }
            
            let sizeInBytes = imageSizeInBytes(image: image)
            
            //create the upload image
            
            var selectedImage = image
            let lengthOfLongestSide = max(selectedImage.size.width, selectedImage.size.height)
            
            let limit = 2
            //if size cannot be determined, we dont compare size
            
            if (sizeInBytes > (limit*1024*1024) || sizeInBytes == -1), lengthOfLongestSide > 1200.0 {
                var scale = 1200.0/lengthOfLongestSide
                scale = round(scale * CGFloat(100))/CGFloat(100)
                selectedImage = selectedImage.af_imageScaled(to: CGSize(width: scale * selectedImage.size.width, height: scale * selectedImage.size.height))
            }
            
            guard let data = selectedImage.compressOriginalImage(200*1024) else {
                return
            }
            
            if let formData = self.datas[2].first as? PhotoFormFieldData {
                formData.images = ["\(data.base64EncodedString(options: []))"]
                formData.isShowErrorMsg = false
                formData.hasBeenEdited = true
                if let footer = self.tableView.footerView(forSection: captureSection) as? CAExpensesAmountFootView {
                    footer.bgView.borderColor = .init(hexValue: 0x4082FF)
                }
            }
            self.tableView.reloadSections([captureSection], with: .none)
            
        default:
            () //no op
        }
    }
    
    func printFileSize(image: UIImage) {
        print("size of image in KB: \( Double(imageSizeInBytes(image: image)) / 1024.0 ) ")
    }
    
    func imageSizeInBytes(image: UIImage) -> Int {
        if let data = image.jpegData(compressionQuality: 1.0) {
            return data.count
        } else {
            return -1
        }
    }
    
    func photoPickerDidCancel() {
        //no op
    }
    
    func dismissComplete() {
    }
    
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        let _ = UIAlertController.showRequestCameraAccessMessage(
            picker,
            noActionHandler: { _ in
                return
        },
            yesActionHandler: { _ in
                picker.openSettings()
        })
    }
    
}

//MARK: - selectors
extension CANewExpensesViewController {
    
    
    @objc func dismissAction2(obj:String) {
        
        if let type = CAExpensesType.init(rawValue: obj) {
            self.expensesType = type == .personal ? .inventory : .personal
            highlightButton(sender: type == .personal ? inventoryButton : personalButton, unselectButton: type != .personal ? inventoryButton : personalButton)
        }
        if let _ = draftInfo {
//           _ = LNExpenseDBManager.deleteExpenceData(data: saveData)
        }
        target?.perform(object: self.expensesType.rawValue)

        self.footLabel?.isHidden = true
        draftInfo = nil
        notSubmitData = nil
        initDraftData()
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        UIView.animate(withDuration: 0.15) {
//            self.tableViewSpace.constant = 23
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func didShowResult(obj: Any) {
        searchTipsView.hide()
        guard let item = obj as? CADropdownItem, let selectingCell = selectingCell, let includeType = selectingIncludeType else { return }
        
        if let cell = selectingCell as? CANewExpensesNormalCell {
            if let data = cell.data as? SearchFormFieldData {
                data.selectedItem = item
                data.text = item.title
                cell.textField.text = item.title
                data.isShowErrorMsg = false
                cell.textField.superview?.borderColor = .init(hexValue: 0xC4CDD5)
            }
        }else if let cell = selectingCell as? CANewExpensesAmountCell {
            
            if includeType == .carplate {
                if let data = cell.data.items[2] as? SearchFormFieldData {
                    data.selectedItem = item
                    cell.carplate.text = item.title
                    data.isShowErrorMsg = false
                    data.text = item.title
                    cell.carplate.superview?.borderColor = .init(hexValue: 0xC4CDD5)
                }
            }else{
                if let data = cell.data.items[3] as? SearchFormFieldData {
                    data.selectedItem = item
                    data.text = item.title
                    cell.category.text = item.title
                    data.isShowErrorMsg = false
                    cell.category.superview?.borderColor = .init(hexValue: 0xC4CDD5)
                }
            }
        }
        
        self.selectingIncludeType = nil
        self.selectingCell = nil
    }
    
    @objc func draftDescriptionDidChanged(noti: Notification) {
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
        if  let obj = noti.object as? [String:Any], let heightDifference = obj["heightDifference"] as? CGFloat, let cell = obj["cell"] as? CANewExpensesAmountCell {
            if !cell.descrip.isFirstResponder {
                return
            }
            LNDebugPrint(item: self.tableView.contentOffset.y - heightDifference)
            UIView.animate(withDuration: 0.15) {
//                self.tableViewSpace.constant = self.tableViewSpace.constant-heightDifference
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func dismissAction(obj:String) {
//        if let saveData = saveData {
//            _ = LNExpenseDBManager.deleteExpenceData(data: saveData)
//            target?.perform(object: "")
//        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.25) {
            self.dismiss(animated: true)
        }
    }

    @objc private func switchCopyState(_ sender: UISwitch) {
        
        for data in datas[1] {
            if let data = data as? ItemsFormFieldData {
                data.shouldCopy = sender.isOn
            }
        }
    }
    
    
    @objc private func addNewItem(_ sender: UIButton) {
        if dropInfo == nil {
            return
        }
        searchTipsView.hide()
        
        var formDatas = datas[1]
        
        let formData = ItemsFormFieldData(localizedTitleKey: "\(String.localized("new_expenses_title_Item", comment: "")) \(formDatas.count+1)")
        formData.currencyCode = AppDataHelper.currencyCode.rawValue
        formData.currencyInfo = dropInfo.currencies?.default
        if let itemsData = formDatas.last as? ItemsFormFieldData {
            formData.shouldCopy = itemsData.shouldCopy
        }
        
        var items = [FormFieldData]()
        
        let item1 = TextFormFieldData(localizedTitleKey: "amount")
        item1.required = true
        item1.placeholder = "0.00"
        if AppDataHelper.countryCode == .ID {
            item1.placeholder = "0"
        }
        item1.keyboardType = .decimalPad
        items.append(item1)
                
        let item2 = TextFormFieldData(localizedTitleKey: "amount")
        item2.placeholder = "0.00"
        if AppDataHelper.countryCode == .ID {
            item2.placeholder = "0"
        }
        item2.keyboardType = .decimalPad
        items.append(item2)
         
        let item3 = SearchFormFieldData(localizedTitleKey: "carplate")
        item3.required = true
        item3.placeholder = .localized("new_expenses_title_carplate_placeholder", comment: "")
        items.append(item3)
        
        let item4 = SearchFormFieldData(localizedTitleKey: "category")
        item4.required = true
        item4.placeholder = .localized("new_expenses_title_category_placeholder", comment: "")
        if let itemsData = formDatas.last as? ItemsFormFieldData, itemsData.items.count > 3, let searchData = itemsData.items[3] as? SearchFormFieldData, itemsData.shouldCopy {
            item4.text = searchData.text
            item4.selectedItem = searchData.selectedItem
        }
        items.append(item4)

        let item5 = TextFormFieldData(localizedTitleKey: "description")
        item5.placeholder = .localized("new_expenses_title_description_placeholder", comment: "")
        if let itemsData = formDatas.last as? ItemsFormFieldData, itemsData.items.count > 4, itemsData.shouldCopy {
            item5.text = itemsData.items[4].text
        }
        items.append(item5)

        formData.items = items
        formData.isPersonal = expensesType == .personal
        
        formData.currencyInfo = self.currencyInfo
        formDatas.append(formData)

        datas[1] = formDatas
        datas[1].first?.hasBeenEdited = true
        tableView.reloadData()
    }
    
    @objc private func captureItem(_ sender: UIButton) {
        searchTipsView.hide()
        self.showImagePicker()
    }
    
    @objc private func removePhoto(_ sender: UIButton) {
        guard let formData = datas[2].first as? PhotoFormFieldData else {
            return
        }
        formData.images = []
        self.tableView.reloadSections([captureSection], with: .none)
    }
    
    
    @objc private func removeAmount(_ sender: UIButton) {
        
        var items = datas[1]
        items.remove(at: sender.tag-100)
        for index in 0..<items.count {
            let item = items[index]
            item.title = "\(String.localized("new_expenses_title_Item", comment: "")) \(index+1)"
        }
        datas[1] = items
        self.tableView.reloadSections([1], with: .automatic)
    }
    
    @objc func dropListDidBeginTpyeIn(noti: Notification) {
        
        guard let obj = noti.object as? [String:Any],
              let searchText = obj["searchText"] as? String
        else {return}
                
        var cell:UIView!
        if let c = obj["cell"] as? CANewExpensesNormalCell {
            cell = c.textField
            selectingIncludeType = .vendor
            selectingCell = c
        }else if let c = obj["cell"] as? CANewExpensesAmountCell {
            
            if let data = obj["data"] as? SearchFormFieldData {
                if data.title == "carplate" {
                    selectingIncludeType = .carplate
                    cell = c.carplate
                }else{
                    selectingIncludeType = .category
                    cell = c.category
                }
            }
            selectingCell = c
        }
        
        let rect = cell.convert(cell.bounds, to: self.view)
        searchTipsView.snp.remakeConstraints { (ls) in
            ls.left.equalToSuperview().offset(rect.minX-12)
            ls.right.equalToSuperview().offset(-rect.minX+12)
            if selectingIncludeType == .vendor {
                ls.top.equalTo(cell.snp.bottom).offset(8)
            }else{
                ls.bottom.equalTo(cell.snp.top).offset(-8)
            }
        }
        
        guard let includeType = selectingIncludeType else {return}
        searchTipsView.reset(searchText: searchText, expensesType: expensesType, include: includeType)
        searchTipsView.show()
    }

    private func submitForm(isDraft: Bool) {
        if self.datas.count == 0 {
            return
        }
        
        footView.subviews.last?.isUserInteractionEnabled = false
        footLabel?.isHidden = true
        if !canSumit(isDraft: isDraft) {
            footLabel?.isHidden = false
            footView.subviews.last?.isUserInteractionEnabled = true
            self.tableView.reloadData()
            return
        }
        
        var params = [String:Any]()
        params["payee_id"] = ""
        
        if expensesType == .personal {
            
            if let fieldData = datas[0][0] as? DateFormFieldData, let value = fieldData.text, value.count > 0 {
                
                if let formatter = fieldData.dateFormatter, let date = Date.init(string: value, formatter: formatter) {
                    params["expenditure_date"] = date.string(with: .dashSeparatedYearMonthDay)
                }
            }
            
            if let fieldData = datas[0][1] as? DateFormFieldData, let value = fieldData.text, value.count > 0 {
                
                if let formatter = fieldData.dateFormatter, let date = Date.init(string: value, formatter: formatter) {
                    params["due_date"] = date.string(with: .dashSeparatedYearMonthDay)
                }
            }

        }else{
            params["vendor_id"] = ""
            params["invoice_number"] = ""
            params["invoice_date"] = ""
            if let fieldData = datas[0][0] as? SearchFormFieldData, let value = fieldData.selectedItem?.value, value.count > 0 {
                params["vendor_id"] = value
            }
            
            if let invoiceNo = datas[0][1].text, invoiceNo.count > 0 {
                params["invoice_number"] = invoiceNo
            }
            
            if let fieldData = datas[0][2] as? DateFormFieldData, let value = fieldData.text, value.count > 0 {
                
                if let formatter = fieldData.dateFormatter, let date = Date.init(string: value, formatter: formatter) {
                    params["invoice_date"] = date.string(with: .dashSeparatedYearMonthDay)
                }
            }
            
            if let fieldData = datas[0][3] as? DateFormFieldData, let value = fieldData.text, value.count > 0 {
                
                if let formatter = fieldData.dateFormatter, let date = Date.init(string: value, formatter: formatter) {
                    params["due_date"] = date.string(with: .dashSeparatedYearMonthDay)
                }
            }
        }

        if let formData = datas[3][0] as? DropdownFormFieldData,let dropData = formData.selectedIndex.map({formData.items[$0]}) {
            if let id = dropData.id as? NSNumber {
                params["payee_id"] = id.stringValue
            }else if let id = dropData.id as? String{
                params["payee_id"] = id
            }
        }
        
        params["expense_type"] = expensesType.rawValue
        
        if let data = datas[1].first as? ItemsFormFieldData {
            params["toggle_copy_item"] = data.shouldCopy ? 1 : 0
        }
        
        var itemDatas = [[String:Any]]()
        for sectionData in datas[1] {
            
            if let itemData = sectionData as? ItemsFormFieldData {
                var itemDic = [String:Any]()
                
                if let value = itemData.items.first?.text {
                    itemDic["amount"] = value.replacingOccurrences(of: AppDataHelper.getSeparator(itemData.currencyCode), with: "")
                }else{
                    itemDic["amount"] = ""
                }
                
                var currencyParams = [String:Any]()
                currencyParams["currency_code"] = itemData.currencyInfo?.currency_code ?? ""
                currencyParams["flag"] = itemData.currencyInfo?.flag ?? ""
                currencyParams["currency_name"] = itemData.currencyInfo?.currency_name ?? ""
                currencyParams["amount_separator"] = itemData.currencyInfo?.amount_separator ?? ""
                currencyParams["decimal_places_count"] = itemData.currencyInfo?.decimal_places_count.stringValue ?? ""
                currencyParams["default_amount"] = itemData.currencyInfo?.default_amount ?? ""
                itemDic["currency"] = currencyParams
                
                if let value = itemData.items[1].text {
                    itemDic["tax_amount"] = value.replacingOccurrences(of: AppDataHelper.getSeparator(itemData.currencyCode), with: "")
                }else{
                    itemDic["tax_amount"] = ""
                }
                
                if let fieldData = itemData.items[2] as? SearchFormFieldData, let title = fieldData.selectedItem?.title, title.count > 0 ,let value = fieldData.selectedItem?.value, value.count > 0 {
                    itemDic["carplate_number"] = title
                    itemDic["inventory_id"] = value
                }
                
                if let fieldData = itemData.items[3] as? SearchFormFieldData, let value = fieldData.selectedItem?.value, value.count > 0 {
                    itemDic["expense_category_id"] = value
                }
                
                if let value = itemData.items[4].text {
                    itemDic["description"] = value
                }
                
                itemDatas.append(itemDic)
                
                if itemData.country_code.isEmpty {
                    params["country_code"] = AppDataHelper.user?.country?.countryCode ?? "SG"
                }else{
                    params["country_code"] = itemData.country_code
                }
                if itemData.country_id.isEmpty {
                    params["country_id"] = AppDataHelper.user?.country?.id ?? "1"
                }else{
                    params["country_id"] = itemData.country_id
                }
            }
        }
        params["items"] = itemDatas

        params["file_item_name"] = "expense"
        if let photoData = datas[2].first as? PhotoFormFieldData, let info = photoData.images.first {
            
            if let base64Str = info as? String {
                params["file"] = "data:image/jpeg;base64,\(base64Str)"
            } else if let imageData = info as? LNUploadImage {
//                params["file"] = "data:image/jpeg;base64,\(imageData.base64 ?? "")"
                params["file"] = imageData.url
            }
        }
        params["is_draft"] = isDraft
        if let draft = draftInfo {
            params["id"] = draft.id
        }
        
        LNDebugPrint(item: params)
        LoadingView.showLoadingViewInView(view: self.view)
        let userController: SellFlowController! = AppServices.shared.find(SellFlowController.self)
        userController.submitForm(params: params, id: "").done {[weak self] selfImage in
            guard let self = self else {return}

            if let _ = self.draftInfo {
                self.target?.perform(object: "draft_data")
            }else{
                self.target?.perform(object: "")
            }
            self.dismiss(animated: true)
            
        }.catch { [weak self] error in
            guard let self = self else {return}
            UIAlertController.showErrorMessage(error: error, from: self)
            self.footView.subviews.last?.isUserInteractionEnabled = true
        }.finally { [weak self] in
            guard let self = self else { return }
            self.footView.subviews.first?.isUserInteractionEnabled = true
            LoadingView.hideLoadingViewInView(view: self.view)
        }
    }
    
    //MARK: - submit
    @objc private func submitExpense() {
        submitForm(isDraft: false)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
        self.searchTipsView.hide()
        self.currencyView.hide()
    }
}
