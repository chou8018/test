//
//  THExpemseDetailCell.swift
//  ClaimApp
//
//  Created by 付耀辉 on 2022/10/11.
//

import UIKit

class THExpemseDetailCell: UITableViewCell {
    
    @IBOutlet weak var submitMark: PaddingLabel!
    @IBOutlet weak var mainView: UIView!
    
    let normalSection = 1
    let amountSection = 2
    let captureSection = 3
    let pyamentInfoSection = 4

    private let tableIdentifierCell = "tableIdentifierCell"
    private let tableAmountIdentifierCell = "tableAmountIdentifierCell"
    private let tableAmountFootIdentifierCell = "tableAmountFootIdentifierCell"
    private let tableCaptureHeaderIdentifierCell = "tableCaptureHeaderIdentifierCell"
    private let tableCapturePhotoIdentifierCell = "tableCapturePhotoIdentifierCell"
    private let tableCostItemIdentifierCell = "tableCostItemIdentifierCell"
    private let tablePaymentCurrencyIdentifierCell = "tablePaymentCurrencyIdentifierCell"

    let sectionHeaderHeight:CGFloat = 45

    var datas: [[FormFieldData]] = [] {
        didSet {
            mainTableView.reloadData()
        }
    }
    
    var expensesType: CAExpensesType = .inventory

    var draft: CAExpenseDraft!
    
    var mainTableView : UITableView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization .
        
        mainView.superview?.setShadow(sColor: .lightGray, offset: .zero, opacity: 0.3, radius: 5)
        
        submitMark.text = String.localized("new_expenses_title_not_saved", comment: "")
        submitMark.textAlignment = .center
        submitMark.textColor = .white
        if AppDataHelper.languageCode == .thai {
            submitMark.font = .customFont(ofSize: 11)
            submitMark.textInsets = UIEdgeInsets(top: 2.5, left: 0, bottom: 2, right: 0)
        }else{
            submitMark.font = .customFont(ofSize: 12)
        }
        submitMark.cornerRadius = submitMark.height/2
        
        mainTableView = UITableView.init(frame: mainView.bounds, style: .grouped)
        mainTableView.estimatedRowHeight = 100
        mainTableView.delegate = self
        mainTableView.separatorColor = .clear
        mainTableView.dataSource = self
        mainTableView.cornerRadius = 5
        mainView.addSubview(mainTableView)
        mainTableView.isScrollEnabled = false
        mainTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        registerCell()
    }
    
    private func registerCell() {
        mainTableView.register(UINib.init(nibName: "CANewExpensesNormalCell", bundle: nil), forCellReuseIdentifier: tableIdentifierCell)
        mainTableView.register(UINib.init(nibName: "THNewExpensesAmountCell", bundle: nil), forCellReuseIdentifier: tableAmountIdentifierCell)
        mainTableView.register(UINib.init(nibName: "CAExpensesTipsHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: tableCaptureHeaderIdentifierCell)
        mainTableView.register(UINib.init(nibName: "CAExpensesCaptureCell", bundle: nil), forCellReuseIdentifier: tableCapturePhotoIdentifierCell)
        mainTableView.register(UINib.init(nibName: "THCostTotalCell", bundle: nil), forCellReuseIdentifier: tableCostItemIdentifierCell)
        mainTableView.register(UINib.init(nibName: "THPaymentCurrencyCell", bundle: nil), forCellReuseIdentifier: tablePaymentCurrencyIdentifierCell)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.estimatedRowHeight = 0
        mainTableView.estimatedSectionFooterHeight = 0
        mainTableView.estimatedSectionHeaderHeight = 0
        mainTableView.backgroundColor = .white
        UITableView().estimatedRowHeight = 0
        UITableView().estimatedSectionFooterHeight = 0
        UITableView().estimatedSectionHeaderHeight = 0
    }
    
    func initResource(datas: [[FormFieldData]], draft: CAExpenseDraft, expensesType: CAExpensesType) {
        
        self.datas = datas
        self.draft = draft
        self.expensesType = expensesType
        
        let titleAndColor = draft.submitTitleAndTitleBackgroundColor()
        submitMark.text = titleAndColor.0
        submitMark.backgroundColor = titleAndColor.1
        submitMark.isHidden = false
        
        let normalCellCount = CGFloat(datas[normalSection].count + datas[pyamentInfoSection].count)
        let costCellHeight:CGFloat = 215
        let kSpace:CGFloat = 16
        var rowHeight:CGFloat = 69*normalCellCount + kSpace + costCellHeight + sectionHeaderHeight
        
        if expensesType == .personal {
//            rowHeight = 69*3 + 16
        }
        
        if let fieldData = datas[captureSection].first as? PhotoFormFieldData, fieldData.images.count > 0 {
            let imageCellHeight:CGFloat = 160
            rowHeight += imageCellHeight
        }else{
            rowHeight += 12
        }
        
        for data in datas[amountSection] {
            guard let data = data as? ItemsFormFieldData else { return }
            
            let descripBaseHeight:CGFloat = 32

            let itemCellHeight: CGFloat = expensesType == .personal ? 0 : (data.items.count > 4 ? 46 : 0)
            if let _ = data.status, data.items.last?.text?.isEmpty ?? true {
                rowHeight = rowHeight + THNewExpensesAmountCell.useBaseRowHeight + itemCellHeight - descripBaseHeight
            }else{
                
                let descrip = GrowingTextView()
                var showText =  data.items.last?.text?.replacingOccurrences(of: "\n", with: " ")
                descrip.text = showText
                descrip.font = .systemFont(ofSize: 15)
                let borderSpaace:CGFloat = 32 + 45
                let size = descrip.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - borderSpaace, height: CGFloat.greatestFiniteMagnitude))
                rowHeight = rowHeight + THNewExpensesAmountCell.useBaseRowHeight + itemCellHeight - descripBaseHeight + size.height
            }
        }
        
        if self.draft.is_automate_data, let header = self.tableView(self.mainTableView, viewForHeaderInSection: captureSection) as? CAExpensesTipsHeaderView  {
            let borderSpace:CGFloat = 48
            let size = header.textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - borderSpace, height: CGFloat.greatestFiniteMagnitude))
            rowHeight = rowHeight + size.height + 16
        }
        
        let submitMarkAndTopSpace:CGFloat = 76
        let bottomSpace:CGFloat = 10

        draft.rowHeight = rowHeight + submitMarkAndTopSpace + 32 + bottomSpace
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}



