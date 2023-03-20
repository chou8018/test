//
//  CAProfileViewController.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/29.
//

import UIKit
import FirebaseAuth

class CAProfileViewController: CABaseViewController {
    
    private let tableIdentifierCell = "tableIdentifierCell"
    private let selectSettingCellId = "SelectSettingCell"

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var footView: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    var isBEOTP: Bool = false

    var languageCode: String? = nil
//    {
//        didSet {
//            if let code = languageCode {
//                let userController: UserController! = AppServices.shared.find(UserController.self)
//                userController.changeLanguage(languageCode: code).done { [weak self] Bool -> Void in
//                    guard let `self` = self else { return }
//                    SystemStoreService.shared().setLanguageCode(value: code)
//                    NotificationCenter.default.post(name: LanguageChangedNotification, object: nil)
//                    self.tableView.reloadData()
//                }.catch { [weak self] error in
//                    guard let `self` = self else { return }
//                    UIAlertController.showErrorMessage(error: error, from: self) {
//                        self.dismiss(animated: true, completion: nil)
//                    }
//                }
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = String.localized("profile_nav_title", comment: "")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        tableView.register(UINib.init(nibName: "CAProfileCell", bundle: nil), forCellReuseIdentifier: tableIdentifierCell)
        tableView.register(SelectSettingTableViewCell.nib, forCellReuseIdentifier: selectSettingCellId)
        
        footView.height = AppConfig.kHeightWithNavigation - (150 + 44 * 2 + AppConfig.kBottomSafeHeight)
        
        versionLabel.text = UIApplication.shared.versionString
        
        languageCode = AppDataHelper.userController.languageCode
        loadUserData()
    }
    
    private func showData(user: User) {
        nameLabel.text = user.name
        phoneLabel.text = user.phone
        emailLabel.text = user.email
        if let version = versionLabel.text {
            versionLabel.text = version + " (\(user.id))"
        }
        
        if let photoString = user.profileImageUrl ,let url = URL(string: photoString) {
            profileImageView.af_setImage(withURL: url,  placeholderImage: UIImage(named: "ic_profilepic"))
        }
    }
    
    private func loadUserData() {
        if let user = AppDataHelper.user {
            showData(user: user)
        } else {
            guard
                let name = UserDefaults.standard.string(forKey: AppConfig.currentUserNameKey)
            else {
                return
            }
            
            nameLabel.text = name
            phoneLabel.text = UserDefaults.standard.string(forKey: AppConfig.currentUserPhoneKey)
            emailLabel.text = UserDefaults.standard.string(forKey: AppConfig.currentUserEmailKey)
            let userId = UserDefaults.standard.string(forKey: AppConfig.currentUserIdKey)
            let imageUrl = UserDefaults.standard.string(forKey: AppConfig.currentUserImageKey)
            
            if let version = versionLabel.text , let usedId = userId {
                versionLabel.text = version + " (\(usedId))"
            }
            
            if let photoString = imageUrl ,let url = URL(string: photoString) {
                profileImageView.af_setImage(withURL: url,  placeholderImage: UIImage(named: "ic_profilepic"))
            }
        }
    }
    
    func showLogoutFlow() {
        let tipVc = LogOutConfirmViewController(target: Target(target: self, selector: #selector(CAProfileViewController.dismissAction(obj:))))
        self.present(tipVc, animated: false, completion: nil)
    }
    
    @objc func dismissAction(obj: String) {
        self.navigationController?.popToRootViewController(animated: true) 
    }

    
    func showAccountDeactivationFlow() {
        let tipVc = DeactivateConfirmViewController(target: Target(target: self, selector: #selector(CAProfileViewController.dismissAction2(obj:))))
        self.present(tipVc, animated: false, completion: nil)
    }
    
    
    @objc func dismissAction2(obj: String) {
        guard let phone = AppServices.shared.find(UserController.self)?.user?.phone, phone.count > 3 else {return}
        handleSubmitButtonPress(phoneStr: phone)
    }

}

extension CAProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: selectSettingCellId, for: indexPath) as! SelectSettingTableViewCell
            cell.titleLabel.text = String.localized("language_setting_title", comment: "Language")
            cell.selectionStyle = .none
            
            var langNames: [String] = []
            let languages = SystemStoreService.shared().getDefaultLanguages()
            for i in languages.indices {
                langNames.append(languages[i].title ?? "")
            }
            cell.pickerData = langNames
            
            var selectedRow = 0
            for i in languages.indices {
                if (languages[i].value == self.languageCode) {
                    selectedRow = i
                    break
                }
            }
            
            cell.selectedRow = selectedRow
            cell.selectionTextView.text = langNames[selectedRow]
            cell.onSelectValueChanged = { [weak self] value in
                guard let `self` = self else { return }
                self.languageCode = languages[value].value
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: tableIdentifierCell, for: indexPath) as! CAProfileCell
            cell.titleLabel.text = String.localized("profile_title_log_out", comment: "")
            cell.selectionStyle = .none
            return cell
        default:

            let cell = tableView.dequeueReusableCell(withIdentifier: tableIdentifierCell, for: indexPath) as! CAProfileCell
            cell.titleLabel.text = String.localized("all_deactivate_account_profile_title", comment: "")
            cell.selectionStyle = .none
            return cell
        }
    }
}

