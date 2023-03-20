//
//  CANewPasswordViewController.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/27.
//

import UIKit
import Alamofire

class CANewPasswordViewController: CABaseViewController {

    @IBOutlet weak var passwordTF0: UITextField!
    @IBOutlet weak var passwordTF1: UITextField!
    
    var canSeePassword = false
    var canSeePassword0 = false

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var eyeButton0: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var buttomView: UIView!
    @IBOutlet weak var hitLabel: UILabel!
    
    @IBOutlet weak var tfView0: UIView!
    @IBOutlet weak var tfView1: UIView!

    var email: String = ""
    var token: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = String.localized("reset_new_password_title", comment: "")
//        self.navigationItem.setHidesBackButton(true, animated:false);
    }
    
    init(email:String , token: String) {
        super.init(nibName: nil, bundle: nil)
        self.email = email
        self.token = token
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTF0.delegate = self
        passwordTF1.delegate = self
        showLoginButtonDisableStatus()
        eyeButton.tintColor = .cPrimary
        eyeButton0.tintColor = .cPrimary

        buttomView.addBottomShadow()
        subLabel.text = String.localized("reset_password_sub_title", comment: "") + email
        
        let c = NSString(string: subLabel.text ?? "")
        
        let attribute = NSMutableAttributedString(string: subLabel.text ?? "")
        let range = NSString(string: c.uppercased).range(of: email.uppercased())
        attribute.addAttributes([NSAttributedString.Key.foregroundColor:UIColor.init(hexValue: 0x4082FF)], range: range)
        subLabel.attributedText = attribute
#if DEBUG
//        emailTF.text = "yaohui200@carro.co"
//        passwordTF.text = "carro123"
//        showLoginButtonenableStatus()
#endif

    }
    
    override func initLocalString() {
        super.initLocalString()
        
        self.navigationController?.navigationBar.topItem?.title = ""

        welcomeLabel.text = String.localized("reset_password_create_new", comment: "")
        subLabel.text = String.localized("reset_password_sub_title", comment: "")
        passwordTF0.placeholder = String.localized("create_profile_form_password_placeholder", comment: "")
        passwordTF1.placeholder = String.localized("reset_new_password_confirm_placeholder", comment: "")
        loginButton.setTitle(String.localized("reset_new_password_confirm_button", comment: ""), for: .normal)
    }
    
    private func showLoginButtonDisableStatus() {
        loginButton.backgroundColor = .init(hexValue: 0xDCDCDC)
        loginButton.isEnabled = false
    }
    
    private func showLoginButtonenableStatus() {
        loginButton.isEnabled = true
        loginButton.backgroundColor = .cPrimary
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        guard let password0 = passwordTF0.text , !password0.isEmpty else {
            return
        }

        guard let password1 = passwordTF1.text , !password1.isEmpty else {
            return
        }
        
        if password0 != password1 {
            tfView0.borderColor = .cRemindRed
            tfView1.borderColor = .cRemindRed
            hitLabel.isHidden = false
            return
        }
        
        tfView0.borderColor = .personalButtonUnselect
        tfView1.borderColor = .personalButtonUnselect
        hitLabel.isHidden = true
        
        guard !email.isEmpty else {
            return
        }
        
        guard !token.isEmpty else {
            return
        }
        
        let controller: SellFlowController! = AppServices.shared.find(SellFlowController.self)
        
        LoadingView.showLoadingViewInView(view: self.view)
        controller.resetPassword(email: email, pwd: password0, confirmPwd: password1, token: token).done { [weak self] cities -> Void in
            guard let `self` = self else { return }
            
            let usr = UserProfile(email: self.email, password: password0, password_confirmation: password1, country_code: "", city_id: "", phone: "")
            self.navigationController?.pushViewController(CACreateProfileSuccessViewController(user: usr, pageType: .updatePassword), animated: true)
            
        }.catch { [weak self] error in
            guard let `self` = self else { return }
            UIAlertController.showErrorMessage(error: error, from: self)

        }.finally { [weak self] in
            guard let `self` = self else { return }
            LoadingView.hideLoadingViewInView(view: self.view)
        }
    }
    
    @IBAction func seePasswordButtonClicked(_ sender: UIButton) {
        passwordTF1.isSecureTextEntry = canSeePassword
        canSeePassword = !canSeePassword
        
        let image = UIImage(named: "eye-filled")
        if canSeePassword {
            eyeButton.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            eyeButton.setImage(image, for: .normal)
        }
    }
    
    @IBAction func seePasswordButton0Clicked(_ sender: UIButton) {
        passwordTF0.isSecureTextEntry = canSeePassword0
        canSeePassword0 = !canSeePassword0
        
        let image = UIImage(named: "eye-filled")
        if canSeePassword0 {
            eyeButton0.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            eyeButton0.setImage(image, for: .normal)
        }
    }
    
}

extension CANewPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let fullStr = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == self.passwordTF0 , !fullStr.isEmpty, let passwordText = self.passwordTF1.text , !passwordText.isEmpty {
            showLoginButtonenableStatus()
        } else if textField == self.passwordTF1 , !fullStr.isEmpty, let email = self.passwordTF0.text , !email.isEmpty {
            showLoginButtonenableStatus()
        } else {
            self.showLoginButtonDisableStatus()
        }
        return true
    }
    
}
