//
//  CAExpensesCellHeadView.swift
//  dealers
//
//  Created by wanggao on 2022/7/7.
//  Copyright © 2022 Trusty Cars. All rights reserved.
//

import UIKit

class CAExpensesCellHeadView: UITableViewHeaderFooterView ,InitializableFromNib {

    static var nibName: String = "CAExpensesCellHeadView"
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var leftLineSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightLineSpaceConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if AppDataHelper.countryCode == .TH {
           showLeftAndRightArrowButton()
        }
        titleLabel.isUserInteractionEnabled = true
        leftButton.setImage(UIImage(named: "icon_blue_left")?.withTintColor(.hexColorWithAlpha(color: "#4082FF")), for: .normal)
        rightButton.setImage(UIImage(named: "icon_blue_right")?.withTintColor(.hexColorWithAlpha(color: "#4082FF")), for: .normal)
    }
    
    func hideLeftAndRightArrowButton() {
        leftButton.isHidden = true
        rightButton.isHidden = true
        leftLineSpaceConstraint.constant = 16
        rightLineSpaceConstraint.constant = leftLineSpaceConstraint.constant
    }
    
    func showLeftAndRightArrowButton() {
        leftButton.isHidden = false
        rightButton.isHidden = false
        leftLineSpaceConstraint.constant = 26
        rightLineSpaceConstraint.constant = leftLineSpaceConstraint.constant
    }
}
