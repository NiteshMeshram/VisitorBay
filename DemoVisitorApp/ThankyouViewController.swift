//
//  ThankyouViewController.swift
//  DemoVisitorApp
//
//  Created by V2Solutions on 17/04/18.
//  Copyright © 2018 V2Solutions. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import Kingfisher

class ThankyouViewController: BaseviewController {
    
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var companyLogo: UIImageView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    var thankYorResponse: JSON?
    
    var initialOrientation = true
    var isInPortrait = false
    
    var format : DateFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
//        let multiLineString = """
//                  Thank You Tty
//
//                  We will let you know soon
//                  """
//
//        self.messageLabel.text = multiLineString
        
        
        if thankYorResponse != nil {
            var message = """
            \(thankYorResponse!["thankyoumsg"]["line1"])
            
            \(thankYorResponse!["thankyoumsg"]["line2"])
            """
            self.messageLabel.text = message
        }
        
        if let activationDetails = DeviceActivationDetails.checkDataExistOrNot(){
            /*
            if activationDetails.logoURL != "" {
                let url = URL(string: activationDetails.logoURL!)
                ImageCache.default.removeImage(forKey: "logoKey")
                let resource = ImageResource(downloadURL: url!, cacheKey: "logoKey")
                companyLogo.kf.setImage(with: resource)
            }else {
                ImageCache.default.removeImage(forKey: "logoKey")
                companyLogo.image = nil
            }
            */
            
            self.setLogoImage()
            
            self.view.backgroundColor = activationDetails.appBackgroundColor()
            
        }
        
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // change 2 to desired number of seconds
            // Your code with delay
            
            if UserDefaults.standard.hasValue(forKey: "fromThankyouPage") {
                
            }
            else {
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "fromThankyouPage")
                defaults.synchronize()
            }
            
            self.navigationController?.popToRootViewController(animated: true)
            
            
        }
        
        let date = Date()
        format = CheapDateFormatter.formatter()
        self.dateTimeLabel.text = format.string(from: date)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
        
        
    }
    
    func setLogoImage() {
        if let activationDetails = DeviceActivationDetails.checkDataExistOrNot(){
            let url = URL(string: activationDetails.logoURL!)
            companyLogo.kf.setImage(with: url,
                                    placeholder: nil,
                                    options: [.transition(ImageTransition.fade(1))],
                                    progressBlock: { receivedSize, totalSize in
                                        //                                        print("\(indexPath.row + 1): \(receivedSize)/\(totalSize)")
            },
                                    completionHandler: { image, error, cacheType, imageURL in
                                        
                                        //                                        print("\(indexPath.row + 1): Finished")
                                        print(image?.size)
                                        
                                        self.logoHeightConstraint.constant = (image?.size.height)!
                                        self.logoWidthConstraint.constant = (image?.size.width)!
                                        //                                        self.companyLogo.image = image
                                        //                                        cell.imageView?.image = self.resizeImage(image: image!, newWidth: 40.0)
                                        
            })
        }
        
    }
    
    //Update clock every second
    @objc func updateClock() {
        let now = NSDate()
        
        self.dateTimeLabel.text =  format.string(from: now as Date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonClick(_ sender: Any) {
        
        //        performSegue(withIdentifier: "chekInChecOutSegue", sender: nil)
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        
//        navigationController?.popViewController(animated: true)
    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        if initialOrientation {
//            initialOrientation = false
//            if view.frame.width > view.frame.height {
//                isInPortrait = false
//                self.topConstraint.constant = 143.00
//            } else {
//                isInPortrait = true
//                self.topConstraint.constant = 00.00
//            }
//        } else {
//            if view.orientationHasChanged(&isInPortrait) {
//
//                if isInPortrait{
//                    self.topConstraint.constant = 143.00
//                }
//                else {
//                    self.topConstraint.constant = 00.00
//                }
//            }
//        }
//    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    
    
}
