//
//  CAExpensesAmountFootView.swift
//  dealers
//
//  Created by wanggao on 2022/7/7.
//  Copyright © 2022 Trusty Cars. All rights reserved.
//

import UIKit

class CAExpensesAmountFootView: UITableViewHeaderFooterView ,InitializableFromNib {

    static var nibName: String = "CAExpensesAmountFootView"
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addNewItemButton: UIButton!
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var optionView: UIView!
    
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var descLabel: UILabel!
    
    var sectionType: Int = amountSection {
        didSet {
            if sectionType == amountSection {
                titleLabel.text = String.localized("new_expenses_button_title_add_item", comment: "")
                icon.image = UIImage(named: "icon-add")
            } else {
//                titleLabel.attributedText = NSAttributedString.addRequireStatus(string: .localized("new_expenses_button_title_capture", comment: ""))
                titleLabel.text = .localized("new_expenses_button_title_capture", comment: "")
                icon.image = UIImage(named: "icon-capture")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .white
        
        descLabel.textColor = .init(hexValue: 0x161C24)
        descLabel.font = .mediumCustomFont(ofSize: 12)
        
        switchButton.onTintColor = .init(hexValue: 0x4082FF)
        
        self.switchButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
                
    }
    
}
