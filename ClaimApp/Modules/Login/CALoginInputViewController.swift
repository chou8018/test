//
//  CALoginInputViewController.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/27.
//

import UIKit
import Alamofire

class CALoginInputViewController: CABaseViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    var canSeePassword = false
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var buttomView: UIView!
    @IBOutlet weak var tfView0: UIView!
    @IBOutlet weak var tfView1: UIView!
    @IBOutlet weak var hitLabel: UILabel!

    var isFromResetPassword = false

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = String.localized("login_nav_title", comment: "")
    }
    
    init(isFromResetPassword: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.isFromResetPassword = isFromResetPassword
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFromResetPassword {
            useUntitledBackButton(target: self, selector: #selector(CALoginInputViewController.cancel))
        }
        
        emailTF.delegate = self
        passwordTF.delegate = self
        showLoginButtonDisableStatus()
        eyeButton.tintColor = .cPrimary
        
        buttomView.addBottomShadow()

#if DEBUG
        emailTF.text = AppConfig.userAccount
        passwordTF.text = AppConfig.userPassword
        showLoginButtonenableStatus()
#endif
        
        NotificationCenter.default.addObserver(self, selector: #selector(CALoginInputViewController.handleAppDidFetchClientAccessToken), name: AppDidFetchClientAPIAccessTokenNotification, object: nil)

    }
    
    @objc private func cancel() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func initLocalString() {
        super.initLocalString()
        
        self.navigationItem.title = String.localized("login_nav_title", comment: "")
        self.navigationController?.navigationBar.topItem?.title = ""

        welcomeLabel.text = String.localized("login_title_welcome", comment: "")
        subLabel.text = String.localized("login_title_with_email", comment: "")
        emailTF.placeholder = String.localized("create_profile_form_email_placeholder", comment: "")
        passwordTF.placeholder = String.localized("create_profile_form_password_placeholder", comment: "")
        loginButton.setTitle(String.localized("login_nav_title", comment: ""), for: .normal)
    }
    
    private func showLoginButtonDisableStatus() {
        loginButton.backgroundColor = .init(hexValue: 0xDCDCDC)
        loginButton.isEnabled = false
    }
    
    private func showLoginButtonenableStatus() {
        loginButton.isEnabled = true
        loginButton.backgroundColor = .cPrimary
    }
    
    @objc private func handleAppDidFetchClientAccessToken() {
        
        guard let email = emailTF.text , !email.isEmpty else {
            return
        }

        guard let password = passwordTF.text , !password.isEmpty else {
            return
        }
        
        if email == AppConfig.app_store_review , AppConfig.environment == .eks_qa  {
            AppConfig.testEnvironment = .eks_qa
            self.loginSecretly(passCode: password, phone: email, countryCode: "")
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        guard var email = emailTF.text , !email.isEmpty else {
            return
        }

        guard var password = passwordTF.text , !password.isEmpty else {
            return
        }
        
#if DEBUG
        if email != AppConfig.app_store_review {
//            email = "yaohui200@carro.co"
//            email = "zhou.biao@carro.co"
//            email = "wang.gao@carro.co"
//            email = "660845678945@carro.co"
//            email = "Zafina@carro.id" // abc123
//
//            if AppConfig.selectEnv == .staging_dx {
//                password = "carro123"
//            } else {
//                password = "wg12345"
//            }
            email = AppConfig.userAccount
            password = AppConfig.userPassword
        }
#endif
        if email == AppConfig.app_store_review , AppConfig.environment == .production  {
            AppConfig.testEnvironment = .eks_qa
            AppConfig.currentEnv = .eks_qa
//            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
//                self.loginSecretly(passCode: password, phone: email, countryCode: "SG")
//            }
        } else {
            self.loginSecretly(passCode: password, phone: email, countryCode: "th")
        }
    }
    
    private func loginSecretly(passCode: String, phone: String?, countryCode: String?) {
        
        let userController: UserController! = AppServices.shared.find(UserController.self)
        
        LoadingView.showLoadingViewInView(view: self.view)
        
        userController.bypass(passCode: passCode, phone: phone, countryCode: countryCode).done({ token,user in
            self.hitLabel.isHidden = true
            let usr = UserProfile(email: phone, password: passCode)
            self.navigationController?.pushViewController(CACreateProfileSuccessViewController(user: usr), animated: true)
        }).catch { [weak self] error in
            guard let `self` = self else { return }
            switch error {
            case ApiError.generalError(let message):
                if message.contains("You do not have access to this app") {
                    UIAlertController.showErrorMessage(error: error, from: self)
                } else {
//                    self.view.makeToast(String.localized("toast_title_unauthorized", comment: ""))
                    self.hitLabel.isHidden = false
                }
            default:
                UIAlertController.showErrorMessage(error: error, from: self)
            }
        }.finally {
            LoadingView.hideLoadingViewInView(view: self.view)
        }
        
    }
    
    @IBAction func seePasswordButtonClicked(_ sender: UIButton) {
        passwordTF.isSecureTextEntry = canSeePassword
        canSeePassword = !canSeePassword
        
        let image = UIImage(named: "eye-filled")
        if canSeePassword {
            eyeButton.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            eyeButton.setImage(image, for: .normal)
        }
    }
    
    @IBAction func resetPassword(_ sender: UIButton) {
        self.navigationController?.pushViewController(CAResetPasswordViewController(), animated: true)
    }
    
}

extension CALoginInputViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let fullStr = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == self.emailTF , !fullStr.isEmpty, let passwordText = self.passwordTF.text , !passwordText.isEmpty {
            showLoginButtonenableStatus()
        } else if textField == self.passwordTF , !fullStr.isEmpty, let email = self.emailTF.text , !email.isEmpty {
            showLoginButtonenableStatus()
        } else {
            self.showLoginButtonDisableStatus()
        }
        return true
    }
    
}
