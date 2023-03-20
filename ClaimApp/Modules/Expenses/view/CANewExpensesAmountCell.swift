//
//  CANewExpensesAmountCell.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/27.
//

import UIKit


class CANewExpensesAmountCell: UITableViewCell ,InitializableFromNib {
    
    static var nibName: String = "CANewExpensesAmountCell"
    @IBOutlet weak var itemStatus: PaddingLabel!

    //    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var taxField: UITextField!
    @IBOutlet weak var grossField: UITextField!
    @IBOutlet weak var carplate: UITextField!
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var descrip: GrowingTextView!
    
    @IBOutlet weak var item2View: UIView!
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var select1Button: UIButton!
    @IBOutlet weak var select2Button: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    
    static var baseRowHeight:CGFloat = 252
    
    @IBOutlet weak var currencyButton: UIButton!
    @IBOutlet weak var currencyImage: UIImageView!
    
    @IBOutlet weak var currency2Button: UIButton!
    @IBOutlet weak var currency2Image: UIImageView!
    
    @IBOutlet weak var currency3Button: UIButton!
    @IBOutlet weak var currency3Image: UIImageView!

    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    
    //    @IBOutlet weak var textViewConstraint: NSLayoutConstraint!
    
    var lastHeight:CGFloat = 30
    
    public var data: ItemsFormFieldData!
    
    lazy var picker: UIPickerView = {
        return UIPickerView()
    }()
    
