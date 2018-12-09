//
//  BaseviewController.swift
//  DemoVisitorApp
//
//  Created by V2Solutions on 16/06/18.
//  Copyright © 2018 V2Solutions. All rights reserved.
//

import Foundation
import UIKit

class BaseviewController: UIViewController {
    
//    @IBOutlet weak var topConstraint: NSLayoutConstraint!
//    var initialOrientation = true
//    var isInPortrait = false
//
    
//    var finalUserData = [String: Any]()
    
    func showValidationAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            let appDelegate  = UIApplication.shared.delegate as? AppDelegate
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}

extension UIView {
    public func turnOffAutoResizing() {
        self.translatesAutoresizingMaskIntoConstraints = false
        for view in self.subviews as [UIView] {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    public func orientationHasChanged(_ isInPortrait:inout Bool) -> Bool {
        if self.frame.width > self.frame.height {
            if isInPortrait {
                isInPortrait = false
                return true
            }
        } else {
            if !isInPortrait {
                isInPortrait = true
                return true
            }
        }
        return false
    }
}

class CheapDateFormatter {
    
    private static let dateFormatter = DateFormatter()
    
    static func formatter() -> DateFormatter {
//        dateFormatter.dateStyle = .medium // reconfiguring is as expensive as recreating
//        dateFormatter.timeStyle = .short  // not good for performance. See comments below.
        
//        like : formatter.dateFormat = "M/dd/yyyy, hh:mm a"
        
//12:15PM, 2 Jan, 2018
        dateFormatter.dateFormat = "hh:mm a, dd MMM, yyyy"
        
        return dateFormatter
    }
    
}


extension DeviceActivationDetails {
    func appFontColor(){
    //-> UIColor {
        let fontColor = self.appuiFontcolor!
        
        let result = fontColor.components(separatedBy: ["(", ")", ","]).filter {!$0.isEmpty}
        
        UILabel.appearance().textColor = UIColor(red: CGFloat(Double(result[0])!/255.0),
                                                 green: CGFloat(Double(result[1])!/255.0),
                                                 blue: CGFloat(Double(result[2])!/255.0),
                                                 alpha: 1.0)
        
//        UILabel.appearance().textColor =  UIColor.black
        
        

    }
    
    func appBackgroundColor() -> UIColor {
        let fontColor = self.appuiBackground!
        let result = fontColor.components(separatedBy: ["(", ")", ","]).filter {!$0.isEmpty}
        
        
        self.appFontColor()
        
        return UIColor(red: CGFloat(Double(result[0])!/255.0),
                       green: CGFloat(Double(result[1])!/255.0),
                       blue: CGFloat(Double(result[2])!/255.0),
                       alpha: 1.0)
//        return UIColor.white
    }
    
}
