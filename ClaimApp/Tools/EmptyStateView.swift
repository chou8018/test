//
//  EmptyStateView.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 17/9/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import UIKit
import SnapKit

final class EmptyStateView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var thActionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        resetSubviews()
    }
    
    func resetSubviews() {
        
        clipsToBounds = true
        
        imageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        actionButton.setTitle(nil, for: .normal)
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        titleLabel.font = UIFont.largeBold
        titleLabel.textColor = UIColor.cDarkText
        
        subtitleLabel.font = UIFont.medium
        subtitleLabel.textColor = UIColor.cLightText
        
        actionButton.titleLabel?.font = UIFont.mediumBold
        
        actionButton.tintColor = UIColor.white
        actionButton.setTitleColor(UIColor.white, for: .normal)
        actionButton.backgroundColor = UIColor.cPrimary
        
        actionButton.layer.cornerRadius = 4
        
        imageView.isHidden = false
        titleLabel.isHidden = false
        subtitleLabel.isHidden = false
        actionButton.isHidden = false
        
        actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
        
        thActionButton.borderColor = .cPrimary
        thActionButton.setTitleColor(.cPrimary, for: .normal)
        thActionButton.snp.remakeConstraints { (maker) in
            maker.top.equalTo(actionButton)
            maker.centerX.equalTo(self)
            maker.width.equalTo(140)
            maker.height.equalTo(38)
        }
        showNormalActionButton()
    }
    
    func showTHActionButton(){
        thActionButton.isHidden = false
        actionButton.isHidden = false
        actionButton.alpha = 0
        actionButton.isEnabled = false
    }
    
    func showNormalActionButton(){
        thActionButton.isHidden = true
        actionButton.isHidden = false
        actionButton.alpha = 1
        actionButton.isEnabled = true
    }
        
    func hide() {
        guard let `superview` = superview else { return }
        superview.sendSubviewToBack(self)
        self.isHidden = true
    }
    
    func useDefaultErrorStateAppearance() {
        
        resetSubviews()
        
        imageView.isHidden = true
        
        titleLabel.text = String.localized("error_state_default_title", comment: "Oops...")
        subtitleLabel.text = String.localized("error_state_default_message", comment: "Something went wrong.")
        actionButton.setTitle(String.localized("error_state_default_button_title", comment: "Retry"), for: .normal)
    
    }
    
    func useDefaultNoConnectionStateAppearance() {
        
        resetSubviews()
        
        imageView.isHidden = true
        
        titleLabel.text = String.localized("error_state_title_no_internet", comment: "No internet connection.")
        subtitleLabel.text = String.localized("error_state_message_no_internet", comment: "Please check your internet connection.")
        actionButton.setTitle("Retry", for: .normal)
        
    }
    
    func useDefaultEmptyStateAppearance() {
        
        resetSubviews()
        
        imageView.image = #imageLiteral(resourceName: "ph_empty")
        
        subtitleLabel.isHidden = true
        
        titleLabel.text = String.localized("empty_state_default_title", comment: "Nothing to show now.")
        actionButton.setTitle(String.localized("empty_state_default_button_title", comment: "Reload"), for: .normal)
        
    }
    
    
}

extension EmptyStateView {
    
    func useErrorStateAppearance(error: Error) {
        switch error {
        case ApiError.noConnection:
            useDefaultNoConnectionStateAppearance()
        default:
            useDefaultErrorStateAppearance()
        }
    }
    
}

