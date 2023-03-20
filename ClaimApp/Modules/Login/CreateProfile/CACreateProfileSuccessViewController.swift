//
//  CACreateProfileSuccessViewController.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/31.
//

import UIKit

enum HitPageType: Int {
    case normal        = 0
    case guest
    case updatePassword
}

class CACreateProfileSuccessViewController: CABaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var user: UserProfile!
    var pageType : HitPageType = .normal

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationItem.setHidesBackButton(true, animated:false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    init(user: UserProfile , pageType: HitPageType = .normal) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
        self.pageType = pageType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func initLocalString() {
        super.initLocalString()
        
        self.navigationItem.title = String.localized("login_nav_title", comment: "")
        
        versionLabel.text = UIApplication.shared.versionString

        
        if pageType == .guest {
            titleLabel.text = String.localized("create_profile_form_title_guest", comment: "")
            subTitle.text = String.localized("create_profile_form_title_guest_subtitle", comment: "")
            iconImageView.image = UIImage(named: "icon-create-profile-success")
        } else if pageType == .updatePassword {
            titleLabel.text = String.localized("reset_new_password_success_title", comment: "")
            subTitle.text = String.localized("reset_new_password_success_subtitle", comment: "")
            iconImageView.image = UIImage(named: "icon_success_update")
        } else {
            titleLabel.text = String.localized("create_profile_form_title_success", comment: "")
            subTitle.text = String.localized("create_profile_form_title_success_subtitle", comment: "")
            iconImageView.image = UIImage(named: "icon_success_normal")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8, execute: {
            guard let pwd = self.user.password , let email = self.user.email else {
                return
            }
            
            if self.pageType == .updatePassword {
                self.navigationController?.pushViewController(CALoginInputViewController(isFromResetPassword: true), animated: true)
       
            } else if self.pageType == .normal {
                self.navigationController?.pushViewController(CAExpensesViewController(), animated: true)
            } else {
                self.loginSecretly(passCode: pwd, phone: email, countryCode: "")
            }
        })
    }
    
    private func loginSecretly(passCode: String, phone: String?, countryCode: String?) {
        
        guard let userController = AppServices.shared.find(UserController.self) else { return }
        
        LoadingView.showLoadingViewInView(view: self.view)
        userController.bypass(passCode: passCode, phone: phone, countryCode: "").done({ token,user in
            self.navigationController?.pushViewController(CAExpensesViewController(), animated: true)
        }).catch { [weak self] error in
            guard let `self` = self else { return }
            switch error {
            case ApiError.generalError(let message):
                if message.contains("You do not have access to this app") {
                    UIAlertController.showErrorMessage(error: error, from: self)
                } else {
                    self.view.makeToast(message)
                }
            default:
                UIAlertController.showErrorMessage(error: error, from: self)
            }
        }.finally {
            LoadingView.hideLoadingViewInView(view: self.view)
        }
        
    }
}
