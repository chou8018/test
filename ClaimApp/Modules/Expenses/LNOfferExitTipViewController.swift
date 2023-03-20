//
//  LNOfferExitTipViewController.swift
//  dealers
//
//  Created by 付耀辉 on 2021/9/23.
//  Copyright © 2021 Trusty Cars. All rights reserved.
//

import UIKit

class LNOfferExitTipViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var leave: UIButton!
    @IBOutlet weak var stay: UIButton!
    
    private var target: Target?
    
    var selectType:String?

    init(target:Target, selectType:String?=nil) {
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
        self.target = target
        self.selectType = selectType
    }

    var isSelectCurrency:Bool = false
    var indexPath:IndexPath?
    init(target:Target, indexPath: IndexPath) {
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
        self.target = target
        self.indexPath = indexPath
        self.isSelectCurrency = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        leave.setTitleColor(.white, for: .normal)
        leave.setTitleColor(.white, for: .highlighted)
        leave.setTitle(.localized("dialog_button_title_no", comment: ""), for: .normal)
        leave.backgroundColor = .cPrimary
        leave.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
    
        stay.setTitleColor(.titleGrayColor, for: .normal)
        stay.setTitleColor(.titleGrayColor, for: .highlighted)
        stay.setTitle(.localized("dialog_button_title_yes", comment: ""), for: .normal)
        stay.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        stay.backgroundColor = .clear
        
        titleLabel.text = .localized("dialog_title_expenses_main_leave", comment: "")
        contentLabel.text = .localized("dialog_title_expenses_sub_leave", comment: "")
        
        if let _ = selectType {
            contentLabel.text = .localized("dialog_title_expenses_sub_switch", comment: "")
        }
        if isSelectCurrency {
            titleLabel.text = .localized("dialog_title_expenses_sub_switch_currency_title", comment: "")
            contentLabel.text = .localized("dialog_title_expenses_sub_switch_currency_content", comment: "")
        }
        stay.borderColor = .titleGrayColor
        leave.borderColor = .clear
        stay.borderWidth = 1
        leave.tag = 101
        stay.tag = 100
        
        leave.cornerRadius = 5
        stay.cornerRadius = 5
    }
    
    
    @IBAction func buttonAction(_ sender: UIButton) {
        
        if sender.tag == 100 {
            if let selectType = selectType {
                target?.perform(object: selectType)
            }else if isSelectCurrency {
                target?.perform(object: indexPath)
            }else{
                target?.perform(object: "")
            }
        }
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
}
