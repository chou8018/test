//
//  CAExpensesViewController.swift
//  ClaimApp
//
//  Created by wanggao on 2022/8/27.
//

import UIKit
import EmptyDataSet_Swift
import ESPullToRefresh
import CoreMIDI
import Siren
import SnapKit

enum CAExpensesType: String {
    case personal = "personal"
    case inventory = "inventory"
}

enum CAIncludeType: String {
    case vendor = "vendor"
    case carplate = "carplate"
    case category = "category"
    case payee = "payee"
}

class CAExpensesViewController: CABaseViewController {
    
    private let tableIdentifierCell = "tableIdentifierCell"
    private let sectionHeaderId = "sectionHeaderId"

    @IBOutlet weak var personalButton: UIButton!
    @IBOutlet weak var inventoryButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createButton: UIButton!
    private var presenter : CAListPresenter!
    @IBOutlet weak var subHeadView: UIView!
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var guestHeadLabel: UILabel!
    
    @IBOutlet weak var switchButtonView: UIView!
    private var usedListData: [LNListMainData]? = nil
    
    var expensesType: CAExpensesType = .personal {
        didSet {
//            readListDataFromDataBase()
        }
    }
    
//    var sectionDatas = [CASectionData]()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated:false);
        self.navigationItem.title = String.localized("my_expenses_nav_title", comment: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = String.localized("my_expenses_nav_title", comment: "")
        let rightItem = UIBarButtonItem(image: UIImage(named: "icon-account"), style: .done, target: self, action: #selector(rightBarBtnItemClick))
        self.navigationItem.rightBarButtonItem = rightItem
        
//        let leftItem = UIBarButtonItem(image: UIImage(named: "icon-account"), style: .done, target: self, action: #selector(leftBarBtnItemClick))
        self.navigationItem.leftBarButtonItem = nil
        
        createButton.setShadow(sColor: UIColor(red: 66, green: 92, blue: 200, alp: 0.36), offset: CGSize(width: -3, height: 3), opacity: 0.8, radius: 5)
        subHeadView.setShadow(sColor: .gray, offset: .zero, opacity: 0.3, radius: 8)
        headView.height = 0
        
        if !isVerified() {
            headView.height = 100
            headView.isHidden = false
            createButton.isHidden = true
            let guestHeadText = String.localized("create_profile_form_expense_head_first", comment: "") + String.localized("create_profile_form_expense_head_second", comment: "")
            guestHeadLabel.attributedText = NSMutableAttributedString.attributedString(string: guestHeadText, rangeString: String.localized("create_profile_form_expense_head_second", comment: "") , font: UIFont.mediumCustomFont(ofSize: 14))

        }
        
        presenter = CAListPresenter()
        presenter.delegate = self
        
//        readListDataFromDataBase()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        tableView.register(UINib.init(nibName: "CAExpensesCell", bundle: nil), forCellReuseIdentifier: tableIdentifierCell)
        tableView.register(UINib.init(nibName: "CAExpensesCellHeadView", bundle: nil), forHeaderFooterViewReuseIdentifier: sectionHeaderId)
        
        self.tableView.es.addPullToRefresh {
            [unowned self] in
            self.refreshData()
        }
        self.tableView.es.startPullToRefresh()
        
        if AppDataHelper.countryCode == .TH {
            switchButtonView.isHidden = true
            tableView.snp.remakeConstraints { make in
                make.top.leading.bottom.trailing.equalToSuperview()
            }
            expensesType = .inventory
        }
    }
    
    private func isVerified() -> Bool {
        if let user = AppDataHelper.user , user.isVerified == true {
            return true
        }
        return false
    }
    
    override func initLocalString() {
        super.initLocalString()
        personalButton.setTitle(String.localized("my_expenses_button_title_personal", comment: ""), for: .normal)
        inventoryButton.setTitle(String.localized("my_expenses_button_title_inventory", comment: ""), for: .normal)
        checkVersion()
        
        NotificationCenter.default.addObserver(self, selector: #selector(processPendingNotifications), name: AppDidReceiveBackgroundNotification, object: nil)
    }
    
    private func requestUserInfo() {
        guard let phone = AppDataHelper.user?.phone else {
            return
        }
        
        let controller: SellFlowController! = AppServices.shared.find(SellFlowController.self)

        controller.fetchUserInformation(phone: phone).done { [weak self] user -> Void in
            guard let `self` = self else { return }
            AppDataHelper._user = user
            
            if user.isVerified {
                self.headView.height = 0
                self.headView.isHidden = true
                self.createButton.isHidden = false
                self.tableView.reloadData()
            }
   
            UserDefaults.standard.set(user.name, forKey: AppConfig.currentUserNameKey)
            UserDefaults.standard.set(user.phone, forKey: AppConfig.currentUserPhoneKey)
            UserDefaults.standard.set(user.email, forKey: AppConfig.currentUserEmailKey)
            UserDefaults.standard.set(user.id, forKey: AppConfig.currentUserIdKey)
            UserDefaults.standard.set(user.profileImageUrl, forKey: AppConfig.currentUserImageKey)
            UserDefaults.standard.synchronize()
            
        }.catch { [weak self] error in
            guard let `self` = self else { return }
//            UIAlertController.showErrorMessage(error: error, from: self)

        }.finally { [weak self] in
            guard let `self` = self else { return }
            LoadingView.hideLoadingViewInView(view: self.view)
        }
    }
    
    @objc func processPendingNotifications() {
        
        let pushNotificationController = AppServices.shared.find(PushNotificationController.self)
        
        guard let notificationInfo = pushNotificationController?.getLastNotification() else { return }

        if let kindValue = notificationInfo.string("action") {
            
            if kindValue == "open_submission_view_page" {
                let id = notificationInfo.lenientNumber("expense_id")
                if let usedId = id {
                    showExpenseDetailPage(id: usedId)
                }
            } else if kindValue == "verification_approved" {
                self.requestUserInfo()
            }
      
        }
        pushNotificationController?.setLastNotification(lastNotification: nil)
    }
    
    func showExpenseDetailPage(id: NSNumber) {
        let data = LNListData(json: ["id":id.intValue])
        if let useData = data {
            let vc = THExpenseDetailViewController(type: expensesType, data: useData)
             self.navigationController?.pushViewController(vc, animated: true)
        }
        refreshData()
    }
    
    func checkVersion() {
        guard let appVersion = AppConfig.version?.components(separatedBy: ".") else {
            return
        }
        let mobileVersion = AppServices.shared.find(RemoteConfigController.self)?.mobileVersion
        let latestVersion = mobileVersion?.versionUpdate?.latestVersion?.components(separatedBy: ".") ?? []
        let forceUpdate = mobileVersion?.versionUpdate?.isForceUpdate ?? false;
        
        var isOutdated: Bool = false
        for i in 0..<4 {
            let latest: Int = i < latestVersion.count ? Int(latestVersion[i]) ?? 0 : 0
            let app: Int = i < appVersion.count ? Int(appVersion[i]) ?? 0 : 0
            
            if latest > app {
                isOutdated = true
                break
            } else if latest < app {
                isOutdated = false
                break
            }
        }
        if forceUpdate && isOutdated {
            Siren.shared.rulesManager = RulesManager(
                majorUpdateRules: .critical,
                minorUpdateRules: .critical,
                patchUpdateRules: .critical,
                revisionUpdateRules: .critical
            )
        } else {
            Siren.shared.rulesManager = RulesManager(
                majorUpdateRules: .critical,
                minorUpdateRules: .persistent,
                patchUpdateRules: .default,
                revisionUpdateRules: .relaxed
            )
        }
        
        if let desc = mobileVersion?.versionUpdate?.updateDesc,
        let title = mobileVersion?.versionUpdate?.updateTitle {
            Siren.shared.presentationManager = PresentationManager(
                alertTitle: title,
                alertMessage: desc
            )
        }

        let userController = AppServices.shared.find(UserController.self)
        Siren.shared.apiManager = APIManager(countryCode: userController?.user?.countryCode.rawValue)
        Siren.shared.wail(performCheck: .onDemand, completion: nil)
        Siren.shared.wail(performCheck: .onForeground, completion: nil)
    }
    
    @objc func rightBarBtnItemClick(){
        self.navigationController?.pushViewController(CAProfileViewController(), animated: true)
    }
    
    @objc func leftBarBtnItemClick(){
        self.requestUserInfo()
    }
    
    @IBAction func personalButtonClicked(_ sender: UIButton) {
        switchTopButton(type: .personal, unSelectButton: inventoryButton, selectButton: personalButton)
    }
    
    @IBAction func inventoryButtonClicked(_ sender: UIButton) {
        switchTopButton(type: .inventory, unSelectButton: personalButton, selectButton: inventoryButton)
    }
    
    private func switchTopButton(type: CAExpensesType , unSelectButton: UIButton , selectButton: UIButton) {
        guard expensesType != type else {
            return
        }
        unSelectButton.setTitleColor(.personalButtonUnselect, for: .normal)
        selectButton.setTitleColor(.cPrimary, for: .normal)
        expensesType = type
//        tableView.es.startPullToRefresh()
        presenter.loadList(type: expensesType)
    }
    
    @IBAction func createFileButtonClicked(_ sender: UIButton) {
        
        self.present(THNewExpensesViewController(type: expensesType, data: nil,target: Target(target: self, selector: #selector(CAExpensesViewController.saveDataSuccess))), animated: true)
        
//        if AppDataHelper.countryCode == .TH {
//            self.present(THNewExpensesViewController(type: expensesType, data: nil,target: Target(target: self, selector: #selector(CAExpensesViewController.saveDataSuccess))), animated: true)
//        } else {
//            self.present(CANewExpensesViewController(type: expensesType, data: nil,target: Target(target: self, selector: #selector(CAExpensesViewController.saveDataSuccess))), animated: true)
//        }
    }
    
    private func switchTab(type: CAExpensesType) {

        if type == .personal {
            switchTopButton(type: .personal, unSelectButton: inventoryButton, selectButton: personalButton)
        }else{
            switchTopButton(type: .inventory, unSelectButton: personalButton, selectButton: inventoryButton)
        }
    }
    
    @objc func refreshData() {
        presenter.refreshList(type: self.expensesType)
    }
    
    @objc func saveDataSuccess(type:String) {
        
        if let type = CAExpensesType.init(rawValue: type) {
            switchTab(type: type)
            return
        }
        
        if type != "draft_data" {
            self.view.makeCarroToast(String.localized("toast_title_added", comment: ""), position: .center, image:UIImage(named: "icon-done"))
        }
        presenter.loadList(type: self.expensesType)
    }
    
    @objc func lastButtonClicked(sender: UIButton){
        guard let index = sender.superview?.tag else {return}
        guard let dateString = presenter.dataSource[index - 200].dateTitle else {return}
        countDate(dateString: dateString, isAdd: false)
    }
    
    @objc func nextYearButtonClicked(sender: UIButton){
        guard let index = sender.superview?.tag else {return}
        guard let dateString = presenter.dataSource[index - 200].dateTitle else {return}
        countDate(dateString: dateString)
    }
    
    private func countDate(dateString: String, isAdd: Bool?=true) {
        
        let dateF = DateFormatter()
        dateF.dateFormat = "M"
        let dateMonth = DateFormatter.MMMyyyy.date(from: dateString)?.string(with: dateF) ?? ""
        dateF.dateFormat = "yyyy"
        let dateYear = DateFormatter.MMMyyyy.date(from: dateString)?.string(with: dateF) ?? ""
        
        guard var intMonth = Int(dateMonth), var intYear = Int(dateYear) else {return}
        
        if let isAdd = isAdd {
            if isAdd {
                if intMonth == 12 {
                    intMonth = 1
                    intYear += 1
                }else{
                    intMonth += 1
                }
            }else{
                if intMonth == 1 {
                    intMonth = 12
                    intYear -= 1
                }else{
                    intMonth -= 1
                }
            }
        }
        let useDateString = "\(intMonth) \(intYear)"
        dateF.dateFormat = "M yyyy"
        var year_month = ""
        if let useDate = dateF.date(from: useDateString) {
            year_month = DateFormatter.MMMMyyyy.string(from: useDate)
        }
        filterCorrespondingData(year_month: year_month)
    }
    

    @objc func yearClicked(ges: UITapGestureRecognizer){
        guard let index = ges.view?.superview?.tag else {return}
        guard let date = presenter.dataSource[index - 200].currentDate else {return}

        let vc = THMonthSelectViewController(target: Target(target: self, selector: #selector(CAExpensesViewController.dismissAction(obj:))), currentDate: date)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion:nil)
    }

    @objc func dismissAction(obj: String) {
        filterCorrespondingData(year_month: obj)
    }
    
    
    private func filterCorrespondingData(year_month: String) {
        var tempData = [LNListMainData]()
        var tempListData = [LNListMainData]()
        if let existData = usedListData {
            self.presenter.dataSource = existData
        }
        for useData in self.presenter.dataSource {
            if useData.draftTitle?.isEmpty == false, (useData.items?.count ?? 0) > 0 {
                tempData.append(useData)
            } else if let date = useData.date , date == year_month {
                tempData.append(useData)
                tempListData.append(useData)
            }
        }
        if tempListData.count == 0 , let mainData = LNListMainData(json: ["date":year_month]) {
            tempData.append(mainData)
        }
        self.presenter.dataSource = tempData
        self.tableView.reloadData()
    }
    
}

extension CAExpensesViewController: EmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        
        var attributes: [NSAttributedString.Key: Any] = [:]
        
        attributes[NSAttributedString.Key.font] = UIFont.mediumCustomFont(ofSize:16)
        attributes[NSAttributedString.Key.foregroundColor] = UIColor.personalButtonUnselect
        
        var message = String.localized("my_expenses_title_create_expense", comment: "")
        
        if !isVerified() {
            message = String.localized("create_profile_form_title_guest_empty", comment: "")
        }
        return NSAttributedString.init(string: message, attributes: attributes)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        if !isVerified() {
            return UIImage(named: "UserAdd")
        }
        return UIImage(named: "file-add")
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -30
    }
}

extension CAExpensesViewController: EmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
}

extension CAExpensesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.dataSource.count
//        return sectionDatas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return sectionDatas[section].datas.count
        return presenter.dataSource[section].items?.count ?? 0

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableIdentifierCell, for: indexPath) as! CAExpensesCell
        cell.selectionStyle = .none
//        let subData = self.sectionDatas[indexPath.section].datas[indexPath.row]
//
        let section = presenter.dataSource[indexPath.section]
        let item = section.items?[indexPath.row]
        if let usedItem = item as? LNListData {
            cell.configApiData(data: usedItem)
        }else if let subData = item as? CAExpenseListData{
            cell.config(data: subData)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderId) as! CAExpensesCellHeadView
        
        guard presenter.dataSource.count > section else {
            return nil
        }
        
        if let _ = presenter.dataSource[section].draftTitle ,section == 0 , presenter.dataSource[section].items?.count ?? 0 == 0 {
            return nil
        }

        
        let date = presenter.dataSource[section].date
        if AppDataHelper.languageCode == .indonesian || AppDataHelper.languageCode == .thai {
            let arr0 = date?.split(separator: " ")
            let str0 = String(arr0?.first ?? "")
            let str1 = String(arr0?.last ?? "")
            var usedDate = str0
            switch str0 {
            case "January":
                usedDate = String.localized("month_date_title_january", comment: "")
                break
            case "February":
                usedDate = String.localized("month_date_title_february", comment: "")
                break
            case "March":
                usedDate = String.localized("month_date_title_march", comment: "")
                break
            case "April":
                usedDate = String.localized("month_date_title_april", comment: "")
                break
            case "May":
                usedDate = String.localized("month_date_title_may", comment: "")
                break
            case "June":
                usedDate = String.localized("month_date_title_june", comment: "")
                break
            case "July":
                usedDate = String.localized("month_date_title_july", comment: "")
                break
            case "August":
                usedDate = String.localized("month_date_title_august", comment: "")
                break
            case "September":
                usedDate = String.localized("month_date_title_september", comment: "")
                break
            case "October":
                usedDate = String.localized("month_date_title_october", comment: "")
                break
            case "November":
                usedDate = String.localized("month_date_title_november", comment: "")
                break
            case "December":
                usedDate = String.localized("month_date_title_december", comment: "")
                break
            default:
                break
            }

            header.titleLabel.text = usedDate + " \(str1)"
        } else {
            if let title = presenter.dataSource[section].draftTitle {
                header.titleLabel.text = title
                header.hideLeftAndRightArrowButton()
                header.titleLabel.gestureRecognizers?.removeAll()
            } else {
                header.showLeftAndRightArrowButton()
                header.titleLabel.text = presenter.dataSource[section].dateTitle
                if presenter.dataSource[section].dateTitle == presenter.dataSource[section].lastMonthOfCurrentYear {
                    header.rightButton.isEnabled = false
                }else{
                    header.rightButton.isEnabled = true
                }
                let ges = UITapGestureRecognizer(target: self, action: #selector(yearClicked(ges:)))
                header.titleLabel.addGestureRecognizer(ges)
                header.tag = 200+section
            }
        }
        
        header.leftButton.addTarget(self, action: #selector(lastButtonClicked(sender:)), for: .touchUpInside)
        header.rightButton.addTarget(self, action: #selector(nextYearButtonClicked(sender:)), for: .touchUpInside)

        return header
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let data = presenter.dataSource[indexPath.section].items?[indexPath.row] as? LNListData, data.status == .notSubmitted {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return ""
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            swipeDeleteData(indexPath: indexPath)
        }
    }
    
    func swipeDeleteData(indexPath: IndexPath) {
        
        if let data = presenter.dataSource[indexPath.section].items?[indexPath.row] , let usedData = data as? LNListData , usedData.status == .notSubmitted {
            let userController: SellFlowController! = AppServices.shared.find(SellFlowController.self)
            userController.deleteDraft(id: usedData.id.stringValue).done {[weak self] selfImage in
                guard let self = self else {return}
                self.presenter.refreshList(type: self.expensesType)
                self.view.makeCarroToast(String.localized("toast_title_removed", comment: ""), position: .center, image:UIImage(named: "icon-cancel"))
            }.catch { [weak self] error in
                guard let self = self else {return}
                UIAlertController.showErrorMessage(error: error, from: self)
            }
        }
    }
}

extension CAExpensesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, resultClosure) in
            guard let `self` = self else {
                return
            }
            self.swipeDeleteData(indexPath: indexPath)
        }
        deleteAction.backgroundColor = .init(hexValue: 0x161C24)
        let actions = UISwipeActionsConfiguration(actions: [deleteAction])
        actions.performsFirstActionWithFullSwipe = false
        return actions
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if #available(iOS 11.0, *) {
            for subView in tableView.subviews {
                if NSStringFromClass(subView.classForCoder) == "UISwipeActionPullView" {
                    if let deleteBtn: UIButton = subView.subviews.last as? UIButton  {
                        changeAction(sourceBtn: deleteBtn, title: String.localized("my_expenses_title_swipe_remove", comment: ""), imageStr: "nil")
                    }
                }  else if NSStringFromClass(subView.classForCoder) == "_UITableViewCellSwipeContainerView" {
                    // iOS13.0之后
                    subView.backgroundColor = .init(hexValue: 0x161C24)
                    for sub in subView.subviews {
                        if NSStringFromClass(sub.classForCoder) == "UISwipeActionPullView" {
                            if let deleteBtn: UIButton = sub.subviews.last as? UIButton  {
                                deleteBtn.backgroundColor = subView.backgroundColor
                                changeAction(sourceBtn: deleteBtn, title: String.localized("my_expenses_title_swipe_remove", comment: ""), imageStr: "nil")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func changeAction(sourceBtn: UIButton, title: String?, imageStr: String?) {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 8, y: 0, width: sourceBtn.frame.width, height: sourceBtn.frame.height)
        btn.backgroundColor = sourceBtn.backgroundColor
        btn.setImage(UIImage(named: imageStr ?? ""), for: .normal)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = .mediumCustomFont(ofSize: 14)
        btn.contentHorizontalAlignment = .center
        btn.isUserInteractionEnabled = true
        sourceBtn.addSubview(btn)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        if let data = presenter.dataSource[indexPath.section].items?[indexPath.row] as? LNListData {
            if data.status == .notSubmitted {
                self.present(THNewExpensesViewController(type: expensesType, data: data, target: Target(target: self, selector: #selector(CAExpensesViewController.saveDataSuccess(type:)))), animated: true)
            }else{
               let vc = THExpenseDetailViewController(type: expensesType, data: data)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90 + 8
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        guard presenter.dataSource.count > section else {
            return 0.01
        }
        let data = presenter.dataSource[section]
        if let _ = data.draftTitle , data.items?.count ?? 0 == 0 ,section == 0 {
            return 0.01
        }
        return 50
    }
    
}

extension CAExpensesViewController: CAListPresenterDelegate {
    func handleListDidLoad() {
//        self.tableView.reloadData()
        usedListData = presenter.dataSource
        
        countDate(dateString: DateFormatter.MMMyyyy.string(from: Date()), isAdd: nil)
    }
    
    func showLoadingIndicator() {
        LoadingView.showLoadingViewInView(view: self.view)
    }
    
    func hideLoadingIndicator() {
        tableView.es.stopPullToRefresh()
        LoadingView.hideLoadingViewInView(view: self.view)
    }
    
    func startRefreshing() {
    }
    
    func stopRefreshing() {
        tableView.es.stopPullToRefresh()
    }
    
    func hideErrorOrEmptyState() {
    }
    
    func willLoadsList() {
    }
    
    func showEmptyState() {
    }
    
    func showErrorState(error: Error) {
    }
    
}
