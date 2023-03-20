//
//  THCostTotalCell.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/27.
//

import UIKit


class THCostTotalCell: UITableViewCell ,InitializableFromNib {
    
    static var nibName: String = "THCostTotalCell"

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var taxField: UITextField!
    @IBOutlet weak var totalField: UITextField!

    @IBOutlet weak var netLabel: UILabel!
    @IBOutlet weak var vatLabel: UILabel!
        
    @IBOutlet weak var excVATLabel: UILabel!
    
    @IBOutlet weak var grandTotalLabel: UILabel!
    
    @IBOutlet weak var thbTF1: UITextField!
    @IBOutlet weak var thbTF2: UITextField!
    @IBOutlet weak var thbTF3: UITextField!
    
    @IBOutlet weak var subtotalLabelCenterYConstraint: NSLayoutConstraint!
    
    public var data: THCostItemData!
    
    var onTextFieldTextDidChange: ((String?, UITextField)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(THCostTotalCell.didSelectCurrency(notification:)), name: DraftDidChooseCurrency, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(THCostTotalCell.didSelectCurrency(notification:)), name: DraftDidChooseCurrencyForTotalCell, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func didSelectCurrency(notification: Notification) {
        
        guard let model = notification.object as? CACurrencyInfo else {
            return
        }
        
        updateInfor(model: model)
    }
    
    func updateInfor(model: CACurrencyInfo) {

        textField.text = nil
        taxField.text = nil
        totalField.text = nil

        textField.placeholder = "-"
        taxField.placeholder = textField.placeholder
        totalField.placeholder = textField.placeholder
        
        updateLabelInfo(model: model)
    }
    
    private func updateLabelInfo(model: CACurrencyInfo) {
        
        if AppDataHelper.countryCode == .TH {
            excVATLabel.isHidden = false
            netLabel.text = "Subtotal"
            vatLabel.text = "Total VAT"
            grandTotalLabel.text = "Grand Total"
            subtotalLabelCenterYConstraint.constant = -8
        } else {
            if model.currency_code == "THB" {
                excVATLabel.isHidden = false
                netLabel.text = "Subtotal"
                vatLabel.text = "Total VAT"
                grandTotalLabel.text = "Grand Total"
                subtotalLabelCenterYConstraint.constant = -8
            } else {
                excVATLabel.isHidden = true
                netLabel.text = "Total"
                vatLabel.text = "Total Tax"
                grandTotalLabel.text = "Total Gross"
                subtotalLabelCenterYConstraint.constant = 0
            }
        }
        
        thbTF1.placeholder = "(\(model.currency_code))"
        thbTF2.placeholder = thbTF1.placeholder
        thbTF3.placeholder = thbTF1.placeholder
    }
    
    @IBAction func beginEditing(_ sender: Any) {
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetSubviews()
    }
    
    private func resetSubviews() {
 
        textField.inputView = nil
        textField.delegate = nil
        textField.isEnabled = true
        textField.keyboardType = .default
                
        onTextFieldTextDidChange = nil
    }
    
}

extension THCostTotalCell: FormFieldDataUI {
    
    func bind(data: FormFieldData) {
        
        self.textField.textColor = .black
        self.textField.isHidden = false
        
        guard let costData = data as? THCostItemData else {
            return
        }
        
        textField.text = costData.subtotal
        taxField.text = costData.totalVAT
        totalField.text = costData.grandTotal
        
        if let currency = costData.currency {
            updateLabelInfo(model: currency)
        }

        self.data = costData

    }
}

extension THCostTotalCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        LNDebugPrint(item: "xxxx")
    }
    
}
