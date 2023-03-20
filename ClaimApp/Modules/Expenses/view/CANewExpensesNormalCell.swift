//
//  CANewExpensesNormalCell.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/27.
//

import UIKit

class CANewExpensesNormalCell: UITableViewCell ,InitializableFromNib {
    
    static var nibName: String = "CANewExpensesNormalCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    
    var data: FormFieldData!
    
    lazy var picker: UIPickerView = {
       return UIPickerView()
    }()
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        
        datePicker.locale = Locale.init(identifier: AppDataHelper.languageCode?.rawValue ?? "en")
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        return datePicker
    }()
    
    var onDatePickerValueDidChange: ((Date)->())?
    var onTextFieldTextDidChange: ((String?)->())?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        NotificationCenter.default.addObserver(self, selector: #selector(CANewExpensesNormalCell.handleTextFieldTextDidChange(notification:)), name: UITextField.textDidChangeNotification, object: textField)
        datePicker.addTarget(self, action: #selector(CANewExpensesNormalCell.handleDatePickerValueDidChange(sender:)), for: .valueChanged)
        datePicker.addTarget(self, action: #selector(CANewExpensesNormalCell.handleDatePickerValueDidChange(sender:)), for: .editingDidBegin)
        
        textField.addTarget(self, action: #selector(textFieldtextDidBegin(sender:)), for: .editingDidBegin)
    }
    
    func configData(data: CANewExpensesNormalData) {
        titleLabel.text = data.title
        textField.placeholder = data.placeholder
        iconButton.setImage(data.icon, for: .normal)
        textField.text = data.text
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}


extension CANewExpensesNormalCell: FormFieldDataUI {
        
    func bind(data: FormFieldData) {
        
        self.textField.textColor = .black
        self.textField.isHidden = false
        self.textField.isEnabled = data.editable

        let downButton = iconButton!
        self.data = data
        if data.isShowErrorMsg {
            textField.superview?.borderColor = .cRemindRed
        }else{
            self.textField.superview?.borderColor = .init(hexValue: 0xC4CDD5)
        }
        
        if data.required , !data.isDetail {
            titleLabel.attributedText = NSAttributedString.addRequireStatus(string: data.title)
        } else {
            titleLabel.text = data.title
        }
        
        if data.title.isEmpty {
            titleHeightConstraint.constant = 0
        } else {
            titleHeightConstraint.constant = 22
        }
        
        textField.tintColor = .cPrimary
        textField.placeholder = data.placeholder
        if let dateData = data as? DateFormFieldData {
            textField.tintColor = .clear

            textField.inputView = datePicker
            
            datePicker.datePickerMode = dateData.datePickerMode
            datePicker.minimumDate = dateData.minimumDate
            if let formatter = dateData.dateFormatter {
                self.textField.text = dateData.selectedDate?.string(with: formatter)
            }
            onDatePickerValueDidChange = { date in
                dateData.selectedDate = date
            }
            self.textField.text = dateData.text
            downButton.isHidden = false
            downButton.setImage(UIImage(named: "icon-calendar"), for: .normal)
            dateData.onSelectedDateDidChange = { [weak self, unowned dateData] (_, newDate) in
                guard let `self` = self else { return }
                self.textField.text = dateData.formattedDateString
                
                if let formatter = dateData.dateFormatter {
                    self.textField.text = newDate?.string(with: formatter)
                }
                dateData.hasBeenEdited = true
                if let formatter = dateData.dateFormatter {
                    dateData.text = newDate?.string(with: formatter)
                }
                
                if data.isShowErrorMsg {
                    data.isShowErrorMsg = false
                    self.textField.superview?.borderColor = .init(hexValue: 0xC4CDD5)
                }
            }
            
        }else if let dropdownData =  data as? DropdownFormFieldData ,dropdownData.items.count > 0 {
            textField.tintColor = .clear
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
            textField.inputView = picker
            textField.delegate = dropdownData
            picker.dataSource = dropdownData
            picker.delegate = dropdownData
            textField.text = dropdownData.selectedIndex.map {
                dropdownData.items[$0].name
            }
            
            downButton.isHidden = false
            downButton.setImage(UIImage(named: "icon-arrow"), for: .normal)
            dropdownData.onSelectedIndexDidChange = { [weak self, unowned dropdownData] (_, newIndex) in
                guard let `self` = self else { return }
                self.textField.text = newIndex.map { dropdownData.items[$0].name }
                dropdownData.hasBeenEdited = true
                dropdownData.text = self.textField.text
                if data.isShowErrorMsg {
                    data.isShowErrorMsg = false
                    self.textField.superview?.borderColor = .init(hexValue: 0xC4CDD5)
                }
                
                NotificationCenter.default.post(name: PaymentChooseLastOption, object: dropdownData, userInfo: nil)
            }
            
        }else{
            
            textField.delegate = nil
            downButton.isHidden = true
            textField.text = data.text
            textField.inputView = nil
            textField.keyboardType = data.keyboardType

            onTextFieldTextDidChange = { [weak self] text in
                guard let `self` = self else { return }
                data.text = text
                data.hasBeenEdited = true
                if data.isShowErrorMsg {
                    self.textField.superview?.borderColor = .init(hexValue: 0xC4CDD5)
                    data.isShowErrorMsg = false
                }
            }
        }
    }
    
    @objc func textFieldtextDidBegin(sender: UITextField) {
//        if let searchData = data as? SearchFormFieldData {
//            textField.text = searchData.selectedItem?.title
//        }
        if let vc = viewContainingController() as? CANewExpensesViewController {
            vc.searchTipsView.hide()
        }
        if let dropdownData = data as? DropdownFormFieldData, dropdownData.items.count > 0 {
            if dropdownData.selectedIndex == nil && dropdownData.title != "Payment to" {
                dropdownData.selectedIndex = 0
            }
        }
        if data is DateFormFieldData {
            onDatePickerValueDidChange?(Date())
        }
    }
    
//    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//
//        if let _ = data as? TextFormFieldData {
//            return true
//        }
//
//        LNDebugPrint(item: action)
//
//        return super.canPerformAction(action, withSender: sender)
//    }

    
    @objc private func handleTextFieldTextDidChange(notification: Notification) {
    
        if let searchData = data as? SearchFormFieldData, let text = textField.text {
            searchData.text = text
            searchData.selectedItem = nil
            NotificationCenter.default.post(name: SearchFieldDidBeginSearch, object: ["data": searchData, "cell": self, "searchText": text])
            return
        }
        onTextFieldTextDidChange?(textField.text)
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
        
        iconButton.isHidden = true
        onTextFieldTextDidChange = nil
        onDatePickerValueDidChange = nil
    }

    
}
