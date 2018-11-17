//
//  ErrorViewController.swift
//  DemoVisitorApp
//
//  Created by Nitesh Meshram on 07/08/18.
//  Copyright © 2018 V2Solutions. All rights reserved.
//

import Foundation
import UIKit

class ErrorViewController: BaseviewController,UITextFieldDelegate {
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    var errorMessgeText: String?
    
    var format : DateFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.errorLabel.text = errorMessgeText
        
        
        let date = Date()
        format = CheapDateFormatter.formatter()
        self.dateTimeLabel.text = format.string(from: date)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
        
        if let activationDetails = DeviceActivationDetails.checkDataExistOrNot(){
            self.view.backgroundColor = activationDetails.appBackgroundColor()
        }
        
    }
    
    //Update clock every second
    @objc func updateClock() {
        let now = NSDate()
        
        self.dateTimeLabel.text =  format.string(from: now as Date)
    }
}
