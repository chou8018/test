//
//  CACreateProfileCell.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/27.
//

import UIKit
import SnapKit

class CACreateProfileCell: UITableViewCell ,InitializableFromNib {
    
    static var nibName: String = "CACreateProfileCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var iconButton: UIButton!
    
    @IBOutlet weak var textFieldTrailngConstraint: NSLayoutConstraint!
    var data: FormFieldData!
    
    lazy var picker: UIPickerView = {
       return UIPickerView()
    }()
    
    var onTextFieldTextDidChange: ((String?)->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        NotificationCenter.default.addObserver(self, selector: #selector(CACreateProfileCell.handleTextFieldTextDidChange(notification:)), name: UITextField.textDidChangeNotification, object: textField)
        
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


extension CACreateProfileCell: FormFieldDataUI {
        
    func bind(data: FormFieldData) {
        
        self.textField.textColor = .black
        self.textField.isHidden = false
        self.textField.isSecureTextEntry = false
        textFieldTrailngConstraint.constant = 0
        
        let downButton = iconButton!
//        downButton.setImage(UIImage(named: "icon-arrow"), for: .normal)

        self.data = data
        if data.isShowErrorMsg {
            textField.superview?.borderColor = .cRemindRed
        }else{
            self.textField.superview?.borderColor = .init(hexValue: 0xC4CDD5)
        }
        
        if data.required {
            titleLabel.attributedText = NSAttributedString.addRequireStatus(string: data.title)

        } else {
            titleLabel.text = data.title
        }
        textField.tintColor = .cPrimary
        textField.placeholder = data.placeholder
        if let dropdownData =  data as? DropdownFormFieldData {
            textField.tintColor = .clear
            textField.autocorrectionType = .no
            textField.spellCheckingType = .no
            textField.inputView = picker
            textField.delegate = dropdownData
            picker.dataSource = dropdownData
            picker.delegate = dropdownData
            if let index = dropdownData.selectedIndex , dropdownData.items.count > index {
                textField.text = dropdownData.selectedIndex.map {
                    dropdownData.items[$0].name
                }
            }
            downButton.isHidden = false
            downButton.isUserInteractionEnabled = false
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
                
                NotificationCenter.default.post(name: CountryChooseLastOption, object: dropdownData, userInfo: nil)
            }
            
        }else{
            
            textField.delegate = nil
            downButton.isHidden = true
            textField.text = data.text
            textField.inputView = nil
            textField.keyboardType = data.keyboardType
            textField.isSecureTextEntry = data.isPassword
            
            if data.isPassword {
                downButton.isHidden = false
                
                let image = UIImage(named: "eye-filled")
                if data.canSeePassword {
                    downButton.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
                } else {
                    downButton.setImage(image, for: .normal)
                }
                textField.isSecureTextEntry = !data.canSeePassword
            
                downButton.addTarget(self, action: #selector(downButtonClicked), for: .touchUpInside)
                downButton.isUserInteractionEnabled = true
                textFieldTrailngConstraint.constant = 35
    
            }
            onTextFieldTextDidChange = { [weak self] text in
                guard let `self` = self else { return }
                data.text = text
                data.hasBeenEdited = true
                if data.isShowErrorMsg {
                    self.textField.superview?.borderColor = .init(hexValue: 0xC4CDD5)
                    data.isShowErrorMsg = false
                }
                
                NotificationCenter.default.post(name: FormTextDidChanged, object: data, userInfo: nil)
            }
        }
    }
    
    @objc func downButtonClicked(sender: UIButton) {
        
        if data.title == String.localized("create_profile_form_password", comment: "") || data.title == String.localized("create_profile_form_confirm_password", comment: "") {
            textField.isSecureTextEntry = self.data.canSeePassword
            self.data.canSeePassword = !self.data.canSeePassword
            let image = UIImage(named: "eye-filled")
            if self.data.canSeePassword {
                sender.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                sender.setImage(image, for: .normal)
            }
        }
    }
    
    @objc func textFieldtextDidBegin(sender: UITextField) {
        if let vc = viewContainingController() as? CANewExpensesViewController {
            vc.searchTipsView.hide()
        }
        if let dropdownData = data as? DropdownFormFieldData, dropdownData.items.count > 0 {
            if dropdownData.selectedIndex == nil {
                dropdownData.selectedIndex = 0
            }
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
    }
}
