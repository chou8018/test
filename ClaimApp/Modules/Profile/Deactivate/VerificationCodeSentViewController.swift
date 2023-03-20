//
//  VerificationCodeSentViewController.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 16/4/18.
//  Copyright © 2018 Trusty Cars. All rights reserved.
//

import UIKit
import SnapKit

class VerificationCodeSentViewController: UIViewController {

    private var phoneString: String!
    private var emptyStateView: EmptyStateView!
    private var isDeactivate: Bool? = false
    init(phoneString: String, isDeactivate:Bool? = false) {
        super.init(nibName: nil, bundle: nil)
        self.phoneString = phoneString
        self.isDeactivate = isDeactivate
    }
   
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyStateView = addEmptyStateViewInView(self.view, frame: .zero)
        
        emptyStateView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    
        emptyStateView.resetSubviews()
      
        emptyStateView.imageView.image = .init(named: "icVerification")
        
        emptyStateView.titleLabel.text = String.localized("otp_code_sent_title", comment: "Verification Code Sent")
        emptyStateView.titleLabel.font = UIFont.extraExtraLargeBold
        emptyStateView.titleLabel.textColor = UIColor.cDarkText
        
        emptyStateView.subtitleLabel.text = String.localized("otp_code_sent_message", comment: "The verification code has been successfully sent to")
        emptyStateView.subtitleLabel.font = UIFont.medium
        emptyStateView.subtitleLabel.textColor = UIColor.cLightText
        
        emptyStateView.actionButton.tintColor = UIColor.cPrimary
        emptyStateView.actionButton.setTitleColor(UIColor.cPrimary, for: .normal)
        emptyStateView.actionButton.titleLabel?.font = UIFont.extraExtraLargeBold
        emptyStateView.actionButton.backgroundColor = UIColor.white
        emptyStateView.actionButton.isEnabled = false
        
        emptyStateView.actionButton.setTitle(phoneString, for: .normal)
                
        addVersionLabel()
    
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emptyStateView.imageView.alpha = 0
        emptyStateView.imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).concatenating(CGAffineTransform(rotationAngle: CGFloat(Double.pi)))
        
        emptyStateView.titleLabel.alpha = 0
        emptyStateView.titleLabel.transform = CGAffineTransform(translationX: 0, y: 15)
        
        emptyStateView.subtitleLabel.alpha = 0
        emptyStateView.subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 15)
        
        emptyStateView.actionButton.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: [.curveEaseInOut], animations: { [weak self] in
            guard let `self` = self else { return }
            
            self.emptyStateView.imageView.alpha = 1
            self.emptyStateView.titleLabel.alpha = 1
            self.emptyStateView.subtitleLabel.alpha = 1
            
            self.emptyStateView.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            self.emptyStateView.titleLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            self.emptyStateView.subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            
        }) { [weak self] _ in
            
            guard let `self` = self else { return }
            self.emptyStateView.actionButton.alpha = 1
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.dismiss(animated: true, completion: nil)
            })
        
        }
        
    }
    
}
