//
//  CALoginViewController.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/26.
//

import UIKit

class CALoginViewController: CABaseViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var profileButton: UIButton!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func initLocalString() {
        super.initLocalString()
        
        loginButton.setTitle(String.localized("login_with_email_button_title", comment: ""), for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .cPrimary
        loginButton.backgroundColor = .init(hexValue: 0x4082FF)
        profileButton.backgroundColor = loginButton.backgroundColor

        versionLabel.text = UIApplication.shared.versionWithHomepage
        
        versionLabel.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(CALoginViewController.showPromat))
        versionLabel.addGestureRecognizer(tapGes)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(CALoginViewController.handleAdminLogin))
        longPressGesture.minimumPressDuration = 2
        imageView.addGestureRecognizer(longPressGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CALoginViewController.handleClientOrUserAccessTokenDidExpire), name: AppUserAccessTokenDidExpireNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CALoginViewController.handleAppDidFetchClientAccessToken), name: AppDidFetchClientAPIAccessTokenNotification, object: nil)
        
        if let userController = AppServices.shared.find(UserController.self) , let _ = userController.userAccessToken {
            
            if let userAcc = UserDefaults.standard.string(forKey: AppConfig.currentUserEmailKey) , let passcode = UserDefaults.standard.string(forKey: AppConfig.currentUserPasscode) {
                
//                let usedPassCode = MZRSA.decryptString(passcode, publicKey: PUBLIC_KEY) ?? ""
                if userAcc == AppConfig.app_store_review , AppConfig.environment == .production  {
                    AppConfig.testEnvironment = .eks_qa
                    AppConfig.currentEnv = .eks_qa
//                    DispatchQueue.main.asyncAfter(deadline: .now()+1) {
//                        self.loginSecretly(passCode: passcode, phone: userAcc, countryCode: "")
//                    }
                } else {
                    loginSecretly(passCode: passcode, phone: userAcc, countryCode: "")
                }
            } else {
                LoadingView.showLoadingViewInView(view: self.view)
                DispatchQueue.main.asyncAfter(deadline: .now()+1.8) {
                    self.navigationController?.pushViewController(CAExpensesViewController(), animated: true)
                    LoadingView.hideLoadingViewInView(view: self.view)
                }
            }
        }
    }
    
    @objc private func handleAppDidFetchClientAccessToken() {

        if let userController = AppServices.shared.find(UserController.self) , let _ = userController.userAccessToken {
            
            if let userAcc = UserDefaults.standard.string(forKey: AppConfig.currentUserEmailKey) , let passcode = UserDefaults.standard.string(forKey: AppConfig.currentUserPasscode) {
                if userAcc == AppConfig.app_store_review , AppConfig.environment == .eks_qa  {
                    AppConfig.testEnvironment = .eks_qa
                    self.loginSecretly(passCode: passcode, phone: userAcc, countryCode: "")
                }
            }
        }
    }
    
    @objc private func handleClientOrUserAccessTokenDidExpire() {
        let vc = UIViewController.current ?? self
        let unauthVC = CAUnauthorizedViewController()
        unauthVC.modalPresentationStyle = .overFullScreen
        vc.present(unauthVC, animated: false)
    }

    @IBAction func pushToLoginInputVC(_ sender: UIButton) {
        self.navigationController?.pushViewController(CALoginInputViewController(), animated: true)
    }
    
    @IBAction func pushToCreateProfile(_ sender: UIButton) {
        self.navigationController?.pushViewController(CACreateProfileViewController(), animated: true)
    }
    
    @objc private func handleAdminLogin() {
        
        let vc = UIAlertController(title: "Login", message: "Enter Passcode", preferredStyle: .alert)
        vc.addTextField { (textField) in
            textField.isSecureTextEntry = true
            #if DEBUG
            textField.text = "CarroAdminTest!123"
            #endif
        }
        vc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        vc.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] (_) in
            guard let `self` = self else { return }
            if AppConfig.environment == .production {
                AppConfig.testEnvironment = .eks_qa
                AppConfig.currentEnv = .eks_qa
            }
            if let textField = vc.textFields?.first, let text = textField.text?.trimmed , !text.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self.loginSecretly(passCode: text, phone: AppConfig.app_store_review, countryCode: "SG")
                }
            }
        }))
        
        present(vc, animated: true, completion: nil)

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
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        showPromat()
    }
    
    @objc private func showPromat() {
        
        if AppConfig.testEnvironment == .eks_qa {
            return
        }
        if AppConfig.environment != .production {
            let ast = UIAlertController(title: nil, message: "Switch Env (need reopen the App)", preferredStyle: .actionSheet)
            
            ast.addAction(UIAlertAction(title: "Staging_dx" + (AppConfig.selectEnv == .staging_dx ? "（current）" : ""), style: .default, handler: {[weak self] (action) in
                guard let `self` = self else { return }
                AppConfig.currentEnv = .staging_dx
                self.switchSucceed()
            }))
            
            ast.addAction(UIAlertAction(title: "EKS_QA" + (AppConfig.selectEnv == .eks_qa ? "（current）" : ""), style: .default, handler: {[weak self] (action) in
                guard let `self` = self else { return }
                AppConfig.currentEnv = .eks_qa
                self.switchSucceed()
            }))
            
            ast.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(ast, animated: true, completion: nil)
        }
    }
    
    private func switchSucceed() {
        versionLabel.text = UIApplication.shared.versionWithHomepage
        let ast = UIAlertController(title: "Switch Success", message: nil, preferredStyle: .alert)
        ast.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
        }))
        present(ast, animated: true, completion: nil)
    }
    
}
