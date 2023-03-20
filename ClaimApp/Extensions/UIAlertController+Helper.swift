//
//  UIAlertController+Helper.swift
//  CarroRabbitMobile
//
//  Created by Hong Wei Zhuo on 27/8/17.
//  Copyright © 2017 Trusty Cars. All rights reserved.
//

import Foundation
import UIKit

typealias AlertActionHandler = (UIAlertAction) -> ()

extension UIAlertController {
    
    class func showMessage(title: String?, message: String?, buttonTitle: String = "OK", from presentingViewController: UIViewController, completion: (()->Void)? = nil ) {
    
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(
            UIAlertAction(title: buttonTitle, style: .cancel) { _ in
                completion?()
            }
        )
        
        presentingViewController.present(ac, animated: true, completion: nil)
    
    }
    
    class func showMessage(
        title: String?,
        message: String?,
        leftButton: (title: String, handler: AlertActionHandler?)?,
        rightButton: (title: String, handler: AlertActionHandler?)?,
        presentingViewController: UIViewController) -> UIAlertController {
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let leftButton = leftButton {
            ac.addAction(UIAlertAction(title: leftButton.title, style: .default, handler: leftButton.handler))
        }
        
        if let rightButton = rightButton {
            ac.addAction(UIAlertAction(title: rightButton.title, style: .default, handler: rightButton.handler))
        }
        
        presentingViewController.present(ac, animated: true, completion: nil)
        
        return ac
        
    }
    
    class func showMessage(title: String?, message: String?) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
        
    class func showRequestCameraAccessMessage(
        _ presentationController: UIViewController,
        noActionHandler: AlertActionHandler? = nil,
        yesActionHandler: AlertActionHandler? = nil) -> UIAlertController {
        
        var effectiveYesActionHandler: AlertActionHandler? = yesActionHandler
        
        if effectiveYesActionHandler == nil {
            effectiveYesActionHandler = { _ in
                presentationController.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
        
        return UIAlertController.showMessage(
            title: "Allow \(UIApplication.shared.appName) to access the camera?",
            message: "\(UIApplication.shared.appName) would like to access the camera.",
            leftButton: (title: "Don't Allow", handler: noActionHandler),
            rightButton: (title: "OK", handler: effectiveYesActionHandler),
            presentingViewController: presentationController)
        
    }
    
    class func showErrorMessage(error: Error, from presentingVC: UIViewController, completion: (()->Void)? = nil) {
        switch error {
        case ApiError.noConnection:
            showNoConnectionErrorMessage(from: presentingVC, completion: completion)
        case ApiError.unreachable:
            showUnreachableErrorMessage(from: presentingVC, completion: completion)
        case ApiError.generalError(let message):
            let title = "Oops.."
            UIAlertController.showMessage(title: title, message: message, from: presentingVC, completion: completion)
        case ApiError.formError(let message, _):
            let title = "Oops..."
            UIAlertController.showMessage(title: title, message: message, from: presentingVC, completion: completion)
        
        case ApiError.unauthorized:
            break
//            let title = "Oops..."
//            let message = "Your login has expired."
//            UIAlertController.showMessage(title: title, message: message, from: presentingVC, completion: completion)
            
        default:
            showDefaultErrorMessage(from: presentingVC, completion: completion)
        }
    }
    
    class func showNoConnectionErrorMessage(from presentingVC: UIViewController, completion: (()->Void)? = nil) {
        
        
        let title = "No internet connection"
        let message = "Please check your internet connection and try again"
        
        UIAlertController.showMessage(title: title, message: message, from: presentingVC, completion: completion)
        
    }
    
    class func showUnreachableErrorMessage(from presentingVC: UIViewController, completion: (()->Void)? = nil) {
        
        let title = "Could not access server"
        let message = "We could not access the server. Please try again"
        UIAlertController.showMessage(title: title, message: message, from: presentingVC, completion: completion)
    
    }
    
    class func showDefaultErrorMessage(from presentingVC: UIViewController, completion: (()->Void)? = nil) {
        
        let title = "Oops..."
        let message = "Something went wrong. We're working on getting it fixed as soon as we can."
        UIAlertController.showMessage(title: title, message: message, from: presentingVC, completion: completion)
    }
}


