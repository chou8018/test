//
//  THExpenseDetailViewController.swift
//  ClaimApp
//
//  Created by 付耀辉 on 2022/9/28.
//

import UIKit
import TLPhotoPicker
import AlamofireImage
import SnapKit
import CoreMedia
import PromiseKit
import IQKeyboardManagerSwift

class THExpenseDetailViewController: CABaseViewController {
    
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    
    var dropInfo: CAExpenceDropInfo!
    var currencyInfo:CACurrencyInfo?
    
    let tableIdentifierCell = "tableIdentifierCell1"
    
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
                
    var notSubmitData: LNListData?
    var draftInfo: CAExpenseDraft!

    init(type: CAExpensesType, data: LNListData) {
        super.init(nibName: nil, bundle: nil)
        self.expensesType = type
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "Expense"

        initData()
        initDraftData()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
    }
        
    
    func attributteTitle() -> NSAttributedString {
        
        let content = NSString(string: draftInfo?.description ?? "")
        let boldText = draftInfo?.description?.split(separator: ".").first?.description ?? ""
        let attribute = NSMutableAttributedString(string: content as String)
        let range = content.range(of: boldText)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(hexValue: 0x161C24), range: NSRange(location: 0, length: content.length))
        attribute.addAttribute(NSAttributedString.Key.font, value: UIFont.mediumCustomFont(ofSize: 14), range: NSRange(location: 0, length: content.length))
        attribute.addAttribute(NSAttributedString.Key.font, value: UIFont.demiBoldCustomFont(ofSize: 14), range: range)
        return attribute
    }
    
    
    private func initDraftData() {
        
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
        tableView.register(UINib.init(nibName: "THExpemseDetailCell", bundle: nil), forCellReuseIdentifier: tableIdentifierCell)
    }
    
    func initResourceData() {
        if dropInfo == nil {
            return
        }
        infoLabel.attributedText = attributteTitle()
        infoLabel.superview?.setShadow(sColor: .lightGray, offset: CGSize(width: 0, height: 1), opacity: 0.3, radius: 5)
        
        let size = infoLabel.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width-32*2, height: CGFloat.greatestFiniteMagnitude))
        let topHeight = size.height + 30 + 15
        
        tableView.contentInset = UIEdgeInsets(top: topHeight, left: 0, bottom: 0, right: 0)
        if let sup = infoLabel.superview {
            sup.removeFromSuperview()
//            tableView.insertSubview(sup, at: 0)
            tableView.addSubview(sup)
            let size = infoLabel.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width-32*2, height: CGFloat.greatestFiniteMagnitude))
            sup.snp.makeConstraints { make in
                make.top.equalToSuperview().offset( -topHeight + 20)
                make.width.equalTo(UIScreen.main.bounds.width-32)
                make.centerX.equalToSuperview()
                make.height.greaterThanOrEqualTo(30+size.height)
            }
        }

        
        datas.removeAll()
        
        let forData0 = THCostItemData(localizedTitleKey: "")
        if let total = draftInfo.total {
            
            forData0.subtotal = String(format: "%.2f", total.amount.floatValue).conversionOfDigital(separator: self.currencyInfo?.amount_separator)
            forData0.totalVAT = total.tax_amount == 0 ? "-":String(format: "%.2f", total.tax_amount.floatValue).conversionOfDigital(separator: self.currencyInfo?.amount_separator)
            forData0.grandTotal = String(format: "%.2f", total.gross_amount.floatValue).conversionOfDigital(separator: self.currencyInfo?.amount_separator)
        }
        datas.append([forData0])
        
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
        if let draftInfo = draftInfo , let invoiceNumber = draftInfo.invoice_number {
            formData2.text = invoiceNumber
        } else {
            formData2.text = "-"
        }

        let formData_invoiceDate = DateFormFieldData(localizedTitleKey: .localized("new_expenses_title_date", comment: ""))
        formData_invoiceDate.placeholder = .localized("new_expenses_title_date_placeholder", comment: "")
        if expensesType == .personal {
            formData_invoiceDate.title = "Date of Expenditure"
            formData_invoiceDate.placeholder = "Select the date of expenditure"
        }
        formData_invoiceDate.required = true
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
            }else{
                formData_due.text = "-"
            }
        }
        
        let paymentCurrency = PaymentCurrencyData(localizedTitleKey: "Payment Currency")
        paymentCurrency.currency = dropInfo.currencies?.default
        
        if expensesType == .personal {
            datas.append([formData_invoiceDate, formData_due,paymentCurrency])
        }else{
            datas.append([formData1, formData2, formData_invoiceDate, formData_due,paymentCurrency])
        }

        
        if let draftInfo = draftInfo {
            let amountItems = draftInfo.items ?? []
            var amounts = [ItemsFormFieldData]()

            for index in 0..<amountItems.count {
                let amountItem = amountItems[index]
                
                let itemFormData = ItemsFormFieldData(localizedTitleKey: "\(String.localized("new_expenses_title_Item", comment: "")) \(index+1)")
                
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
                if let tax_amount = amountItem.tax_amount?.replacingOccurrences(of: amountItem.currency?.amount_separator ?? ",", with: "") {
                    if let double = Double(tax_amount), double > 0.00 {
                        item2.text = amountItem.tax_amount
                    }else{
                        item2.text = "-"
                    }
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
                if let categoryText = amountItem.category?.title {
                    item4.text = categoryText
                } else {
                    item4.text = "-"
                }
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
                itemFormData.status = amountItem.status
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
        formData5.required = true
        datas.append([formData5])
        if let draftInfo = draftInfo, let files = draftInfo.receipt_files, !files.isEmpty {
            formData5.images = files
        }
        
        var lastSection = [FormFieldData]()
        let formData6 = DropdownFormFieldData(localizedTitleKey: .localized("new_expenses_title_payment", comment: ""))
        formData6.required = true
        formData6.placeholder = .localized("new_expenses_title_payment_placeholder", comment: "")
        lastSection.append(formData6)
        
        if let draftInfo = draftInfo {
            formData6.text = draftInfo.payee?.title
            
            if let bank = draftInfo.payee?.bank, let display_name = bank.display_name, let account_no = bank.account_no {
                let formData1_1 = TextFormFieldData(localizedTitleKey: .localized("new_expenses_title_bank", comment: ""))
                formData1_1.editable = false
                formData1_1.placeholder = .localized("new_expenses_title_bank_placeholder", comment: "")
                formData1_1.text = display_name
                lastSection.append(formData1_1)

                let formData1_2 = TextFormFieldData(localizedTitleKey: .localized("new_expenses_title_bank_no.", comment: ""))
                formData1_2.editable = false
                formData1_2.placeholder = .localized("new_expenses_title_bank_no._placeholder", comment: "")
                formData1_2.text = account_no
                lastSection.append(formData1_2)
            }
        }
        datas.append(lastSection)
        tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var theCell: THExpemseDetailCell?
    
}

extension THExpenseDetailViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return draftInfo == nil ? 0:1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: tableIdentifierCell, for: indexPath) as! THExpemseDetailCell
        cell.initResource(datas: datas, draft: draftInfo, expensesType: expensesType)
        cell.selectionStyle = .none
        theCell = cell
        return cell
    }
}

extension THExpenseDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        LNDebugPrint(item: "aaa   -   \(draftInfo.rowHeight)")
        return draftInfo.rowHeight
//        (theCell?.mainTableView.contentSize.height ?? 0) + 70+16
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        LNDebugPrint(item: (tableView.visibleCells.first as?  THExpemseDetailCell)?.mainTableView.contentSize)
    }
    
}

    //MARK: - selectors
extension THExpenseDetailViewController {
    
    @objc func pop() {
        self.navigationController?.popViewController(animated: true)
    }
}
