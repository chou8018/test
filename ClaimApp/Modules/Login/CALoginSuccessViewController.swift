//
//  CALoginSuccessViewController.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/31.
//

import UIKit

class CALoginSuccessViewController: CABaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated:false);
    }
    
    override func initLocalString() {
        super.initLocalString()
        
        self.navigationItem.title = String.localized("login_nav_title", comment: "")
        titleLabel.text = String.localized("login_title_success", comment: "")
        subTitle.text = String.localized("login_title_details_verified", comment: "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8, execute: {
            self.navigationController?.pushViewController(CAExpensesViewController(), animated: true)
        })
    }
}
