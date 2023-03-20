//
//  CACreateProfileViewController.swift
//  ClaimApp
//
//  Created by wanggao on 2022/10/26.
//

import UIKit
import SnapKit

class CACreateProfileViewController: CABaseViewController {
    
    private let tableIdentifierCell = "tableIdentifierCell"
    @IBOutlet weak var buttomView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    
    var datas: [FormFieldData] = []
    
    lazy var footView: UIView = {
        
        let foot = UIView(frame:CGRect(x:0, y:0, width: UIScreen.main.bounds.width-13*2, height: 100))
        foot.backgroundColor = .white
        
        let label = UILabel.init()
        label.font = UIFont.mediumCustomFont(ofSize: 12)
        label.textAlignment = .center
        label.tag = 100
        label.textColor = .cRemindRed
        label.numberOfLines = 0
        label.text = .localized("create_profile_form_incorrect_email", comment: "")
        label.isHidden = true
        foot.addSubview(label)
        label.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview()
        }
        
        return foot
        
    }()
    
    private var footLabel: UILabel? {
        footView.viewWithTag(100) as? UILabel
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = String.localized("create_profile_title", comment: "")
        self.navigationController?.navigationBar.topItem?.title = ""
        
        useUntitledBackButton(target: self, selector: #selector(CACreateProfileViewController.cancel))
        
        buttomView.addBottomShadow()
        showLoginButtonDisableStatus()
        
        tableView.register(UINib.init(nibName: "CACreateProfileCell", bundle: nil), forCellReuseIdentifier: tableIdentifierCell)
        
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.tableFooterView = footView
        
        NotificationCenter.default.addObserver(self, selector: #selector(CACreateProfileViewController.lastOptionsDidChanged(noti:)), name: CountryChooseLastOption, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CACreateProfileViewController.textDidChanged(noti:)), name: FormTextDidChanged, object: nil)
        
        initResourceData()
    }
    
    @objc func textDidChanged(noti: Notification) {
//        guard let data = noti.object as? TextFormFieldData else {return}
        
        let userProfile = userProfile()
        
        guard userProfile.name?.isEmpty == false else {
            showLoginButtonDisableStatus()
            return
        }
        
        guard userProfile.email?.isEmpty == false else {
            showLoginButtonDisableStatus()
            return
        }
        
        guard userProfile.password?.isEmpty == false else {
            showLoginButtonDisableStatus()
            return
        }
        
        guard userProfile.password_confirmation?.isEmpty == false else {
            showLoginButtonDisableStatus()
            return
        }
        
        guard userProfile.phone?.isEmpty == false else {
            showLoginButtonDisableStatus()
            return
        }
        
        guard userProfile.city_id?.isEmpty == false else {
            showLoginButtonDisableStatus()
            return
        }
        
        showLoginButtonenableStatus()
    }
    
    private func showLoginButtonDisableStatus() {
        confirmButton.backgroundColor = .init(hexValue: 0xDCDCDC)
        confirmButton.isEnabled = false
    }
    
    private func showLoginButtonenableStatus() {
        confirmButton.isEnabled = true
        confirmButton.backgroundColor = .cPrimary
    }
    
    @objc private func cancel() {
        
        if !isEmpty() {
            let tipVc = CALeaveViewController(target: Target(target: self, selector: #selector(CACreateProfileViewController.dismissAction(obj:))))
            self.present(tipVc, animated: false, completion: nil)
        } else {
            dismissAction(obj: "")
        }
    }
    
    @objc func dismissAction(obj:String) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func lastOptionsDidChanged(noti: Notification) {
        guard let data = noti.object as? DropdownFormFieldData else {return}
        
        if data.title == String.localized("create_profile_form_country", comment: "") {
            let item = data.selectedIndex.map {
                data.items[$0]
            }
            if let code = item?.id as? String , let usedCode = CountryCode(rawValue: code) {
                fetchCities(countryCode: usedCode)
            }
        }
        
        else if data.title == String.localized("create_profile_form_city", comment: "") {
            self.textDidChanged(noti: noti)
//            let item = data.selectedIndex.map {
//                data.items[$0]
//            }
//
//            if let city_id = item?.id as? String {
//                let userProfile = userProfile()
//            }
        }
        
    }
    
    func initResourceData() {
        
        let formData0 = TextFormFieldData(localizedTitleKey: .localized("create_profile_form_name", comment: ""))
        formData0.required = true
        formData0.placeholder = .localized("create_profile_form_name_placeholder", comment: "")
        
        let formData1 = TextFormFieldData(localizedTitleKey: .localized("create_profile_form_email", comment: ""))
        formData1.required = true
        formData1.placeholder = .localized("create_profile_form_email_placeholder", comment: "")
        formData1.keyboardType = .emailAddress
        
        let formData2 = TextFormFieldData(localizedTitleKey: .localized("create_profile_form_password", comment: ""))
        formData2.required = true
        formData2.placeholder = .localized("create_profile_form_password_placeholder", comment: "")
        formData2.isPassword = true
        formData2.canSeePassword = false
        
        let formData3 = TextFormFieldData(localizedTitleKey: .localized("create_profile_form_confirm_password", comment: ""))
        formData3.placeholder = .localized("create_profile_form_confirm_password_placeholder", comment: "")
        formData3.required = true
        formData3.isPassword = true
        formData3.canSeePassword = false

        datas.append(formData0)
        datas.append(formData1)
        datas.append(formData2)
        datas.append(formData3)
        
        let formData4 = DropdownFormFieldData(localizedTitleKey: .localized("create_profile_form_country", comment: ""))
        formData4.required = true
        formData4.placeholder = .localized("create_profile_form_country_placeholder", comment: "")
        datas.append(formData4)
        
        let formData5 = DropdownFormFieldData(localizedTitleKey: .localized("create_profile_form_city", comment: ""))
        formData5.required = true
        formData5.placeholder = .localized("create_profile_form_city_placeholder", comment: "")
        datas.append(formData5)
        
        let formData6 = TextFormFieldData(localizedTitleKey: .localized("create_profile_form_mobile_number", comment: ""))
        formData6.required = true
        formData6.placeholder = .localized("create_profile_form_mobile_number_placeholder", comment: "")
        formData6.keyboardType = .numberPad
        datas.append(formData6)
        
        tableView.reloadData()
        requestData()
    }
    
    private func requestData() {
        let userController: UserController! = AppServices.shared.find(UserController.self)
        
        LoadingView.showLoadingViewInView(view: self.view)
        
        userController.fetchUserCountries().done { [weak self] userCountries -> Void in
            guard let `self` = self else { return }
            
            for i in 0..<self.datas.count {
                let data = self.datas[i]
                if let formdata = data as? DropdownFormFieldData , formdata.title == String.localized("create_profile_form_country", comment: "") {
                    
                    var items = [DropdownItem]()
                    for country in userCountries {
                        let item = DropdownItem(id: country.countryCode ?? AppDataHelper.countryCode, name: (country.displayName ?? "") + " (+\(country.phoneCode ?? ""))" )
                        items.append(item)
                    }
                    formdata.items = items
                    formdata.selectedIndex = 0
                    self.datas[i] = formdata
//                    let defaultCountryCode = CountryCode(rawValue: (formdata.items.first?.id ?? "SG") as! String)
//                    self.fetchCities(countryCode: defaultCountryCode ?? AppDataHelper.countryCode)
                    break
                }
            }
            self.tableView.reloadData()
            
        }.catch { [weak self] _ in
            guard let `self` = self else { return }
            LoadingView.hideLoadingViewInView(view: self.view)
        }.finally { [weak self] in
            guard let `self` = self else { return }
        }
    }
    
    private func fetchCities(countryCode: CountryCode) {
        let controller: SellFlowController! = AppServices.shared.find(SellFlowController.self)
        
        controller.fetchCity(countryCode: countryCode).done { [weak self] cities -> Void in
            guard let `self` = self else { return }
            
            for i in 0..<self.datas.count {
                let data = self.datas[i]
                if let formdata = data as? DropdownFormFieldData , formdata.title == String.localized("create_profile_form_city", comment: "") {
                    
                    var items = [DropdownItem]()
                    for city in cities {
                        let item = DropdownItem(id: city.value, name: city.title )
                        items.append(item)
                    }
                    formdata.items = items
//                    formdata.selectedIndex = 0
                    self.datas[i] = formdata
                    break
                }
            }
            
            self.tableView.reloadData()
            
        }.catch { [weak self] _ in
            guard let `self` = self else { return }
            
        }.finally { [weak self] in
            guard let `self` = self else { return }
            LoadingView.hideLoadingViewInView(view: self.view)
        }
    }
    
    private func userProfile() -> UserProfile{
        var name = ""
        var email = ""
        var password = ""
        var password_confirmation = ""
        var country_code = ""
        var city_id = ""
        var phone = ""
        
        for data in datas {
            if let formdata = data as? TextFormFieldData , formdata.title == String.localized("create_profile_form_name", comment: "") {
                name = formdata.text ?? ""
            }else if let formdata = data as? TextFormFieldData , formdata.title == String.localized("create_profile_form_email", comment: "") {
                email = formdata.text ?? ""
            } else if let formdata = data as? TextFormFieldData , formdata.title == String.localized("create_profile_form_password", comment: "") {
                password = formdata.text ?? ""
            } else if let formdata = data as? TextFormFieldData , formdata.title == String.localized("create_profile_form_confirm_password", comment: "") {
                password_confirmation = formdata.text ?? ""
            } else if let formdata = data as? DropdownFormFieldData , formdata.title == String.localized("create_profile_form_country", comment: "") {
                country_code = formdata.selectedIndex.map {
                    formdata.items[$0].id as? String ?? ""
                } ?? ""
            } else if let formdata = data as? DropdownFormFieldData , formdata.title == String.localized("create_profile_form_city", comment: "") {
                city_id = formdata.selectedIndex.map {
                    let cityId = formdata.items[$0].id as? NSNumber
                    return cityId?.stringValue ?? ""
                } ?? ""
            } else if let formdata = data as? TextFormFieldData , formdata.title == String.localized("create_profile_form_mobile_number", comment: "") {
                phone = formdata.text ?? ""
            }
        }
        
        let userProfile = UserProfile(name: name,email: email, password: password, password_confirmation: password_confirmation, country_code: country_code, city_id: city_id, phone: phone)
        
        return userProfile
    }
    
    private func isEmpty() -> Bool {
        let profile = userProfile()
        if profile.email?.isEmpty == false || profile.password?.isEmpty == false || profile.password_confirmation?.isEmpty == false || profile.phone?.isEmpty == false || profile.name?.isEmpty == false {
            return false
        }
        return true
    }
    
    private func canSubmit() -> Bool {
        guard self.datas.count > 0 else {
            return false
        }
        return true
        
//        var isCanSubmit = true
//        let password = self.datas[2].text ?? ""
//        let password_confirmation = self.datas[3].text ?? ""
//
//        if !password.isEmpty , !password_confirmation.isEmpty {
//
//            var errorMessage = ""
//            if  password != password_confirmation , (password.count < 6 || password_confirmation.count < 6) {
//                errorMessage.append(String.localized("create_profile_form_incorrect_passwords", comment: ""))
//                errorMessage.append(String.localized("create_profile_form_incorrect_passwords_characters", comment: ""))
//                self.datas[2].isShowErrorMsg = true
//                self.datas[3].isShowErrorMsg = true
//                isCanSubmit = false
//            } else if password != password_confirmation {
//                errorMessage.append(String.localized("create_profile_form_incorrect_passwords", comment: ""))
//                self.datas[2].isShowErrorMsg = true
//                self.datas[3].isShowErrorMsg = true
//                isCanSubmit = false
//            } else if password.count < 6 || password_confirmation.count < 6 {
//                errorMessage.append(String.localized("create_profile_form_incorrect_passwords_characters", comment: ""))
//                self.datas[2].isShowErrorMsg = true
//                self.datas[3].isShowErrorMsg = true
//                isCanSubmit = false
//            }
//            footLabel?.text = errorMessage
//        }
//
//        return isCanSubmit
    }
    
    private func showRedBox(type: String) {
        
        for data in datas {
            if let formdata = data as? TextFormFieldData , formdata.title == String.localized("create_profile_form_email", comment: "") {
                if type == "email" {
                    formdata.isShowErrorMsg = true
                }
            }
            if let formdata = data as? TextFormFieldData , formdata.title == String.localized("create_profile_form_password", comment: "") {
                if type == "password" {
                    formdata.isShowErrorMsg = true
                }
            }
            if let formdata = data as? TextFormFieldData , formdata.title == String.localized("create_profile_form_confirm_password", comment: "") {
                if type == "password" {
                    formdata.isShowErrorMsg = true
                }
            }
            if let formdata = data as? DropdownFormFieldData , formdata.title == String.localized("create_profile_form_country", comment: "") {
            }
            if let formdata = data as? DropdownFormFieldData , formdata.title == String.localized("create_profile_form_city", comment: "") {
                if type == "city_id" {
                    formdata.isShowErrorMsg = true
                }
            }
            if let formdata = data as? TextFormFieldData , formdata.title == String.localized("create_profile_form_mobile_number", comment: "") {
                if type == "phone" {
                    formdata.isShowErrorMsg = true
                }
            }
        }
        
        tableView.reloadData()
    }
    
    @IBAction func createProfile(_ sender: UIButton) {
        
        let userProfile = userProfile()
        
//        if userProfile.email?.isEmail == false {
//            footLabel?.isHidden = false
//            return
//        }
        if !canSubmit() {
            footLabel?.isHidden = false
            tableView.reloadData()
            return
        }
        
        let controller: SellFlowController! = AppServices.shared.find(SellFlowController.self)
        
        LoadingView.showLoadingViewInView(view: self.view)
        controller.createProfile(profile: userProfile).done { [weak self] cities -> Void in
            guard let `self` = self else { return }
            self.navigationController?.pushViewController(CACreateProfileSuccessViewController(user: userProfile, pageType: .guest), animated: true)
        }.catch { [weak self] error in
            guard let `self` = self else { return }
            
            switch error {
            case let ApiError.formError(_, errors):
                var errorMessage = ""
                if let emailError = errors["email"]?.first {
                    errorMessage.append(emailError)
                    errorMessage.append("\n")
                    self.showRedBox(type: "email")
                }
                if let passwordError = errors["password"]?.first {
                    errorMessage.append(passwordError)
                    errorMessage.append("\n")
                    self.showRedBox(type: "password")
                } else {
                    self.datas[2].isShowErrorMsg = false
                    self.datas[3].isShowErrorMsg = false
                }
                
                if let phoneError = errors["phone"]?.first {
                    errorMessage.append(phoneError)
                    errorMessage.append("\n")
                    self.showRedBox(type: "phone")
                }
                
                if let cityError = errors["city_id"]?.first {
                    errorMessage.append(cityError)
                    errorMessage.append("\n")
                    self.showRedBox(type: "city_id")
                }
                
                self.footLabel?.text = errorMessage
                self.footLabel?.isHidden = false
           
            default:
                UIAlertController.showErrorMessage(error: error, from: self)
            }
            
        }.finally { [weak self] in
            guard let `self` = self else { return }
            LoadingView.hideLoadingViewInView(view: self.view)
        }
    }
}

extension CACreateProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableIdentifierCell, for: indexPath) as! CACreateProfileCell
        cell.selectionStyle = .none
        let fieldData = datas[indexPath.row]
        cell.bind(data: fieldData)
        return cell
    }
}

extension CACreateProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69
    }
}
