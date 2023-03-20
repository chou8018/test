//
//  VerificationCodeFormViewController.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 16/4/18.
//  Copyright © 2018 Trusty Cars. All rights reserved.
//

import UIKit
import FirebaseAuth
import PromiseKit

class VerificationCodeFormViewController: CABaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var digitOneView: LineTextFieldView!
    @IBOutlet weak var digitTwoView: LineTextFieldView!
    @IBOutlet weak var digitThreeView: LineTextFieldView!
    @IBOutlet weak var digitFourView: LineTextFieldView!
    @IBOutlet weak var digitFiveView: LineTextFieldView!
    @IBOutlet weak var digitSixView: LineTextFieldView!
    
    
    @IBOutlet weak var resendLabel: UILabel!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var buttonWidth: NSLayoutConstraint!
    
    @IBOutlet weak var helpButton: UIButton!
    
    //    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var receiveLabel: UILabel!
    @IBOutlet weak var errorMsg: UILabel!
    @IBOutlet weak var helpView: UIView!
    
    private var theVerificationId: String
    private let thePhoneCode: String
    private let thePhoneNumber: String
    private let theCountryCode: String?
    
    private var nextResendTimestamp: TimeInterval
    
    private var digitViews = [LineTextFieldView]()
    
    private var didAppearForFirstTime: Bool = false
    var isBEOTP: Bool = false
    
    public var target:Target? = nil

    private var isDeactivate: Bool? = false

    init(verificationId: String, phoneCode: String, phoneNumber: String ,countryCode: String?, isDeactivate: Bool? = false) {
        
        theVerificationId = verificationId
        thePhoneCode = phoneCode
        thePhoneNumber = phoneNumber
        theCountryCode = countryCode
        
        nextResendTimestamp = Date().timeIntervalSince1970 + Double(60)
        
        super.init(nibName: "VerificationCodeFormViewController", bundle: Bundle.main)
        self.isDeactivate = isDeactivate
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = String.localized("otp_form_nav_title", comment: "")
        
        showNormalTitleMessage()
        
        if isDeactivate == true {
            subtitleLabel.text = "+\(thePhoneCode) \(thePhoneNumber)"
            helpView.isHidden = false
        } else {
            subtitleLabel.text = thePhoneNumber
            titleLabel.text = String.localized("otp_form_title", comment: "")
            helpView.isHidden = true
        }
        
        digitViews.append(contentsOf: [digitOneView, digitTwoView, digitThreeView, digitFourView, digitFiveView, digitSixView])
        for digitView in digitViews {
            digitView.textField.textColor = .init(hexValue: 0x161C24)
        }
        setupDigitViews()
        updateDigitViewsAppearance()
        
        updateSubmitButtonState()
        
        //        submitButton.addTarget(self, action: #selector(VerificationCodeFormViewController.handleSubmitButtonPressed(sender:)), for: .touchUpInside)
        resendButton.addTarget(self, action: #selector(VerificationCodeFormViewController.handleResendButtonPressed(sender:)), for: .touchUpInside)
//        addVersionLabel()
        
        resendButton.setTitleColor(.cNewPrimary, for: .normal)
        helpButton.setTitleColor(.cNewPrimary, for: .normal)
        helpButton.buttonUnderlineWith(btnStr: "Get help from us")
        
        self.errorMsg.textColor = .init(hexValue: 0xF54165)
        
        startCountdown()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !didAppearForFirstTime {
            makeDigitViewsBecomeFirstResponder()
            didAppearForFirstTime = true
        }
        
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(VerificationCodeFormViewController.updateFooter), object: nil)
        }
    }
    
    @IBAction func handleHelpButtonPressed(_ sender: Any) {
        
        //        if let countryCode = CountryCode(rawValue: theCountryCode ?? "") {
        //            trackLoginVerified(eventName: "clicked_help", pageName: "login_verification", buttonLabel: "help",countryId: "\(countryCode.id)")
        //        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector:
                                                #selector(VerificationCodeFormViewController.updateFooter), object: nil)
        showNormalFooter()
        
        let vc = VerificationHelpFormViewController(verificationId: theVerificationId, phoneCode: thePhoneCode, phoneNumber: thePhoneNumber, isDeactivate: isDeactivate)
        show(vc, sender: self)
    }
    
    private func setupDigitViews() {
        digitViews.forEach { [weak self] digitView in
            digitView.textField.delegate = self
            digitView.textField.textAlignment = .center
            digitView.textField.keyboardType = .numberPad
        }
    }
    
    private func updateSubmitButtonState() {
        
        if digitViews.contains(where: { digitView in
            return digitView.textField.text.map({ text in
                return text.isEmpty || !text.isNumeric
            }) ?? true
        }) {
            
        } else {
            handleSubmitButtonPressed()
        }
        
    }
    
    @objc private func updateDigitViewsAppearance() {
        
        digitViews.forEach({ digitView in
            
            if digitView.textField.isFirstResponder {
                digitView.lineColor = UIColor.cPrimary
            } else if let text = digitView.textField.text?.trimmed, !text.isEmpty {
                digitView.lineColor = UIColor.init(hexValue: 0xC4CDD5)
            } else {
                digitView.lineColor = UIColor.init(hexValue: 0xC4CDD5)
            }
        })
        
    }
    
    private func previousDigitView(fromTextField tf: UITextField) -> LineTextFieldView? {
        guard let idx = digitViews.firstIndex(where: { $0.textField == tf }), idx > 0 else { return nil }
        return digitViews[idx - 1]
    }
    
    private func nextDigitView(fromTextField tf: UITextField) -> LineTextFieldView? {
        guard let idx = digitViews.firstIndex(where: { $0.textField == tf }), idx < (digitViews.count-1) else { return nil }
        return digitViews[idx + 1]
    }
    
    private func makeDigitViewsBecomeFirstResponder() {
        digitViews[0].textField.becomeFirstResponder()
    }
    
    @objc private func handleSubmitButtonPressed() {
        if isDeactivate == true {
            verifyCode()
        } else {
            verifyResetPasswordCode()
        }
    }
        
    private func deleteUser(key:String, value:String) {
        let userController: UserController! = AppServices.shared.find(UserController.self)
        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else { return }
        var params = ["phone":thePhoneNumber,
                      "phone_code": thePhoneCode,
                      "device_info":["device_id":uuid]] as [String : Any]
        params[key] = value
        LoadingView.showLoadingViewInView(view: self.view)
        userController.deleteUser(params: params).done { user -> Void in
            LoadingView.hideLoadingViewInView(view: self.view)
            let successVC = VerificationSuccessViewController()
            successVC.modalTransitionStyle = .crossDissolve
            successVC.modalPresentationStyle = .fullScreen
            self.present(successVC, animated: true, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: { [weak self] in
                guard let `self` = self else { return }
                self.dismiss(animated: false, completion: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                    UIApplication.shared.keyWindow?.makeCarroToast(String.localized("all_deactivate_account_success_title", comment: "") + "\n\n" + String.localized("all_deactivate_account_success_content", comment: ""),position: .center, boldTitle: String.localized("all_deactivate_account_success_title", comment: ""), image:UIImage(named: "success_icon"))
                })
                self.navigationController?.popToRootViewController(animated: true)
            })

        }.catch {[weak self] error in
            guard let self = self else {return}
            LoadingView.hideLoadingViewInView(view: self.view)
            
            switch error {
            case ApiError.generalError(let message):
                self.showInvalidCode(message: message)
                break
            case ApiError.formError(let message, _):
                self.showInvalidCode(message: message)
                break
            default:
                self.showInvalidCode(message: error.localizedDescription)
                break
            }
        }
    }
    
    private func showInvalidCode(message: String) {
        if message.lowercased().contains("invalid access token") {
            self.showErrorMsg(msg: "Invalid code. Try again.")
        } else {
            self.showErrorMsg(msg: message)
        }
    }
    
    private func requestOtpFromEmail() {
        
        guard !thePhoneNumber.isEmpty else {
            return
        }
        
        let controller: SellFlowController! = AppServices.shared.find(SellFlowController.self)
        
        LoadingView.showLoadingViewInView(view: self.view)
        controller.requestOTPEmail(email: thePhoneNumber).done { [weak self] cities -> Void in
            guard let `self` = self else { return }
            self.nextResendTimestamp = Date().timeIntervalSince1970 + Double(60)
            self.updateFooter()
        }.catch { [weak self] error in
            guard let `self` = self else { return }
            UIAlertController.showErrorMessage(error: error, from: self)
        }.finally { [weak self] in
            guard let `self` = self else { return }
            LoadingView.hideLoadingViewInView(view: self.view)
        }
    }
    
    private func verifyResetPasswordCode() {
        showNormalTitleMessage()

        guard !digitViews.contains(where: { digitView in
            return digitView.textField.text.map({ text in
                return text.isEmpty || !text.isNumeric
            }) ?? true
        }) else {
            return
        }
        
        let otp = digitViews.map({ $0.textField.text ?? "" }).joined()
        
        let controller: SellFlowController! = AppServices.shared.find(SellFlowController.self)
        
        LoadingView.showLoadingViewInView(view: self.view)
        controller.resetPasswordOTP(email: thePhoneNumber, otp: otp).done { [weak self] token -> Void in
            guard let `self` = self else { return }
            self.navigationController?.pushViewController(CANewPasswordViewController(email: self.thePhoneNumber, token: token), animated: true)
        }.catch { [weak self] error in
            guard let `self` = self else { return }
            switch error {
            case ApiError.generalError(let message):
                self.showErrorMsg(msg: message)
                break
            case ApiError.formError(let message, _):
                self.showErrorMsg(msg: message)
                break
            default:
                self.showErrorMsg(msg: error.localizedDescription)
                break
            }
            
        }.finally { [weak self] in
            guard let `self` = self else { return }
            LoadingView.hideLoadingViewInView(view: self.view)
        }

    }
    
    private func verifyCode() {
        showNormalTitleMessage()

        guard !digitViews.contains(where: { digitView in
            return digitView.textField.text.map({ text in
                return text.isEmpty || !text.isNumeric
            }) ?? true
        }) else {
            return
        }
        
        
        let otp = digitViews.map({ $0.textField.text ?? "" }).joined()
        
        if isBEOTP {
            self.deleteUser(key: "token", value: otp)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: theVerificationId,
            verificationCode: otp)
        
        LoadingView.showLoadingViewInView(view: self.view)
        
        Auth.auth().signIn(with: credential) { [weak self] (result, error) in
            
            guard let `self` = self else { return }
            
            LoadingView.hideLoadingViewInView(view: self.view)
            
            if let error = error as NSError? {
                
                switch error.code {
                    
                case AuthErrorCode.invalidVerificationCode.rawValue:
                    self.showErrorMsg(msg: "Invalid code. Try again.")
                    break
                case AuthErrorCode.invalidVerificationID.rawValue: fallthrough
                case AuthErrorCode.sessionExpired.rawValue:
                    self.showExpiredVerificationCodeMessage()
                    
                default:
                    
                    if error.localizedDescription.lowercased().contains("invalid access token") {
                        self.showErrorMsg(msg: "Invalid code. Try again.")
                    } else {
                        self.showErrorMsg(msg: error.localizedDescription)
                    }
//                    UIAlertController.showErrorMessage(error: error, from: self)
                }
                return
            }
//            guard let loginController = AppServices.shared.find(UserController.self), let token = loginController.userAccessToken?.value  else { return }
            
            guard let user = Auth.auth().currentUser else {
                return
            }
            
            user.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
                self.deleteUser(key: "access_token", value: idToken ?? "")
            })
        }
    }
    
    @objc private func handleResendButtonPressed(sender: UIButton) {
//        startCountdown()
        
        if isDeactivate == true {
            resend { [weak self] in
                guard let `self` = self else { return }
                self.updateFooter()
            }
        } else {
            requestOtpFromEmail()
        }
    }
        
    private func showNormalTitleMessage() {
        self.errorMsg.isHidden = true
    }
    
    private func showNormalFooter() {
        resendLabel.text = String.localized("otp_form_normal_footer_title", comment: "")
        resendLabel.textColor = .init(hexValue: 0x6E6E6E)
        receiveLabel.isHidden = false
        
        resendButton.isHidden = false
        resendButton.isEnabled = true
        
        resendButton.setTitle(String.localized("otp_form_resend_button_title", comment: ""), for: .normal)
        buttonWidth.constant = 100
    }
    
    private func showCountdownFooter(numberOfSeconds: Int) {
        
        let countdownMessageFmt = String.localized("otp_form_resend_countdown_message", comment: "")
        resendLabel.text = countdownMessageFmt.replacingOccurrences(of: "{numberOfSeconds}", with: "\(numberOfSeconds)")
    
        resendButton.isHidden = true
        resendButton.isEnabled = false
        
        resendButton.setTitle(nil, for: .normal)
        buttonWidth.constant = 0
    }

    private func showExpiredVerificationCodeMessage() {
    
        let _ =
        UIAlertController.showMessage(
            title: "Oops",
            message: String.localized("otp_form_otp_expired_message", comment: "Your verification code has expired. Resend?"),
            leftButton: (title: "No", handler: nil),
            rightButton: (title: "Yes", handler: { [weak self] _ in
                
                guard let `self` = self else { return }
                self.startCountdown()
                
            }),
            presentingViewController: self
        )
        
    }
    
    private func startCountdown() {
        showNormalTitleMessage()
        updateFooter()
    }
    
    private func resend(completion: (()->())?) {
        
        LoadingView.showLoadingViewInView(view: self.view)
        
        PhoneAuthProvider.provider().verifyPhoneNumber("+\(self.thePhoneCode)\(self.thePhoneNumber)", uiDelegate: nil) { [weak self] (verificationId, error) in
            
            
            guard let `self` = self else {
                return
            }
            
            LoadingView.hideLoadingViewInView(view: self.view)
            
            if let error = error as NSError? {
                
                switch error.code {
                    
                case AuthErrorCode.captchaCheckFailed.rawValue:
                    self.showErrorMsg(msg: "Invalid captcha token, please try again")
                case AuthErrorCode.invalidPhoneNumber.rawValue: fallthrough
                case AuthErrorCode.missingPhoneNumber.rawValue:
                    self.showErrorMsg(msg: "Invalid or missing phone number")
                    break
                case AuthErrorCode.quotaExceeded.rawValue:
                    self.requestSmsLogin {
                        completion?()
                    }
                    break
                default:
                    if error.localizedDescription.contains("blocked") {
                        self.requestSmsLogin {
                            completion?()
                        }
                    } else {
                        self.showErrorMsg(msg: error.localizedDescription)
                    }
                    break
                }
                return
            }
            let successVC = VerificationCodeSentViewController(phoneString: "+\(self.thePhoneCode) \(self.thePhoneNumber)")
            successVC.modalTransitionStyle = .crossDissolve
            successVC.modalPresentationStyle = .fullScreen
            self.present(successVC, animated: true, completion: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4, execute: { [weak self] in
                guard let `self` = self, let verificationId = verificationId else { return }
                successVC.dismiss(animated: false)
                self.theVerificationId = verificationId
                self.nextResendTimestamp = Date().timeIntervalSince1970 + Double(60)
                completion?()
            })
        }
    }
    
    
    @objc private func updateFooter() {
        
        let currentTimestamp = Date().timeIntervalSince1970
        let numberOfSeconds = Int(nextResendTimestamp - currentTimestamp)
        
        guard numberOfSeconds >= 0 else {
            self.showNormalFooter()
            return
        }
        
        showCountdownFooter(numberOfSeconds: numberOfSeconds)
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(VerificationCodeFormViewController.updateFooter), object: nil)
        
        self.perform(#selector(VerificationCodeFormViewController.updateFooter), with: nil, afterDelay: 1, inModes: [RunLoop.Mode.common])
    }
        
    func requestSmsLogin(completion: (()->())?) {
        guard let loginController = AppServices.shared.find(UserController.self), let uuid = UIDevice.current.identifierForVendor?.uuidString else { return }
        var params = ["phone":self.thePhoneNumber,
                      "phone_code": self.thePhoneCode,
                      "device_info":["device_id":uuid]] as [String : Any]
        if isDeactivate == true {
            params["request_sms_code"] = true
        }
        loginController.smsloginRequest(params: params).done {[weak self] result in
            guard let self = self else {return}
            LoadingView.hideLoadingViewInView(view: self.view)

            let successVC = VerificationCodeSentViewController(phoneString: "+\(self.thePhoneCode) \(self.thePhoneNumber)")
            successVC.modalTransitionStyle = .crossDissolve
            successVC.modalPresentationStyle = .fullScreen
            self.present(successVC, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4, execute: { [weak self] in

                guard let `self` = self else { return }
                successVC.dismiss(animated: false, completion: nil)
                self.isBEOTP = true
                self.nextResendTimestamp = Date().timeIntervalSince1970 + Double(60)
                completion?()
            })
        }.catch {[weak self] error in

            guard let self = self else {return}
            LoadingView.hideLoadingViewInView(view: self.view)
            switch error {
            case ApiError.generalError(let message):
                self.showErrorMsg(msg: message)
                break
            case ApiError.formError(let message, _):
                self.showErrorMsg(msg: message)
                break
            case ApiError.unconventionalError(message: let message, errorInfo: _):
                self.showErrorMsg(msg: message)
                break
            default:
                self.showErrorMsg(msg: error.localizedDescription)
                break
            }
        }
    }
    
    
    func showErrorMsg(msg: String) {
        self.errorMsg.isHidden = false
        self.errorMsg.text = msg
    }
    
}

