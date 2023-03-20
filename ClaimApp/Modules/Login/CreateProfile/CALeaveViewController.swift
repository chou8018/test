//
//  CALeaveViewController.swift
//  dealers
//
//  Created by chenjun on 2022/7/5.
//  Copyright © 2022 Trusty Cars. All rights reserved.
//

import UIKit

class CALeaveViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirm: UIButton!
    
    private var target: Target?
    
    init(target:Target) {
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
        self.target = target
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        confirm.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        titleLabel.text = String.localized("create_profile_form_dialog_title", comment: "")
        contentLabel.text = String.localized("create_profile_form_dialog_subtitle", comment: "")
        cancelButton.setTitle(String.localized("all_deactivate_account_pop_cacel", comment: ""), for: .normal)
        confirm.setTitle(String.localized("all_deactivate_account_pop_confirm", comment: ""), for: .normal)
        
        confirm.cornerRadius = 6
        cancelButton.cornerRadius = 6
        
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        if sender.tag == 101 {
            self.target?.perform(object: "")
        }
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    

}