    var onDatePickerValueDidChange: ((Date)->())?
    var onTextFieldTextDidChange: ((String?, UITextField)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CANewExpensesAmountCell.handleTextFieldTextDidChange(notification:)), name: UITextField.textDidChangeNotification, object: textField)
        NotificationCenter.default.addObserver(self, selector: #selector(CANewExpensesAmountCell.handleTextFieldTextDidChange(notification:)), name: UITextField.textDidChangeNotification, object: taxField)
        NotificationCenter.default.addObserver(self, selector: #selector(CANewExpensesAmountCell.handleTextFieldTextDidChange(notification:)), name: UITextField.textDidChangeNotification, object: carplate)
        NotificationCenter.default.addObserver(self, selector: #selector(CANewExpensesAmountCell.handleTextFieldTextDidChange(notification:)), name: UITextField.textDidChangeNotification, object: category)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(CANewExpensesAmountCell.handleTextFieldTextDidBeginEditing(notification:)), name: UITextField.textDidBeginEditingNotification, object: carplate)
        NotificationCenter.default.addObserver(self, selector: #selector(CANewExpensesAmountCell.handleTextFieldTextDidBeginEditing(notification:)), name: UITextField.textDidBeginEditingNotification, object: category)
        NotificationCenter.default.addObserver(self, selector: #selector(CANewExpensesAmountCell.handleTextFieldTextDidBeginEditing(notification:)), name: UITextField.textDidBeginEditingNotification, object: textField)
        NotificationCenter.default.addObserver(self, selector: #selector(CANewExpensesAmountCell.handleTextFieldTextDidBeginEditing(notification:)), name: UITextField.textDidBeginEditingNotification, object: taxField)

        NotificationCenter.default.addObserver(self, selector: #selector(CANewExpensesAmountCell.didSelectCurrency(notification:)), name: DraftDidChooseCurrency, object: nil)
        
        
        category.addTarget(self, action: #selector(textFieldtextDidBegin(sender:)), for: .editingDidBegin)
        category.addTarget(self, action: #selector(textFieldtextDidBegin(sender:)), for: .editingDidBegin)
        
        textField.delegate = self
        taxField.delegate = self

        descrip.layer.cornerRadius = 4.0
        descrip.font = UIFont.systemFont(ofSize: 15)
        descrip.minHeight = 0
        descrip.delegate = self
        descrip.text = nil
        
        
        for image in [currencyImage, currency2Image, currency3Image] {
            image?.borderWidth = 1
            image?.borderColor = .init(hexValue: 0xc4cdd5)
        }
        
        for button in [currencyButton, currency2Button, currency3Button] {
            button?.layout(style: .left, space: 55)
            button?.titleLabel?.font = .mediumCustomFont(ofSize: 14)
            button?.setTitleColor(.hexColorWithAlpha(color: "#161C24"), for: .normal)
            button?.layout(style: .left, space: 50)
        }
        
        itemStatus.font = .mediumCustomFont(ofSize: 12)
        //        if amountLabel.text == AppDataHelper.currencyCode.rawValue {
        //            if AppDataHelper.countryCode == .ID {
        //                amountLabel.text = "Rp"
        //            }
        //        }
    }
    
    func configData(data: CANewExpensesNormalData) {
        category.becomeFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func currencyAction(_ sender: UIButton) {
        
        if let superVc = self.viewContainingController() as? CANewExpensesViewController {
            if superVc.currencyView.isShowing {
                superVc.currencyView.hide()
                return
            }
            superVc.currencyView.show(pointView: sender)
            superVc.currencyView.target = Target(target: self, selector: #selector(CANewExpensesAmountCell.didSelectCurrency(obj:)))
        }
    }
    
    @objc func didSelectCurrency(obj: Any) {
        if let model = obj as? CACurrencyInfo {
            NotificationCenter.default.post(name: DraftDidChooseCurrency, object: model)
        }
    }
    
    
    @IBAction func beginEditing(_ sender: Any) {
    }
    
    @objc func textFieldtextDidBegin(sender: UITextField) {
        
        if let dropdownData = data.items[2] as? DropdownFormFieldData, dropdownData.items.count > 0 {
            if dropdownData.selectedIndex == nil {
                dropdownData.selectedIndex = 0
            }
        }
    }
    
    @objc private func handleTextFieldTextDidBeginEditing(notification: Notification) {
        if let vc = viewContainingController() as? CANewExpensesViewController {
            vc.searchTipsView.hide()
        }
    }
    
    
    @objc private func didSelectCurrency(notification: Notification) {
        
        guard let model = notification.object as? CACurrencyInfo, let url = URL(string: model.flag) else {
            return
        }
        
        data.items.first?.text = ""
        textField.text = nil
        taxField.text = nil

        currencyImage.af_setImage(withURL: url)
        currency2Image.af_setImage(withURL: url)
        
        currencyButton.setTitle(model.currency_code, for: .normal)
        currency2Button.setTitle(model.currency_code, for: .normal)

        data.currencyCode = model.currency_code
        data.currencyInfo = model
        
        if let superVc = self.viewContainingController() as? CANewExpensesViewController {
            superVc.currencyInfo = model
        }
        
        let placeholder = data.currencyInfo?.default_amount ?? ""
        let usedString = NSString(string:placeholder + " *")
        let attribute = NSMutableAttributedString(string:usedString as String)
        let range = NSRange(location: 0, length: placeholder.count)
        attribute.addAttributes([NSAttributedString.Key.foregroundColor:UIColor.init(hexValue: 0x000000)], range: range)
        let theRange = usedString.range(of: "*")
        attribute.addAttributes([NSAttributedString.Key.foregroundColor:UIColor.cRemindRed], range: theRange)
        textField.attributedPlaceholder = attribute
        
        let attributeTax = NSMutableAttributedString(string:placeholder)
        let rangeTax = NSRange(location: 0, length: placeholder.count)
        attributeTax.addAttributes([NSAttributedString.Key.foregroundColor:UIColor.init(hexValue: 0x000000)], range: rangeTax)
        taxField.attributedPlaceholder = attributeTax
    }
    
    
    @objc private func handleTextFieldTextDidChange(notification: Notification) {
        
        if (notification.object as? UITextField) == category, let searchData = data.items[3] as? SearchFormFieldData, let text = category.text {
            searchData.text = text
            searchData.selectedItem = nil
            NotificationCenter.default.post(name: SearchFieldDidBeginSearch, object: ["data": searchData, "cell": self, "searchText": text])
            return
        }else if (notification.object as? UITextField) == carplate, let searchData = data.items[2] as? SearchFormFieldData, let text = carplate.text {
            searchData.text = text
            searchData.selectedItem = nil
            NotificationCenter.default.post(name: SearchFieldDidBeginSearch, object: ["data": searchData, "cell": self, "searchText": text])
            return
        }
        
        guard let textField = notification.object as? UITextField else {
            return
        }
        if textField == self.textField || textField == self.taxField {
            let item = textField == self.textField ? data.items[0] : data.items[1]
            if let text = textField.text?.replacingOccurrences(of: AppDataHelper.getSeparator(data.currencyCode), with: ""), let itemData = item as? TextFormFieldData {
                itemData.isShowErrorMsg = false
                textField.superview?.borderColor = .init(hexValue: 0xC4CDD5)
                let amountText = text.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: ".", with: "")
                if let doubleValue = Double(amountText), doubleValue > 0  {
                    if let currency = CurrencyCode.init(rawValue: data.currencyCode){
                        
                        switch currency {
                        case .SGD, .THB, .CNY, .MYR, .USD:
                            textField.text = String(format: "%.2f", doubleValue/100.00).conversionOfDigital(separator: AppDataHelper.getSeparator(data.currencyCode), unit: "")
                            itemData.text = String(format: "%.2f", doubleValue/100.00)
                            break
                        case .IDR, .JPY:
                            textField.text = amountText.conversionOfDigital(separator: AppDataHelper.getSeparator(data.currencyCode), unit: "")
                            itemData.text = amountText
                        default:
                            textField.text = Int(doubleValue).conversionOfDigital(separator: AppDataHelper.getSeparator(data.currencyCode), unit: "")
                            itemData.text = "\(Int(doubleValue))"
                            break
                        }
                    }else {
                        textField.text = String(format: "%.2f", doubleValue/100.00).conversionOfDigital(separator: AppDataHelper.getSeparator(data.currencyCode), unit: "")
                        itemData.text = String(format: "%.2f", doubleValue/100.00)
                    }
                }else{
                    textField.text = ""
                    itemData.text = ""
                }
                data.hasBeenEdited = true
                return
            }else{
                textField.text = ""
            }
        }
        onTextFieldTextDidChange?(textField.text, textField)
    }
    
    
    @objc private func handleDatePickerValueDidChange(sender: UIDatePicker) {
        onDatePickerValueDidChange?(sender.date)
    }
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetSubviews()
    }
    
    private func resetSubviews() {
        titleLabel.text = nil
        textField.text = nil
        textField.inputView = nil
        textField.delegate = nil
        textField.isEnabled = true
        textField.keyboardType = .default
        
        picker.dataSource = nil
        picker.delegate = nil
        
        onTextFieldTextDidChange = nil
        onDatePickerValueDidChange = nil
        categoryLabel.isHidden = true
        categoryLabel.text = nil
    }
    
}

extension CANewExpensesAmountCell: FormFieldDataUI {
    
    func bind(data: FormFieldData) {
        
        titleLabel.text = data.title
        self.textField.textColor = .black
        self.textField.isHidden = false
        
        guard let itemData = data as? ItemsFormFieldData else {
            return
        }
        
        if let _ = itemData.status {
            itemStatus.isHidden = false
            removeButton.isHidden = true
            let titleAndColor = itemData.itemTitleAndColor()
            itemStatus.text = titleAndColor.0
            itemStatus.textColor = titleAndColor.1
        }else{
            itemStatus.isHidden = true
            removeButton.isHidden = false
        }
        
        self.data = itemData
        item2View.isHidden = itemData.isPersonal
//        if itemData.isPersonal {
//            itemData.items[1].required = false
//        }else{
//            itemData.items[1].required = true
//        }
        
        if let item = itemData.items.last {
            descrip.isOnlyShowing = self.data.status != nil
            descrip.text = item.text
            descrip.placeholder = item.placeholder
            
            let isFromNew = viewContainingController() is CANewExpensesViewController
            let detailHeight:CGFloat = isFromNew ? 0: itemData.items.count > 4 ? 46:-46
            if isFromNew {
                grossField.superview?.isHidden = isFromNew
            }else{
                if itemData.items.count > 4 {
                    grossField.superview?.isHidden = false
                    taxField.superview?.isHidden = false
                }else{
                    grossField.superview?.isHidden = true
                    taxField.superview?.isHidden = true
                }
            }
            
            if let _ = self.data.status, item.text?.isEmpty ?? true {
                descrip.superview?.borderColor = .clear
                itemData.rowHeight = CANewExpensesAmountCell.baseRowHeight-30-12 + detailHeight
                bottomSpace.constant = 0
            }else{
                descrip.superview?.borderColor = .init(hexValue: 0xC4CDD5)
                let borderSpaace:CGFloat = 32 + 45
                let size = descrip.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - borderSpaace, height: CGFloat.greatestFiniteMagnitude))
                
                let descripBaseHeight:CGFloat = 32
                itemData.rowHeight = CANewExpensesAmountCell.baseRowHeight+size.height-descripBaseHeight + detailHeight
                bottomSpace.constant = 10
            }
        }
        
        var textFields = [textField, taxField, carplate, category]
        if itemData.items.count == 6 {
            textFields.insert(grossField, at: 2)
        }
        if itemData.items.count == 4 {
            textFields.remove(at: 1)
        }
        for index in 0..<itemData.items.count-1 {
            let field = textFields[index]!
            field.tag = 100+index
            let item = itemData.items[index]
            if item.isShowErrorMsg {
                field.superview?.borderColor = .cRemindRed
            }else{
                field.superview?.borderColor = .init(hexValue: 0xC4CDD5)
            }
            
            if item.required, var placeholder = item.placeholder {
                if item.keyboardType == .decimalPad {
                    placeholder = itemData.currencyInfo?.default_amount ?? ""
                }
                let usedString = NSString(string:placeholder + " *")
                let attribute = NSMutableAttributedString(string:usedString as String)
                if field == textField {
                    let range = NSRange(location: 0, length: placeholder.count)
                    attribute.addAttributes([NSAttributedString.Key.foregroundColor:UIColor.init(hexValue: 0x000000)], range: range)
                    field.attributedPlaceholder = attribute
                    currencyButton.setTitle(self.data.currencyInfo?.currency_code, for: .normal)
                    currency2Button.setTitle(self.data.currencyInfo?.currency_code, for: .normal)
                    currency3Button.setTitle(self.data.currencyInfo?.currency_code, for: .normal)
                    if let url = URL(string: self.data.currencyInfo?.flag ?? "") {
                        currencyImage.af_setImage(withURL: url)
                        currency2Image.af_setImage(withURL: url)
                        currency3Image.af_setImage(withURL: url)
                    }
                }
                
                let theRange = usedString.range(of: "*")
                attribute.addAttributes([NSAttributedString.Key.foregroundColor:UIColor.cRemindRed], range: theRange)
                field.attributedPlaceholder = attribute
                
            } else {
                if item.keyboardType == .decimalPad {
                    let placeholder = itemData.currencyInfo?.default_amount ?? ""
                    let usedString = NSString(string:placeholder)
                    let attribute = NSMutableAttributedString(string:usedString as String)
                    let range = NSRange(location: 0, length: placeholder.count)
                    attribute.addAttributes([NSAttributedString.Key.foregroundColor:UIColor.init(hexValue: 0x000000)], range: range)
                    field.attributedPlaceholder = attribute
                }else{
                    field.placeholder = item.placeholder
                }
            }
            
            if let dropdownData =  item as? DropdownFormFieldData {
                
                if dropdownData.title == "category" {
                    categoryLabel.isHidden = false
                } else {
                    categoryLabel.isHidden = true
                }
                
                field.autocorrectionType = .no
                field.spellCheckingType = .no
                field.inputView = picker
                field.delegate = dropdownData
                picker.dataSource = dropdownData
                picker.delegate = dropdownData
                field.text = dropdownData.selectedIndex.map { dropdownData.items[$0].name }
                
                dropdownData.onSelectedIndexDidChange = { [unowned dropdownData] (_, newIndex) in
                    
                    data.hasBeenEdited = true
                    field.text = newIndex.map { dropdownData.items[$0].name }
                    dropdownData.text = field.text
                    if item.isShowErrorMsg {
                        item.isShowErrorMsg = false
                        field.superview?.borderColor = .init(hexValue: 0xC4CDD5)
                    }
                    
                    if dropdownData.title == "category" {
                        self.categoryLabel.text = field.text
                        self.category.text = " "
                    }
                }
                
            }else{
                
                field.text = item.text
                field.keyboardType = item.keyboardType
                field.inputView = nil
                if field != textField {
                    field.delegate = nil
                }else{
                    field.keyboardType = .decimalPad
                    field.delegate = self
                    if item.text?.contains(itemData.currencyInfo?.amount_separator ?? "") ?? false && item.text?.contains(".") ?? false {
                        
                    }else{
                        if let text = item.text, !text.isEmpty, !data.isDetail {
                            field.text = item.text?.conversionOfDigital(separator: AppDataHelper.getSeparator(itemData.currencyCode), unit: "")
                        }
                    }
                }
                
                onTextFieldTextDidChange = { text, textField in
                    //                    guard let `self` = self else { return }
                    itemData.items[textField.tag - 100].text = text
                    data.hasBeenEdited = true
                    if itemData.items[textField.tag - 100].isShowErrorMsg {
                        item.isShowErrorMsg = false
                        textField.superview?.borderColor = .init(hexValue: 0xC4CDD5)
                    }
                }
            }
        }
    }
}

extension CANewExpensesAmountCell: GrowingTextViewDelegate {
    
    // *** Call layoutIfNeeded on superview for animation when changing height ***
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        data.rowHeight = CANewExpensesAmountCell.baseRowHeight-35+height
        if self.data.items.last?.hasBeenEdited == true {
            NotificationCenter.default.post(name: DraftDescriptionIsChanged, object: ["heightDifference":height-lastHeight, "cell": self])
        }
        lastHeight = height
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func textViewEndEditing(_ textView: GrowingTextView) {
        
    }
    
    func textViewDidChanged(_ textView: GrowingTextView) {
        data.items.last?.text = textView.text
        data.items.last?.hasBeenEdited = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let vc = viewContainingController() as? CANewExpensesViewController {
            vc.searchTipsView.hide()
        }
    }
}

extension CANewExpensesAmountCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "." {
            return false
        }
        let futureString: NSMutableString = NSMutableString(string: textField.text!)
        futureString.insert(string, at: range.location)
        if textField.text?.count ?? 0 >= 15 && !string.isEmpty {
            return false
        }
        return true
        
        if AppDataHelper.countryCode == .ID {
            return true
        }
        if let text = textField.text, text.contains("."), string == "." {
            return false
        }
         var flag = 0;
         
         let limited = 2;//小数点后需要限制的个数
         
         if !futureString.isEqual(to: "") {
             for i in stride(from: (futureString.length - 1), through: 0, by: -1) {
                 let char = Character(UnicodeScalar(futureString.character(at: i))!)
                 if char == "." {
                     if flag > limited {
                         return false
                     }
                     break
                 }
                 flag += 1
             }
         }
         return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        LNDebugPrint(item: "xxxx")
    }
    
}
