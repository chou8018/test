//
//  AuctionFormField.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 25/12/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation
import UIKit

let FormFieldDataDidChangeNotification = Notification.Name(rawValue: "FormFieldDataDidChange")

let PaymentChooseLastOption = Notification.Name(rawValue: "PaymentChooseLastOption")

let loremIpsumMode: Bool = false

protocol FormFieldDataUI {
    func bind(data: FormFieldData)
}

class FormFieldData: NSObject {

    var title: String = ""
    var isShowErrorMsg = false
    var hasBeenEdited = false
    
    var text: String? = nil {
        didSet {
            NotificationCenter.default.post(name: FormFieldDataDidChangeNotification, object: self)
            onTextDidChange?(oldValue, text)
        }
    }
    
    var placeholder: String? = nil
    
    var required: Bool = false
    
    var editable: Bool = true
    
    var onTextDidChange: ((_ oldText: String?, _ newText: String?)->())?
    
    init(localizedTitleKey: String) {
        self.title = localizedTitleKey
        
        if loremIpsumMode {
            self.placeholder = localizedTitleKey
        }
        
    }
 
    var keyboardType: UIKeyboardType = .default
    var autocapitalizationType: UITextAutocapitalizationType = .words
    var isDetail = false
    var isPassword = false
    var canSeePassword = true

}

extension FormFieldData {
    
    @objc var isEmpty: Bool {
        guard let text = text?.trimmed, !text.isEmpty else { return true }
        return false
    }
    
    var isNumeric: Bool {
        return text?.trimmed.isNumeric ?? false
    }
    
}

class LongTextFormFieldData: FormFieldData {
 
    override init(localizedTitleKey: String) {
        super.init(localizedTitleKey: localizedTitleKey)
        
        if loremIpsumMode {
            text = String.randomSentence(maximumWords: 60, maxWordLength: 8)
        }
     
        autocapitalizationType = .sentences
    }
    
}

class TextFormFieldData: FormFieldData {
 
    var suffix: String? = nil
    var prefix: String? = nil
    
    var maxLength: String? = nil
    var max_length_tip_message: String? = nil
    var multiple_value: String? = nil
    var multiples_tip_message: String? = nil

    var defaultValue: String? = nil
    var defaultManagerId: String? = nil

    override init(localizedTitleKey: String) {
        super.init(localizedTitleKey: localizedTitleKey)
        
        if loremIpsumMode {
            text = String.randomSentence(maximumWords: 3, maxWordLength: 10)
        }
        
    }
    
}


class SearchFormFieldData: FormFieldData {
    
    var selectedItem: CADropdownItem?
}


class AddFormFieldData: FormFieldData {
    var imageName = ""
}


class ItemsFormFieldData: FormFieldData {
    
    var rowHeight:CGFloat = THNewExpensesAmountCell.baseRowHeight
    var currencyCode = ""
    var country_code = ""
    var country_id = ""
    var currencyInfo: CACurrencyInfo?
    var status: CurrencyItemStatus?
    var shouldCopy = true

    func itemTitleAndColor() -> (String?, UIColor, UIColor) {
        
        switch status {
//        case .pending:
//            return (nil, .clear)
////            return (String.localized("my_expenses_title_status_not_submitted", comment: ""), UIColor.hexColorWithAlpha(color: "#6E7882"))
        case .approved:
            fallthrough
        case .approved_lark:
            return ("Item " + String.localized("my_expenses_title_status_approved", comment: ""), UIColor.hexColorWithAlpha(color: "#4082FF"),UIColor.hexColorWithAlpha(color: "#F1F8FF"))
        case .rejected:
            fallthrough
        case .rejected_lark:
            return ("Item " + String.localized("my_expenses_title_status_rejected", comment: ""), UIColor.hexColorWithAlpha(color: "#F54165"), UIColor.hexColorWithAlpha(color: "#FFF3F6"))
        default:
            return (nil, UIColor.hexColorWithAlpha(color: "#4082FF"), UIColor.hexColorWithAlpha(color: "#F1F8FF"))
        }
    }
    
    var isPersonal = false
    var items = [FormFieldData]() {
        didSet{
//            let descrip = items.last?.text,
        }
    }
}

class PaymentCurrencyData: FormFieldData {
    var currency: CACurrencyInfo? = nil
}

class THCostItemData: FormFieldData {
    
    var subtotal:String?
    var totalVAT:String?
    var grandTotal:String?
    var currency: CACurrencyInfo? = nil
}

class PhoneFormFieldData: FormFieldData {
    
    override init(localizedTitleKey: String) {
        super.init(localizedTitleKey: localizedTitleKey)
    
        if loremIpsumMode {
            text = "\( arc4random_uniform(100_000_000) )"
        }
        
        keyboardType = .phonePad
        
    }
    
}


class NumericFormFieldData: FormFieldData {
    
    override init(localizedTitleKey: String) {
        super.init(localizedTitleKey: localizedTitleKey)
        
        if loremIpsumMode {
            text = "\( arc4random_uniform(1_000_000) )"
        }
        
        keyboardType = .decimalPad
        
    }
    
    var number: NSNumber? {
        guard let text = text else { return nil }
        guard let i = Double(text) else { return nil }
        return NSNumber(value: i)
    }
    
}