extension VerificationCodeFormViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if let text = textField.text, !text.isEmpty {
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
            
        } else {
            textField.text = "\u{200B}"
        }
        
        updateDigitViewsAppearance()
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let text = textField.text, text == "\u{200B}" {
            textField.text = nil
        }
        
        updateDigitViewsAppearance()
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let old = textField.text else { return false }
        //old will at least be a zero width character, cannot be empty
        self.errorMsg.isHidden = true
        
        if string.count == 0,
           (old.count == 1 && old.isNumeric) {
            
            textField.text = "\u{200B}"
            
            updateDigitViewsAppearance()
            updateSubmitButtonState()
            
            return false
            
        } else if string.count == 0,
                  old == "\u{200B}" { //backspace
            
            textField.text = nil
            
            if let previous = previousDigitView(fromTextField: textField) {
                previous.textField.text = nil
                previous.textField.becomeFirstResponder()
                
            } else { //backspace on the first digit
                textField.text = "\u{200B}"
            }
            
            updateDigitViewsAppearance()
            updateSubmitButtonState()
            
            return false
            
        } else if
            string.count == 1,
            string.isNumeric,
            old == "\u{200B}" || (old.count == 1 && old.isNumeric) { //forward
            
            //we replace the zero width character with a digit
            
            textField.text = string
            
            if let next = nextDigitView(fromTextField: textField) {
                next.textField.becomeFirstResponder()
                
            } else {
                textField.resignFirstResponder()
            }
            
            updateDigitViewsAppearance()
            updateSubmitButtonState()
            
            return false
            
        }
        
        return false
        
    }
    
}
