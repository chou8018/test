//
//  LogOutConfirmViewController.swift
//  dealers
//
//  Created by chenjun on 2022/7/5.
//  Copyright © 2022 Trusty Cars. All rights reserved.
//

import UIKit

class LogOutConfirmViewController: UIViewController {

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
        
        titleLabel.text = String.localized("dialog_title_log_out_main", comment: "")
        contentLabel.text = String.localized("dialog_title_log_out_message", comment: "")
        cancelButton.setTitle(String.localized("profile_dialog_button_title_no", comment: ""), for: .normal)
        confirm.setTitle(String.localized("profile_dialog_button_title_yes", comment: ""), for: .normal)
        
        confirm.cornerRadius = 6
        cancelButton.cornerRadius = 6
        
    }

    
    @IBAction func buttonAction(_ sender: UIButton) {
        
        if sender.tag == 101 {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                if let userController = AppServices.shared.find(UserController.self) {
                    userController.logout()
                }
                self.target?.perform(object: "")
            }
        }
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    

}