extension THExpemseDetailCell: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == captureSection {
            if let fieldData = datas[section].first as? PhotoFormFieldData, fieldData.images.count > 0 {
            }else{
                return 0
            }
        }
        return datas[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let fieldData = datas[indexPath.section][indexPath.row]
        fieldData.isDetail = true
        
        if let photoData = fieldData as? PhotoFormFieldData, photoData.images.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: tableCapturePhotoIdentifierCell, for: indexPath) as! CAExpensesCaptureCell
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = true
            cell.photo.isUserInteractionEnabled = true
            cell.bind(data: photoData)
            cell.removeButton.isHidden = true
            return cell
        }else if let itemData = fieldData as? ItemsFormFieldData {
            let cell = tableView.dequeueReusableCell(withIdentifier: tableAmountIdentifierCell) as! THNewExpensesAmountCell
            cell.bind(data: itemData)
            cell.removeButton.isHidden = indexPath.row <= 0
            cell.removeButton.tag = indexPath.row+100
            cell.removeButton.isHidden = true
            cell.netLabel.text = "Net"
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
            return cell
        } else if let itemData = fieldData as? THCostItemData {
            let cell = tableView.dequeueReusableCell(withIdentifier: tableCostItemIdentifierCell, for: indexPath) as! THCostTotalCell
            cell.bind(data: itemData)
            cell.titleLabel.text = "Expense Amount"
            cell.selectionStyle = .none
            return cell
        } else if let itemData = fieldData as? PaymentCurrencyData {
            let cell = tableView.dequeueReusableCell(withIdentifier: tablePaymentCurrencyIdentifierCell, for: indexPath) as! THPaymentCurrencyCell
            cell.isDetail = true
            cell.bind(data: itemData)
            cell.selectionStyle = .none
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: tableIdentifierCell, for: indexPath) as! CANewExpensesNormalCell
            cell.selectionStyle = .none
            cell.bind(data: fieldData)
            cell.isUserInteractionEnabled = false
            cell.iconButton.isHidden = true
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: sectionHeaderHeight))
            let view = UIView(frame: CGRect(x: 16, y: 0, width: (window?.windowScene?.screen.bounds.width ?? 0) - 64, height: 35))
            view.backgroundColor = .init(hexValue: 0xF1F8FF)
            view.cornerRadius = 6
            let label = UILabel(frame: CGRect(x: 12, y: 0, width: view.width-32, height: view.height))
            label.text = section == 0 ? "Expense Amount" : "Expense Details"
            label.textColor = .init(hexValue: 0x4082FF)
            label.font = .mediumCustomFont(ofSize: 14)
            view.addSubview(label)
            bottomView.addSubview(view)
            return bottomView
        }

        if section == captureSection, self.draft.is_automate_data {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: tableCaptureHeaderIdentifierCell) as! CAExpensesTipsHeaderView
            if self.draft.receipt_files?.count ?? 0 > 0 {
                header.textView.text = "For more information, please view the receipt. The expense is a bulk submission, no items will be listed."
            }else{
                header.textView.text = "A receipt was not filed; you may view the details on CAPtain. The expense is a bulk submission, no items will be listed."
            }
            header.backgroundColor = .white
            return header
        }
        let view = UIView()
        view.backgroundColor = .white
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }

}

extension THExpemseDetailCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == amountSection {
            if let data = datas[amountSection][indexPath.row] as? ItemsFormFieldData {
                return data.rowHeight - (data.isPersonal ? 36+10 : 0)
            }
        } else if indexPath.section == captureSection {
            
            if let formData = datas[captureSection].first as? PhotoFormFieldData, formData.images.count > 0 {
                return 160 + 16
            }
            return 0
        }else if indexPath.section == 0 {
            return 226
        }
        return 69
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return sectionHeaderHeight
        }
        if self.draft != nil, self.draft.is_automate_data, let header = self.tableView(tableView, viewForHeaderInSection: section) as? CAExpensesTipsHeaderView  {
            let borderSpaace:CGFloat = 48
            let size = header.textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - borderSpaace, height: CGFloat.greatestFiniteMagnitude))
            return size.height
        }else{
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.draft != nil, section == captureSection, self.draft.is_automate_data {
            return 10
        }
        return 0.01
    }
}
