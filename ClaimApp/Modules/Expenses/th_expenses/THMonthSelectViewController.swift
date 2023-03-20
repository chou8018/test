//
//  THMonthSelectViewController.swift
//  dealers
//
//  Created by chenjun on 2022/7/5.
//  Copyright © 2022 Trusty Cars. All rights reserved.
//

import UIKit

enum THMonthTag: Int {
    case JAN = 101
    case FEB
    case MAR
    case APR
    case MAY
    case JUN
    case JUL
    case AUG
    case SEP
    case OCT
    case NOV
    case DEC
}

enum THMonthString: String {
    case JAN = "January"
    case FEB = "February"
    case MAR = "March"
    case APR = "April"
    case MAY = "May"
    case JUN = "June"
    case JUL = "July"
    case AUG = "August"
    case SEP = "September"
    case OCT = "October"
    case NOV = "November"
    case DEC = "December"
}

class THMonthSelectViewController: UIViewController {
    
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var leftYearButton: UIButton!
    @IBOutlet weak var rightYearButton: UIButton!
    
    var currentMonthTag: THMonthTag = .JAN
    var mCurrentYear = 2023
    var mCurrentMonth: THMonthString = .JAN
    
    var currentDate: Date!
    private var target: Target?
    
    init(target:Target, currentDate: Date = Date()) {
        super.init(nibName: nil, bundle: nil)
        self.target = target
        self.currentDate = currentDate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let currentMonth = dateFormatter.string(from: currentDate)
        dateFormatter.dateFormat = "yyyy"
        let showYear = dateFormatter.string(from: currentDate)
        yearLabel.text = showYear
        
        let currentYear = dateFormatter.string(from: Date())
        mCurrentYear = Int(currentYear) ?? 2023
        
        if let intYear = Int(showYear) {
            if intYear >= mCurrentYear {
                rightYearButton.setImage(UIImage.init(named: "icon_year_right_disable"), for: .normal)
            }else{
                rightYearButton.setImage(UIImage.init(named: "icon_year_right"), for: .normal)
            }
            if intYear <= mCurrentYear - 20 {
                leftYearButton.setImage(UIImage.init(named: "icon_year_left_disable"), for: .normal)
            }else{
                leftYearButton.setImage(UIImage.init(named: "icon_year_left"), for: .normal)
            }
        }
        
        switch currentMonth {
        case "01":
            currentMonthTag = .JAN
            mCurrentMonth = .JAN
        case "02":
            currentMonthTag = .FEB
            mCurrentMonth = .FEB
        case "03":
            currentMonthTag = .MAR
            mCurrentMonth = .MAR
        case "04":
            currentMonthTag = .APR
            mCurrentMonth = .APR
        case "05":
            currentMonthTag = .MAY
            mCurrentMonth = .MAY
        case "06":
            currentMonthTag = .JUN
            mCurrentMonth = .JUN
        case "07":
            currentMonthTag = .JUL
            mCurrentMonth = .JUL
        case "08":
            currentMonthTag = .AUG
            mCurrentMonth = .AUG
        case "09":
            currentMonthTag = .SEP
            mCurrentMonth = .SEP
        case "10":
            currentMonthTag = .OCT
            mCurrentMonth = .OCT
        case "11":
            currentMonthTag = .NOV
            mCurrentMonth = .NOV
        case "12":
            currentMonthTag = .DEC
            mCurrentMonth = .DEC
        default:
            break
        }
        
        let b = view.viewWithTag(currentMonthTag.rawValue) as! UIButton
        monthButtonSelected(b)
    }
    
    @IBAction func dismissVC(_ sender: UIButton) {
        
        let year = yearLabel.text ?? "2023"
        let month = mCurrentMonth.rawValue
        self.target?.perform(object: "\(month) \(year)")
        
        self.dismiss(animated: false)
        
//        UIView.animate(withDuration: 0.25, animations: {
//            self.view.layoutIfNeeded()
//            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
//        }) { (flag) in
//            self.dismiss(animated:false, completion: nil)
//        }

//        UIView.animate(withDuration: 0.25, animations: {
//            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        }) { _ in
//
//            UIView.animate(withDuration: 0.25) {
//                self.view.backgroundColor = UIColor.black.withAlphaComponent(1)
//                self.dismiss(animated: false)
//            }
//        }
    }
    
    @IBAction func monthButtonSelected(_ sender: UIButton) {
        let year = Int(yearLabel.text ?? "2023")

//        if sender.tag > currentMonthTag.rawValue ,year == mCurrentYear {
//            return
//        }
        
        for i in THMonthTag.JAN.rawValue...THMonthTag.DEC.rawValue {
            let b = view.viewWithTag(i) as! UIButton
            b.backgroundColor = UIColor.init(hexValue: 0xF4F6F8)
            b.setTitleColor(.titleGrayColor, for: .normal)
        }
        
        sender.backgroundColor = .cBlue
        sender.setTitleColor(.white, for: .normal)
        
        switch sender.tag {
        case THMonthTag.JAN.rawValue:
            mCurrentMonth = .JAN
        case THMonthTag.FEB.rawValue:
            mCurrentMonth = .FEB
        case THMonthTag.MAR.rawValue:
            mCurrentMonth = .MAR
        case THMonthTag.APR.rawValue:
            mCurrentMonth = .APR
        case THMonthTag.MAY.rawValue:
            mCurrentMonth = .MAY
        case THMonthTag.JUN.rawValue:
            mCurrentMonth = .JUN
        case THMonthTag.JUL.rawValue:
            mCurrentMonth = .JUL
        case THMonthTag.AUG.rawValue:
            mCurrentMonth = .AUG
        case THMonthTag.SEP.rawValue:
            mCurrentMonth = .SEP
        case THMonthTag.OCT.rawValue:
            mCurrentMonth = .OCT
        case THMonthTag.NOV.rawValue:
            mCurrentMonth = .NOV
        case THMonthTag.DEC.rawValue:
            mCurrentMonth = .DEC
        default:
            break
        }
    }
    
    
    @IBAction func leftYearButtonClicked(_ sender: UIButton) {
        var intYear = Int(yearLabel.text ?? "2023")
        intYear! -= 1
        if intYear! <= mCurrentYear - 20 {
            yearLabel.text = "\(mCurrentYear-20)"
            leftYearButton.setImage(UIImage.init(named: "icon_year_left_disable"), for: .normal)
            return
        }
        yearLabel.text = "\(intYear ?? 2023)"
        
        if intYear! < mCurrentYear {
            rightYearButton.setImage(UIImage.init(named: "icon_year_right"), for: .normal)
        }
  
    }
    
    @IBAction func rightYearButtonClicked(_ sender: UIButton) {
        var intYear = Int(yearLabel.text ?? "2023")
        intYear! += 1
        if intYear! >= mCurrentYear {
            yearLabel.text = "\(mCurrentYear)"
            rightYearButton.setImage(UIImage.init(named: "icon_year_right_disable"), for: .normal)
            return
        }
        yearLabel.text = "\(intYear ?? 2023)"
        
        if intYear! > mCurrentYear - 20 {
            leftYearButton.setImage(UIImage.init(named: "icon_year_left"), for: .normal)
        }
    }
}