extension CAProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            break
        case 1:
            showLogoutFlow()
            break
        default:
            showAccountDeactivationFlow()
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 0
        }
        return 44
    }
}

extension CAProfileViewController {
    
    
    private func handleSubmitButtonPress(phoneStr: String) {
        
        LoadingView.showLoadingViewInView(view: self.view)
#if DEBUG
//        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
#endif
        let phoneCode = String(phoneStr.prefix(3).suffix(2))
        let phone = String(phoneStr.suffix(phoneStr.count-3))
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneStr, uiDelegate: nil) { [weak self] (verificationId, error) in
            
            guard let `self` = self else { return }
            
            LoadingView.hideLoadingViewInView(view: self.view)
            
            if let error = error as NSError? {
                            
                switch error.code {
                
                case AuthErrorCode.captchaCheckFailed.rawValue:
                    UIAlertController.showMessage(title: "Oops", message: "Invalid captcha token, please try again", from: self)
                    
                case AuthErrorCode.invalidPhoneNumber.rawValue: fallthrough
                case AuthErrorCode.missingPhoneNumber.rawValue:
                    UIAlertController.showMessage(title: "Oops", message: "Invalid or missing phone number", from: self)
                case AuthErrorCode.tooManyRequests.rawValue:
                    fallthrough
                case AuthErrorCode.quotaExceeded.rawValue:
                    self.requestSmsLogin(phone: phone, phoneCode: phoneCode)
                default:
                    if error.localizedDescription.contains("blocked") {
                        self.requestSmsLogin(phone: phone, phoneCode: phoneCode)
                    } else {
                        let title = String.localized("default_error_title", comment: "Oops...")
                        UIAlertController.showMessage(title: title, message: error.localizedDescription, from: self, completion: nil)
                    }
                }
                return
            }
            
            guard let verificationId = verificationId else { return }
            
            let successVC = VerificationCodeSentViewController(phoneString: "+\(phoneCode) \(phone)", isDeactivate: true)
            successVC.modalTransitionStyle = .crossDissolve
            successVC.modalPresentationStyle = .fullScreen
            self.present(successVC, animated: true, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { [weak self] in
                
                guard let `self` = self else { return }
                
                successVC.dismiss(animated: false, completion: nil)
                guard let countryCode = AppServices.shared.find(UserController.self)?.user?.countryCode.rawValue else {return}

                let vc = VerificationCodeFormViewController(
                    verificationId: verificationId,
                    phoneCode: phoneCode,
                    phoneNumber: phone,
                    countryCode: countryCode,
                    isDeactivate: true
                )
                self.show(vc, sender: self)
            })
        }
    }
    
    func requestSmsLogin(phone: String, phoneCode: String) {
        guard let loginController = AppServices.shared.find(UserController.self), let uuid = UIDevice.current.identifierForVendor?.uuidString else { return }
        let params = ["phone":phone,
                      "phone_code": phoneCode,
                      "request_sms_code":true,
                      "device_info":["device_id":uuid]] as [String : Any]
        loginController.smsloginRequest(params: params).done {[weak self] result in
            guard let self = self else {return}
            LoadingView.hideLoadingViewInView(view: self.view)
            
            let successVC = VerificationCodeSentViewController(phoneString: "+\(phoneCode) \(phone)", isDeactivate: true)
            successVC.modalTransitionStyle = .crossDissolve
            successVC.modalPresentationStyle = .fullScreen
            self.present(successVC, animated: true, completion: nil)
            self.isBEOTP = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { [weak self] in
                
                guard let `self` = self else { return }
                
                successVC.dismiss(animated: false, completion: nil)
                guard let countryCode = AppServices.shared.find(UserController.self)?.user?.countryCode.rawValue else {return}

                let vc = VerificationCodeFormViewController(
                    verificationId: "",
                    phoneCode: phoneCode,
                    phoneNumber: phone,
                    countryCode: countryCode,
                    isDeactivate: true
                )
                vc.isBEOTP = self.isBEOTP
                self.show(vc, sender: self)
            })

        }.catch {[weak self] error in
            guard let self = self else {return}
            LoadingView.hideLoadingViewInView(view: self.view)
            UIAlertController.showErrorMessage(error: error, from: self)
        }
    }

}
