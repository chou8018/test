//
//  CAResetPasswordViewController.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/27.
//

import UIKit
import Alamofire

class CAResetPasswordViewController: CABaseViewController {

    @IBOutlet weak var emailTF: UITextField!
    
    var canSeePassword = false
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var buttomView: UIView!
    @IBOutlet weak var hitLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = String.localized("reset_password_title", comment: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTF.delegate = self
        showLoginButtonDisableStatus()
        
        buttomView.addBottomShadow()

#if DEBUG
//        emailTF.text = "yaohui200@carro.co"
//        showLoginButtonenableStatus()
#endif

    }
    
    override func initLocalString() {
        super.initLocalString()
        
        self.navigationController?.navigationBar.topItem?.title = ""

        welcomeLabel.text = String.localized("reset_password_send_request", comment: "")
        subLabel.text = String.localized("reset_password_message", comment: "")
        emailTF.placeholder = String.localized("create_profile_form_email_placeholder", comment: "")
        loginButton.setTitle(String.localized("reset_password_send_request", comment: ""), for: .normal)
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
        
        guard let email = emailTF.text , !email.isEmpty else {
            return
        }
        
//        self.navigationController?.pushViewController(CANewPasswordViewController(email: email, token: ""), animated: true)
//        return
        
        let controller: SellFlowController! = AppServices.shared.find(SellFlowController.self)
        
        LoadingView.showLoadingViewInView(view: self.view)
        controller.requestOTPEmail(email: email).done { [weak self] cities -> Void in
            guard let `self` = self else { return }
            self.hitLabel.isHidden = true
            self.navigationController?.pushViewController(VerificationCodeFormViewController(verificationId: "", phoneCode: "", phoneNumber: email, countryCode: ""), animated: true)
            
        }.catch { [weak self] error in
            guard let `self` = self else { return }
            
            switch error {
            case let ApiError.formError(_, errors):
                var errorMessage = ""
                if let emailError = errors["email"]?.first {
                    errorMessage.append(emailError)
                    self.hitLabel.text = errorMessage
                    self.hitLabel.isHidden = false
                } else {
                    UIAlertController.showErrorMessage(error: error, from: self)
                }
           
            default:
                UIAlertController.showErrorMessage(error: error, from: self)
            }
        }.finally { [weak self] in
            guard let `self` = self else { return }
            LoadingView.hideLoadingViewInView(view: self.view)
        }
    }
    
}

extension CAResetPasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let fullStr = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if !fullStr.isEmpty {
            showLoginButtonenableStatus()
        } else {
            self.showLoginButtonDisableStatus()
        }
        return true
    }
    
}
