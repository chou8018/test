//
//  VerificationHelpFormViewController.swift
//  dealers
//
//  Created by Hong Wei Zhuo on 4/5/18.
//  Copyright © 2018 Trusty Cars. All rights reserved.
//

import UIKit

class VerificationHelpFormViewController: LoginFlowBaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var digitOneView: LineTextFieldView!
    @IBOutlet weak var digitTwoView: LineTextFieldView!
    @IBOutlet weak var digitThreeView: LineTextFieldView!
    @IBOutlet weak var digitFourView: LineTextFieldView!
    @IBOutlet weak var digitFiveView: LineTextFieldView!
    @IBOutlet weak var digitSixView: LineTextFieldView!
    private var digitViews = [LineTextFieldView]()
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var hitLabel: UILabel!
    
    private var theVerificationId: String
    private var thePhoneCode: String
    private let thePhoneNumber: String
    
    private var isDeactivate: Bool? = false

    init(verificationId: String, phoneCode: String, phoneNumber: String, isDeactivate: Bool? = false) {
        theVerificationId = verificationId
        thePhoneCode = phoneCode
        thePhoneNumber = phoneNumber
        
        super.init(nibName: "VerificationHelpFormViewController", bundle: Bundle.main)
        self.isDeactivate = isDeactivate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        useUntitledBackButton()
        
        title = String.localized("login_help_form_nav_title", comment: "Help")
        
        titleLabel.text = String.localized("login_help_form_title", comment: "Please call us to retrieve a 6-digit code")
        callButton.setTitle(String.localized("login_help_form_call_button_title", comment: "Call"), for: .normal)
        subtitleLabel.text = String.localized("login_help_form_subtitle", comment: "Enter the 6-digit code below")
        
        //callButton.layer.borderColor = UIColor.cPrimary.cgColor
        //callButton.layer.borderWidth = 1
        callButton.setTitleColor(.white, for: .normal)
        callButton.layer.cornerRadius = 4
        callButton.backgroundColor = .cPrimary
        submitButton.layer.cornerRadius = 4
        submitButton.setTitleColor(UIColor.white, for: .normal)
        submitButton.setTitle(String.localized("login_help_form_submit_button_title", comment: "Verify"), for: .normal)
        
        digitViews.append(contentsOf: [digitOneView, digitTwoView, digitThreeView, digitFourView, digitFiveView, digitSixView])
        
        for digitView in digitViews {
            digitView.textField.textColor = .cPrimary
        }
        updateSubmitButtonState()
        setupDigitViews()
        updateDigitViewsAppearance()
        
        //        addVersionLabel()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(VerificationHelpFormViewController.handleDidFetchUserAccessToken), name: AppDidFetchUserAccessTokenNotification, object: nil)
    }
    
    @objc private func handleDidFetchUserAccessToken() {
        if let countryCode = CountryCode(phoneCode: self.thePhoneCode) {
//            self.trackLoginVerified(eventName: "clicked_otp_verified", pageName: "login_help", buttonLabel: "verify", countryId: "\(countryCode.id)")
        }
    }
    
    @objc private func updateSubmitButtonState() {
        
        if digitViews.contains(where: { digitView in
            return digitView.textField.text.map({ text in
                return text.isEmpty || !text.isNumeric
            }) ?? true
        }) {
            
        } else {
            handleSubmitButtonPressed(0)
        }
    }
    
    
    
    private func setupDigitViews() {
        digitViews.forEach { [weak self] digitView in
            digitView.textField.delegate = self
            digitView.textField.textAlignment = .center
            digitView.textField.keyboardType = .numberPad
        }
    }
    
    @objc private func updateDigitViewsAppearance() {
        
        digitViews.forEach({ digitView in
            
            if let text = digitView.textField.text?.trimmed, !text.isEmpty {
                digitView.lineColor =  .cPrimary
                
            } else if digitView.textField.isFirstResponder {
                digitView.lineColor = .cPrimary
            } else {
                digitView.lineColor = UIColor.cPlaceholderBackground
            }
            
        })
        
    }
    
    @IBAction func handleCallButtonPressed(_ sender: Any) {
        
        if thePhoneCode.isEmpty {
            thePhoneCode = "65"
        }
        guard
            let countryCode = CountryCode(phoneCode: thePhoneCode) else { return }
        var url = ""
        switch countryCode {
        case .ID:
            url = "tel:+628119940101"
            break
        case .MY:
            url = "tel:+60355690999"
            break
        case .TH:
            url = "tel:+6625088425"
            break
        case .SG:
            url = "tel:+6581980822"
            break
        default:
            url = "tel:+6581980822"
        }
        guard let urlString = URL(string: url) else {return}
        if UIApplication.shared.canOpenURL(urlString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(urlString, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(urlString)
            }
        }
    }
    
    private func deleteUser(code: String) {
        let userController: UserController! = AppServices.shared.find(UserController.self)
        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else { return }
        let params = ["phone":thePhoneNumber,
                      "phone_code": thePhoneCode,
                      "help_token": code,
                      "device_info":["device_id":uuid]] as [String : Any]
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
//                NotificationCenter.default.post(name: AppAccountDidDeletedNotification, object: nil)
                
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
                if message.lowercased().contains("invalid access token") {
                    self.showErrorMsg(msg: "Invalid code. Try again.")
                } else {
                    self.showErrorMsg(msg: message)
                }
                break
            case ApiError.formError(let message, _):
                self.showErrorMsg(msg: message)
                break
            default:
                self.showErrorMsg(msg: error.localizedDescription)
                break
            }
        }
    }

    
    @IBAction func handleSubmitButtonPressed(_ sender: Any) {
        
        
        guard !digitViews.contains(where: { digitView in
            return digitView.textField.text.map({ text in
                return text.isEmpty || !text.isNumeric
            }) ?? true
        }) else {
            return
        }
        
        if isDeactivate == true {
            let code = digitViews.map({ $0.textField.text ?? "" }).joined()
            deleteUser(code: code)
        } else {
            verifyResetPasswordCode()
        }
    }
    
    private func verifyResetPasswordCode() {
        
        let otp = digitViews.map({ $0.textField.text ?? "" }).joined()
        
        let controller: SellFlowController! = AppServices.shared.find(SellFlowController.self)
        
        LoadingView.showLoadingViewInView(view: self.view)
        controller.resetPasswordOTP(email: thePhoneNumber, otp: otp).done { [weak self] token -> Void in
            guard let `self` = self else { return }
            self.hitLabel.isHidden = true
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
    
    func showErrorMsg(msg: String) {
        self.hitLabel.isHidden = false
        self.hitLabel.text = msg
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
}

extension VerificationHelpFormViewController: UITextFieldDelegate {
    
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

class LoginFlowBaseViewController: UIViewController {

    var topGradientView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func image(fromLayer layer: CALayer) -> UIImage {
            UIGraphicsBeginImageContext(layer.frame.size)
            layer.render(in: UIGraphicsGetCurrentContext()!)
            let outputImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return outputImage!

    }
    func setNavibar() {
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            let gradient = CAGradientLayer()
            
            let  start: CGPoint = CGPoint(x: 0.40, y: 0.5)//渐变起点
            let end: CGPoint = CGPoint(x: 1, y: 0.5)//渐变终点
            
            gradient.startPoint = start
            gradient.endPoint = end
            gradient.locations = [0.0, 1.0]
            
            let sizeLength = UIScreen.main.bounds.size.width
            let frameAndStatusBar = CGRect(x: 0, y: 0, width: sizeLength, height: 64)
            gradient.frame = frameAndStatusBar
            gradient.colors = [UIColor(hexValue: 0xFF4C00).cgColor, UIColor(hexValue: 0xFE8C5A).cgColor]
            appearance.backgroundImage = self.image(fromLayer: gradient)
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            self.navigationController?.navigationBar.standardAppearance = appearance;
            self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        }else{
            let gradient = CAGradientLayer()
             let sizeLength = UIScreen.main.bounds.size.width
             let frameAndStatusBar = CGRect(x: 0, y: 0, width: sizeLength, height: 64)
             gradient.frame = frameAndStatusBar
             gradient.colors = [UIColor(hexValue: 0xFF4C00).cgColor, UIColor(hexValue: 0xFFD4C2).cgColor]
             navigationController?.navigationBar.setBackgroundImage(self.image(fromLayer: gradient), for: .default)
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
           
        }
        
    }

}
