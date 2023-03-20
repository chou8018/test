//
//  CAUnauthorizedViewController.swift
//  ClaimApp
//
//  Created by wanggao on 2022/9/2.
//

import UIKit

class CAUnauthorizedViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var okButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = String.localized("dialog_title_unauthorized_session", comment: "")
        messageLabel.text = String.localized("dialog_title_unauthorized_sub_message", comment: "")
        okButton.setTitle(String.localized("dialog_button_title_ok", comment: ""), for: .normal)
    }

    @IBAction func okButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
}
