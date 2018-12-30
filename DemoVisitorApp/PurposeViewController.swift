//
//  PurposeViewController.swift
//  DemoVisitorApp
//
//  Created by V2Solutions on 18/03/18.
//  Copyright © 2018 V2Solutions. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import Kingfisher

class PurposeViewController: BaseviewController {
    
    var initialOrientation = true
    var isInPortrait = false
    
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var companyLogo: UIImageView!
    var format : DateFormatter!
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let date = Date()
        format = CheapDateFormatter.formatter()
        self.dateTimeLabel.text = format.string(from: date)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
        
        if let activationDetails = DeviceActivationDetails.checkDataExistOrNot(){
            self.setLogoImage()
            /*
            if activationDetails.logoURL != "" {
                let url = URL(string: activationDetails.logoURL!)
                ImageCache.default.removeImage(forKey: "logoKey")
                let resource = ImageResource(downloadURL: url!, cacheKey: "logoKey")
                companyLogo.kf.setImage(with: resource)
            }else {
                ImageCache.default.removeImage(forKey: "logoKey")
                companyLogo.image = nil
            }*/
            
            self.view.backgroundColor = activationDetails.appBackgroundColor()
        }
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
        
//        performSegue(withIdentifier: "userSegue", sender: nil)
    }
    
    @IBAction func backButtonClick(_ sender: Any) {

        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func selectedPurpose(_ sender: UIButton) {
//        print(sender.tag)
        
        if sender.tag == 0 {
            VisitorsDetailsManager.shared.finalUserData.updateValue("Meeting", forKey: "purpose")
        }
        if sender.tag == 1 {
            VisitorsDetailsManager.shared.finalUserData.updateValue("Interview", forKey: "purpose")
        }
        if sender.tag == 2 {
             VisitorsDetailsManager.shared.finalUserData.updateValue("Vendor", forKey: "purpose")
        }
        if sender.tag == 3 {
             VisitorsDetailsManager.shared.finalUserData.updateValue("Personal Visit", forKey: "purpose")
        }
        
        var loginDict = [String: Any]()
        //        http://dev.visitorbay.com/api/?a=render-form&deviceid=<deviceid>
        if let deviceInfo = UserDeviceDetails.checkDataExistOrNot() {
            loginDict = ["a":"render-form" ,
                         "deviceid":deviceInfo.deviceUniqueId!]
        }
        
        DataManager.userFormAPI(userDetailDict: loginDict, closure: {Result in
            
            switch Result {
            case .success(let jsonData):
                if jsonData["response"]["status"].stringValue == VisitorError.resposeCode105.rawValue {
                    self.performSegue(withIdentifier: "userSegue", sender: jsonData)
                }
                
                break
            case .failure(let errorMessage):
                print(errorMessage)
                break
                
            }
        })
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "userSegue") {
            let userController = segue.destination as! UserViewController
            let jsonData = sender as!  JSON
            userController.formData = jsonData
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
}
