//
//  DeactivateConfirmViewController.swift
//  dealers
//
//  Created by 付耀辉 on 2022/6/13.
//  Copyright © 2022 Trusty Cars. All rights reserved.
//

import UIKit

class DeactivateConfirmViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var confirm: UIButton!
    @IBOutlet weak var close: UIButton!

    private var target: Target?
    
    init(target:Target) {
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
        self.target = target
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        cancelButton.setTitleColor(.white, for: .normal)
        titleLabel.text = String.localized("all_deactivate_pop_account_title", comment: "")
        contentLabel.text = String.localized("all_deactivate_pop_account_content", comment: "")
        cancelButton.setTitle(String.localized("all_deactivate_account_pop_cacel", comment: ""), for: .normal)
        confirm.setTitle(String.localized("all_deactivate_account_pop_confirm", comment: ""), for: .normal)
        
        
//        setViewBackground(cancel)
        cancelButton.cornerRadius = 6

        confirm.cornerRadius = 6
        confirm.borderColor = .init(hexValue: 0x7A7A4A)
        confirm.borderWidth = 1
        confirm.setTitleColor(.init(hexValue: 0x7A7A4A), for: .normal)
        close.isHidden = true
        cancelButton.cornerRadius = 6
        
        cancelButton.backgroundColor = .cPrimary
    }

    
    @IBAction func buttonAction(_ sender: UIButton) {
        
        if sender.tag == 101 {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.target?.perform(object: "")
            }
        }
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
}

public extension UIImage {
    
    static func gradientImage(_ height: NSInteger,fromColor:UIColor,toColor:UIColor) -> UIImage {
        
        let view = UIView(frame: CGRect(x:0, y:0, width:Int(1000), height:height))
        view.layer.insertSublayer(getNavigationView(height, fromColor: fromColor, toColor: toColor), at: 0)
        UIGraphicsBeginImageContext(view.bounds.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }


    
    
    //MARK: 获得渐变背景颜色
    static func getNavigationView(_ height: NSInteger,fromColor:UIColor,toColor:UIColor) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x:0, y:0, width:Int(1000), height:height)
        gradient.colors = [fromColor.cgColor,toColor.cgColor]
        gradient.startPoint = CGPoint.init(x: 0, y: 0.5)
        gradient.endPoint = CGPoint.init(x: 1, y: 0.5)
        return gradient
        
    }
}


 func setViewBackground(_ gradientView: UIView) {
        //创建渐变图层
        let gradientLayer = CAGradientLayer()
        //设置渐变层的位置和尺寸，与视图对象保持一致
        gradientLayer.frame = gradientView.frame
        //设置渐变起始颜色
        let fromColor = UIColor.yellow.cgColor
        //设置渐变中间颜色
        let midColor = UIColor.red.cgColor
        //设置渐变的结束颜色
        let toColor = UIColor.gray.cgColor
        
        //设置渐变层颜色数组属性
        gradientLayer.colors = [fromColor,midColor,toColor]
        
        //将配好的渐变层，添加到视图对象的层中
        gradientView.layer.addSublayer(gradientLayer)
        
    }