//Mark: - Date selection

class DateFormFieldData: FormFieldData {
    
    override init(localizedTitleKey: String) {
        super.init(localizedTitleKey: localizedTitleKey)
    }
    
    var selectedDate: Date? {
        didSet {
            NotificationCenter.default.post(name: FormFieldDataDidChangeNotification, object: self)
            onSelectedDateDidChange?(oldValue, selectedDate)
        }
    }

    var onSelectedDateDidChange: ((_ oldDate: Date?, _ newDate: Date?)->())?
    var dateFormatter: DateFormatter?
    
    var minimumDate: Date? = nil
    
    var datePickerMode: UIDatePicker.Mode = .date
    
    var formattedDateString: String? {
        if let fmt = dateFormatter {
            return selectedDate?.string(with: fmt)
            
        } else {
            return selectedDate?.string(with: DateFormatter.dayMonthAndYear)
        }
    }
    
    override var isEmpty: Bool {
        return selectedDate == nil
    }
    
}

extension DateFormFieldData: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let datePicker = textField.inputView as? UIDatePicker else { return }
        guard let selectedDate = selectedDate else { return }
        datePicker.date = selectedDate
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
}

class OptionFormFieldData: DropdownFormFieldData {
    var isYesOrNo = false
    
    var isMarkLeft = false
    
    var defaultValue = "No"
}

protocol PhotoFormater {}
extension String: PhotoFormater {}
extension LNUploadImage: PhotoFormater {}

class PhotoFormFieldData: DropdownFormFieldData {
    var images:[PhotoFormater] = []
    var itemId:String = ""
}

//Mark: - Dropdown lists

class DropdownFormFieldData: FormFieldData {
    
    var items = [DropdownItem]()
    var selectedIndex: Int? {
        didSet {
            NotificationCenter.default.post(name: FormFieldDataDidChangeNotification, object: self)
            onSelectedIndexDidChange?(oldValue, selectedIndex)
        }
    }
    
    init(localizedTitleKey: String, theItems: [DropdownItem] = [], theIndex: Int? = nil) {
        super.init(localizedTitleKey: localizedTitleKey)
        items.append(contentsOf: theItems)
        selectedIndex = theIndex
    }
    
    var onSelectedIndexDidChange: ((_ oldIndex: Int?, _ newIndex: Int?) -> ())?
    
    var selectedItemId: Any? {
        return selectedIndex.map { items[$0].id }
    }
 
    func setSelectedIndexIfIdFound<T: Equatable>(_ id: T?) {
        guard let id = id else { return }
        if let index = items.firstIndex(where: {
            if let itemId = $0.id as? T, itemId == id {
                return true
            }
            return false
        }) {
            
            selectedIndex = index
        }
    }
    
    override var isEmpty: Bool {
        guard !items.isEmpty else { return true }
        guard let index = selectedIndex, index < items.count else { return true }
        guard !items[index].name.trimmed.isEmpty else { return true }
        return false
    }
    
}

struct DropdownItem {
    
    let id: Any
    let name: String
    
    init(id: Any, name: String) {
        self.id = id
        self.name = name
    }
    
}

extension DropdownItem: InitFailable, ArrayBuildable {
    
    init?(json: [String : Any]) {
        guard let id: Any = json["value"], let name = json["name"] as? String else { return nil }
        self.id = id
        self.name = name
    }
    
}

extension DropdownFormFieldData: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return !items.isEmpty
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let pickerView = textField.inputView as? UIPickerView else { return }
        pickerView.reloadAllComponents()
        
        guard let selectedIndex = selectedIndex else {
            pickerView.selectRow(0, inComponent: 0, animated: true)
            return
        }
        
        pickerView.selectRow(selectedIndex, inComponent: 0, animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let text = textField.text , text.isEmpty {
            self.selectedIndex = 0
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
}

extension DropdownFormFieldData: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if items.count <= row {
            return nil
        }
        return items[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if self.title.contains("Bank Name") {
            return 48
        }else{
            
            for item in items {
                if item.name.count >= 40 {
                    return 48
                }
            }
            return 30
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                    forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        }
        pickerLabel?.numberOfLines = 0
        pickerLabel?.text = items[row].name
        pickerLabel?.textAlignment = .center
        return pickerLabel!
    }
    

}

extension DropdownFormFieldData: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
}

//Mark: - Radio Button Group

class RadioFormFieldData:FormFieldData {
    
    var items = [RadioItem]()
    
    var selectedIndex: Int? {
        didSet {
            NotificationCenter.default.post(name: FormFieldDataDidChangeNotification, object: self)
        }
    }
    
    override init(localizedTitleKey: String) {
        super.init(localizedTitleKey: localizedTitleKey)
    }
    
    var selectedItemId: Any? {
        return selectedIndex.map { items[$0].id }
    }
    
    func setSelectedIndexIfIdFound<T: Equatable>(_ id: T?) {
        guard let id = id else { return }
        if let index = items.firstIndex(where: {
            if let itemId = $0.id as? T, itemId == id {
                return true
            }
            return false
        }) {
            
            selectedIndex = index
            
        }
    }
    
    override var isEmpty: Bool {
        return selectedIndex == nil
    }
    
}

struct RadioItem {
    let id: Any
    let name: String
}
