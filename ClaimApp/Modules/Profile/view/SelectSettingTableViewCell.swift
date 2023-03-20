//
//  SelectSettingTableViewCell.swift
//  dealers
//
//  Created by Warren Frederick Balcos on 2/6/20.
//  Copyright © 2020 Trusty Cars. All rights reserved.
//

import Foundation
import UIKit

final class SelectSettingTableViewCell: UITableViewCell, InitializableFromNib, UIPickerViewDelegate, UIPickerViewDataSource {

    static var nibName: String = "SelectSettingTableViewCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectionTextView: UITextField!
    
    var valuePicker: UIPickerView!
    var pickerData: [String] = [String]() {
       didSet {
           valuePicker.reloadComponent(0)
       }
        
   }
    var selectedRow: Int = 0  {
        didSet {
            if valuePicker.numberOfRows(inComponent: 0) > 0 {
                valuePicker.selectRow(selectedRow, inComponent: 0, animated: false)
            }
        }
    }
    
    var onSelectValueChanged:((Int)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        valuePicker = UIPickerView()
        valuePicker.dataSource = self
        valuePicker.delegate = self
        
        selectionTextView.inputView = valuePicker
        
        selectionTextView.tintColor = .clear
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        selectionTextView.text = nil
        onSelectValueChanged = nil
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) ->  String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectionTextView.text = pickerData[row]
        onSelectValueChanged?(row)
        self.endEditing(true)
    }
    
}
