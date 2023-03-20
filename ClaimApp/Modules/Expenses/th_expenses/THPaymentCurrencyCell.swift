//
//  THPaymentCurrencyCell.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/27.
//

import UIKit

class THPaymentCurrencyCell: UITableViewCell ,InitializableFromNib {
    
    static var nibName: String = "THPaymentCurrencyCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var iconButton: UIButton!
    
    @IBOutlet weak var currencyTitle: UILabel!
    @IBOutlet weak var currencySubtitle: UILabel!
    @IBOutlet weak var currencyImage: UIImageView!
    
    var data: FormFieldData!
    var selectedCurrency: CACurrencyInfo?
    var isDetail: Bool = false

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
        
        NotificationCenter.default.addObserver(self, selector: #selector(THPaymentCurrencyCell.handleTextFieldTextDidChange(notification:)), name: UITextField.textDidChangeNotification, object: textField)
        datePicker.addTarget(self, action: #selector(THPaymentCurrencyCell.handleDatePickerValueDidChange(sender:)), for: .valueChanged)
        datePicker.addTarget(self, action: #selector(THPaymentCurrencyCell.handleDatePickerValueDidChange(sender:)), for: .editingDidBegin)
        
        textField.addTarget(self, action: #selector(textFieldtextDidBegin(sender:)), for: .editingDidBegin)
    }
    
    func configData(data: CANewExpensesNormalData) {
        textField.placeholder = data.placeholder
        iconButton.setImage(data.icon, for: .normal)
        textField.text = data.text
    }
    
    @IBAction func currencyAction(_ sender: UIButton) {
        
        if let superVc = self.viewContainingController() as? THNewExpensesViewController {
            if superVc.currencyView.isShowing {
                superVc.currencyView.hide()
                return
            }
            superVc.currencyView.show(pointView: sender)
            superVc.currencyView.target = Target(target: self, selector: #selector(THPaymentCurrencyCell.didSelectCurrency(obj:)))
        }
    }
    
    @objc func didSelectCurrency(obj: Any) {
        
        guard let model = obj as? CACurrencyInfo, let url = URL(string: model.flag) else {
            return
        }
        
        if model.currency_code == self.selectedCurrency?.currency_code {
            return
        }
        
        currencyImage.af_setImage(withURL: url)
        currencyTitle.text = model.currency_name
        currencySubtitle.text = "(\(model.currency_code))"
        self.selectedCurrency = model
        NotificationCenter.default.post(name: DraftDidChooseCurrency, object: model)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}


extension THPaymentCurrencyCell: FormFieldDataUI {
        
    func bind(data: FormFieldData) {
        
        iconButton.isHidden = isDetail
        
        self.textField.textColor = .black
        self.textField.isEnabled = false
        if let useData = data as? PaymentCurrencyData , let model = useData.currency,let url = URL(string: model.flag) {
            currencyImage.af_setImage(withURL: url)
            currencyTitle.text = model.currency_name
            currencySubtitle.text = "(\(model.currency_code))"
            self.selectedCurrency = model
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
            if dropdownData.selectedIndex == nil {
                dropdownData.selectedIndex = 0
            }
        }
        if data is DateFormFieldData {
            onDatePickerValueDidChange?(Date())
        }
    }
    
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
        textField.text = nil
        textField.inputView = nil
        textField.delegate = nil
        textField.isEnabled = true
        textField.keyboardType = .default
        
        picker.dataSource = nil
        picker.delegate = nil
        
        iconButton.isHidden = false
        onTextFieldTextDidChange = nil
        onDatePickerValueDidChange = nil
    }

    
}
