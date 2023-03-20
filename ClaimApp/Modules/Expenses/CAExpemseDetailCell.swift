//
//  CAExpemseDetailCell.swift
//  ClaimApp
//
//  Created by 付耀辉 on 2022/10/11.
//

import UIKit

class CAExpemseDetailCell: UITableViewCell {
    
    @IBOutlet weak var submitMark: PaddingLabel!
    @IBOutlet weak var mainView: UIView!
    
    
    private let tableIdentifierCell = "tableIdentifierCell"
    private let tableAmountIdentifierCell = "tableAmountIdentifierCell"
    private let tableAmountFootIdentifierCell = "tableAmountFootIdentifierCell"
    private let tableCaptureHeaderIdentifierCell = "tableCaptureHeaderIdentifierCell"
    private let tableCapturePhotoIdentifierCell = "tableCapturePhotoIdentifierCell"
    
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
        mainTableView.register(UINib.init(nibName: "CANewExpensesAmountCell", bundle: nil), forCellReuseIdentifier: tableAmountIdentifierCell)
        mainTableView.register(UINib.init(nibName: "CAExpensesTipsHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: tableCaptureHeaderIdentifierCell)
        mainTableView.register(UINib.init(nibName: "CAExpensesCaptureCell", bundle: nil), forCellReuseIdentifier: tableCapturePhotoIdentifierCell)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        //        UITableView.appearance().estimatedRowHeight = 0
        //        UITableView.appearance().estimatedSectionFooterHeight = 0
        //        UITableView.appearance().estimatedSectionHeaderHeight = 0
        //
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
        
        var rowHeight:CGFloat = 69*5 + 16
        
        if expensesType == .personal {
            rowHeight = 69*3 + 16
        }
        
        if let fieldData = datas[2].first as? PhotoFormFieldData, fieldData.images.count > 0 {
            rowHeight += 160
        }else{
            rowHeight += 12
        }
        
        for data in datas[1] {
            guard let data = data as? ItemsFormFieldData else { return }
            let itemCellHeight: CGFloat = expensesType == .personal ? 0 : (data.items.count > 4 ? 46 : -46)
            if let _ = data.status, data.items.last?.text?.isEmpty ?? true {
                
                rowHeight = rowHeight + CANewExpensesAmountCell.baseRowHeight + itemCellHeight - 35
            }else{
                
                let descrip = GrowingTextView()
                descrip.text = data.items.last?.text
                descrip.font = .systemFont(ofSize: 15)
                let borderSpaace:CGFloat = 32 + 45
                let size = descrip.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - borderSpaace, height: CGFloat.greatestFiniteMagnitude))
                
                let descripBaseHeight:CGFloat = 32
                
                rowHeight = rowHeight + CANewExpensesAmountCell.baseRowHeight + itemCellHeight - descripBaseHeight + size.height
            }
        }
        
        if self.draft.is_automate_data, let header = self.tableView(self.mainTableView, viewForHeaderInSection: captureSection) as? CAExpensesTipsHeaderView  {
            let borderSpaace:CGFloat = 48
            let size = header.textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - borderSpaace, height: CGFloat.greatestFiniteMagnitude))
            rowHeight = rowHeight + size.height + 16
        }
        
        draft.rowHeight = rowHeight + 76 + 32 + 10
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}



extension CAExpemseDetailCell: UITableViewDataSource {
    
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
            let cell = tableView.dequeueReusableCell(withIdentifier: tableAmountIdentifierCell) as! CANewExpensesAmountCell
            cell.bind(data: itemData)
            cell.removeButton.isHidden = indexPath.row <= 0
            cell.removeButton.tag = indexPath.row+100
            cell.removeButton.isHidden = true
            cell.selectButton.isHidden = true
            cell.select1Button.isHidden = true
            cell.select2Button.isHidden = true
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: tableIdentifierCell, for: indexPath) as! CANewExpensesNormalCell
            cell.selectionStyle = .none
            cell.bind(data: fieldData)
            cell.isUserInteractionEnabled = false
            cell.iconButton.isHidden = true
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
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

extension CAExpemseDetailCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == amountSection {
            if let data = datas[amountSection][indexPath.row] as? ItemsFormFieldData {
                return data.rowHeight - (data.isPersonal ? 36+10 : 0)
            }
        } else if indexPath.section == captureSection {
            
            if let formData = datas[2].first as? PhotoFormFieldData, formData.images.count > 0 {
                return 160 + 16
            }
            return 0
        }
        return 69
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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

extension String {
    ///根据宽度跟字体，计算文字的高度
    func textAutoHeight(width:CGFloat, font:UIFont) ->CGFloat{
        let string = self as NSString
        let origin = NSStringDrawingOptions.usesLineFragmentOrigin
        let lead = NSStringDrawingOptions.usesFontLeading
        let ssss = NSStringDrawingOptions.usesDeviceMetrics
        let rect = string.boundingRect(with:CGSize(width: width, height:0), options: [origin,lead,ssss], attributes: [NSAttributedString.Key.font:font], context:nil)
        return rect.height
    }
}
