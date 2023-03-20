//
//  VerificationSuccessViewController.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 16/4/18.
//  Copyright © 2018 Trusty Cars. All rights reserved.
//

import UIKit
import SnapKit

class VerificationSuccessViewController: UIViewController {

    private var emptyStateView: EmptyStateView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyStateView = addEmptyStateViewInView(self.view, frame: .zero)
        
        emptyStateView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
    
        emptyStateView.resetSubviews()
      
        emptyStateView.imageView.image = .init(named: "icSuccess")
        
        emptyStateView.titleLabel.text = String.localized("login_success_title", comment: "Success!")
        emptyStateView.titleLabel.font = UIFont.extraExtraLargeBold
        emptyStateView.titleLabel.textColor = UIColor.cDarkText
        
        let fmt = String.localized("login_success_messsage", comment: "Your phone number has been verified. Taking you back to {app}")
        emptyStateView.subtitleLabel.text = fmt.replacingOccurrences(of: "{app}", with: UIApplication.shared.appName)
        
        emptyStateView.subtitleLabel.font = UIFont.medium
        emptyStateView.subtitleLabel.textColor = UIColor.cLightText
        
        emptyStateView.actionButton.isHidden = true
            
        addVersionLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emptyStateView.imageView.alpha = 0
        emptyStateView.titleLabel.alpha = 0
        emptyStateView.subtitleLabel.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let posX = emptyStateView.imageView.frame.minX
        let posY = emptyStateView.imageView.frame.maxY
        
        emptyStateView.imageView.layer.anchorPoint = CGPoint(x: 0, y: 1)
        emptyStateView.imageView.layer.position = CGPoint(x: posX, y: posY)
        
        emptyStateView.imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).concatenating(CGAffineTransform(rotationAngle: CGFloat(-Double.pi/6)))
        emptyStateView.titleLabel.transform = CGAffineTransform(translationX: 0, y: 15)
        
        emptyStateView.subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 15)
        
        UIView.animate(withDuration: 0.15, delay: 0.1, options: [.curveEaseIn], animations: { [weak self] in
            guard let `self` = self else { return }
            
            self.emptyStateView.imageView.alpha = 1
            self.emptyStateView.titleLabel.alpha = 1
            self.emptyStateView.subtitleLabel.alpha = 1
            
            self.emptyStateView.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            self.emptyStateView.titleLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            self.emptyStateView.subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            
        }) { [weak self] _ in
            
            guard let `self` = self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.dismiss(animated: true, completion: nil)
            })
        
        }
        
    }
    
}
