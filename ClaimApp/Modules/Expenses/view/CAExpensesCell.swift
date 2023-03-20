//
//  CAExpensesCell.swift
//  dealers
//
//  Created by mac on 2021/9/17.
//  Copyright © 2021 Trusty Cars. All rights reserved.
//

import UIKit

class CAExpensesCell: UITableViewCell , InitializableFromNib {

    static var nibName: String = "CAExpensesCell"
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var statusLabel: PaddingLabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var statusLabelWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var taxLabel: UILabel!
    
    private var shadowView: ShadowView!
    private let kCornerRadius: CGFloat = 8.0
    private var data: LNListData?
    lazy var backView: UIView = {
        let backView = UIView()
        backView.layer.cornerRadius = kCornerRadius
        backView.layer.masksToBounds = true
        return backView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundView = backView
        shadowView = ShadowView()
        shadowView.layer.cornerRadius = kCornerRadius
        shadowView.applyShadow(.lightGray, .zero, 0.3, 12)
        insertSubview(shadowView, belowSubview: backView)
        
        contentView.cornerRadius = kCornerRadius
        cornerRadius = kCornerRadius
        
        if AppDataHelper.languageCode == .indonesian {
            statusLabelWidthConstraint.constant = 108
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        shadowView.frame = bounds
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override var frame: CGRect{

        didSet {
            var newFrame = frame
            newFrame.origin.x += 7
            newFrame.size.width -= 7*2
            newFrame.origin.y += 4
            newFrame.size.height -= 8
            super.frame = newFrame
        }
    }
    
    func config(data: CAExpenseListData) {
        yearLabel.text = data.create_at
        categoryLabel.text = data.vendor.text
        
        var amount: Double = 0
        var currency_code = ""
        for amountItem in data.amountItems {
            currency_code = amountItem.currency_code
            let float = NSString.init(string: amountItem.amount.text.replacingOccurrences(of: AppDataHelper.getSeparator(currency_code), with: "")).doubleValue
            amount += float
        }
        showSameData(url: nil,amount: amount, currencyCode: CurrencyCode.init(rawValue: currency_code))
        
        guard let fileName = data.receiptFile else {
            photoView.image = UIImage(named: "photo-default")
            return
        }
        DispatchQueue.global().async {
            //转换尝试判断，有可能返回的数据丢失"=="，如果丢失，swift校验不通过
            var imageData = Data(base64Encoded: fileName, options: .ignoreUnknownCharacters)
            if imageData == nil {
                imageData = Data(base64Encoded: fileName + "==", options: .ignoreUnknownCharacters) //如果数据不正确，添加"=="重试
            }
            if let imageData = imageData, let image = UIImage(data: imageData) {
                DispatchQueue.main.async { [self] in
                    photoView.image = image
                }
            }else{
                DispatchQueue.main.async { [self] in
                    self.photoView.image = UIImage(named: "photo-default")
                }
            }
        }
    }
    
    func configApiData(data: LNListData) {
        self.data = data
        yearLabel.text = data.created_at
        categoryLabel.text = data.vendor_name
        
        showSameData(url: data.receipt_files?.first?.thumbnail_url ,amount: Double(data.gross_amount ?? "0") ?? 0, currencyCode: data.currencyCode)
        if let file = data.receipt_files?.first, file.mime_type.contains("pdf") {
            photoView.image = UIImage(named: "file_placeholder")
        }
        if data.currencyCode == .SGD {
            taxLabel.text = "(incl. tax)"
        }else if data.currencyCode == .THB {
            taxLabel.text = "(incl. VAT)"
        }
        taxLabel.isHidden = !data.include_tax
    }
    
    private func showSameData(url: String?, amount: Double, currencyCode: CurrencyCode?) {
        
        var resultAmount = ""
        if currencyCode != .IDR {
            resultAmount = String(format: "%.2f", amount)
        } else {
            resultAmount = "\(Int(amount))"
        }
        resultAmount = resultAmount.conversionOfDigital(separator: AppDataHelper.getSeparator(currencyCode?.rawValue), unit: nil)
        
        priceLabel.text = "\(currencyCode?.rawValue ?? CurrencyCode.SGD.rawValue) \(resultAmount)"
        if let amount = self.data?.gross_amount , let currency = currencyCode?.rawValue {
            priceLabel.text = "\(currency) \(amount)"
        }
        if let url = URL(string: url ?? "") {
            photoView.af_setImage(withURL: url,  placeholderImage: UIImage(named: "photo-default"))
        } else {
            photoView.image = UIImage(named: "photo-default")
        }
        
        if AppDataHelper.languageCode == .thai {
            statusLabel.font = .customFont(ofSize: 11)
            statusLabel.textInsets = UIEdgeInsets(top: 2.5, left: 0, bottom: 0, right: 0)
        }
        
        let titleAndColor = self.data?.submitTitleAndTitleBackgroundColor()
        statusLabel.text = titleAndColor?.0
        statusLabel.backgroundColor = titleAndColor?.1
    }
    
}
