//
//  UIViewController+Carro.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 17/9/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func makeNavigationBarTransparent() {

        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = UIColor.clear
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
    }
    
    func restoreNavigationBar() {

        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.backgroundColor = UINavigationBar.appearance().backgroundColor
        self.navigationController?.navigationBar.tintColor = UINavigationBar.appearance().tintColor
        self.navigationController?.navigationBar.titleTextAttributes = UINavigationBar.appearance().titleTextAttributes
        
    }
    
    func updateTitleFont() {
        let dict:NSDictionary = [NSAttributedString.Key.foregroundColor: UIColor.white,NSAttributedString.Key.font : UIFont.extraLargeMedium]
        self.navigationController?.navigationBar.titleTextAttributes = dict as? [NSAttributedString.Key : AnyObject]
    }
    
    func isPreviousViewControllerInstanceOf<T: UIViewController>(_ viewControllerType: T.Type) -> Bool {
        guard
            let vcs = self.navigationController?.viewControllers,
            vcs.count >= 2,
            vcs[vcs.count - 1] == self,
            vcs[vcs.count - 2] is T else {
                return false
        }
        return true
    }
    
    func showSearchBarButtonItem(action: Selector) {
     
        let searchButton = UIButton()
        
        var image = #imageLiteral(resourceName: "ic_home_search")
        image = image.withRenderingMode(.alwaysTemplate)
        
        searchButton.setImage(image, for: .normal)
        searchButton.imageView?.tintColor = UIColor.white
        
        searchButton.addTarget(self, action: action, for: .touchUpInside)
        
        searchButton.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        
        let searchBarButton = UIBarButtonItem(customView: searchButton)
        
        self.navigationItem.rightBarButtonItem = searchBarButton
        
    }
    
    func addEmptyStateViewInView(_ view: UIView, frame: CGRect) -> EmptyStateView {
        guard let emptyStateView =
            Bundle.main.loadNibNamed("EmptyStateView", owner: nil, options: nil)?.last as? EmptyStateView else { fatalError() }
        
        emptyStateView.frame = frame
        view.addSubview(emptyStateView)
        
        return emptyStateView
    }
 
    
    func useUntitledBackButton(target: Any? = nil, selector: Selector = #selector(UINavigationController.popViewControllerWithAnimation)) {
        let leftBarButtonItem =
            UIBarButtonItem(image: #imageLiteral(resourceName: "icon_arrow_back"), style: .plain, target: target ?? self.navigationController, action:selector)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func useUntitledNewBackButton(target: Any? = nil, selector: Selector = #selector(UINavigationController.popViewControllerWithAnimation)) {
        let leftBarButtonItem =
            UIBarButtonItem(image: UIImage(named: "ic_back"), style: .plain, target: target ?? self.navigationController, action:selector)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func addVersionLabel() {
        
        let versionLabel = UILabel(frame: .zero)
        view.addSubview(versionLabel)
        view.bringSubviewToFront(versionLabel)
        
        versionLabel.font = UIFont.small
        versionLabel.textColor = UIColor.cDarkText
        
        versionLabel.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).offset(-10)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
                
            } else {
                make.trailing.bottom.equalTo(self.view)
            }
        }
        
        versionLabel.text = UIApplication.shared.versionString

    }
    
    func addTopGradientView() -> UIView {
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: AppConfig.kScreenWidth, height: 6))
        view.addSubview(topView)
        view.bringSubviewToFront(topView)
//        topView.backgroundColor = UIColor.init(hexValue: 0xA0EFE4)
//        topView.addMYNavbarGradientWithRadius(radius: 0)
        
        let imageView = UIImageView(frame: topView.bounds)
        imageView.image = UIImage(named: "my_navibar_shape")
        imageView.contentMode = .scaleToFill
        topView.addSubview(imageView)
        
        return topView
    }
    
    func makeBarButtonItem(image: UIImage, target: AnyObject?, action: Selector) -> UIBarButtonItem {
        
        let button = UIButton()
        button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = UIColor.white
        button.imageView?.clipsToBounds = true
        button.addTarget(target, action: action, for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        
        return UIBarButtonItem(customView: button)
    }
    
}

fileprivate extension UINavigationController {
    
    @objc func popViewControllerWithAnimation() {
        self.popViewController(animated: true)
    }

}


