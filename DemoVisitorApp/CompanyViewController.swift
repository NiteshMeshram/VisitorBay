//
//  CompanyViewController.swift
//  DemoVisitorApp
//
//  Created by V2Solutions on 18/03/18.
//  Copyright © 2018 V2Solutions. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class CompanyViewController: BaseviewController {
    
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    var initialOrientation = true
    var isInPortrait = false
    
    var format : DateFormatter!

    @IBOutlet weak var companyLogo: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var comingFrom: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        

       
        
        if UserDefaults.standard.hasValue(forKey: "loggedInUser") {

        }
        else {
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "loggedInUser")
            defaults.synchronize()
        }
        
        


        let date = Date()
        format = CheapDateFormatter.formatter()
        self.dateTimeLabel.text = format.string(from: date)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
        
        
        


        
        if let activationDetails = DeviceActivationDetails.checkDataExistOrNot(){
            
//            self.setLogoImage()
            
            if activationDetails.logoURL != "" {
                let url = URL(string: activationDetails.logoURL!)
                ImageCache.default.removeImage(forKey: "logoKey")
                let resource = ImageResource(downloadURL: url!, cacheKey: "logoKey")
                companyLogo.kf.setImage(with: resource)
            }else {
                ImageCache.default.removeImage(forKey: "logoKey")
                companyLogo.image = nil
            }
            

            self.view.backgroundColor = activationDetails.appBackgroundColor()
            
            self.welcomeLabel.text = activationDetails.welcometxt
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        comingFrom = ""
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
        
//        performSegue(withIdentifier: "purposeSegue", sender: nil)
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
//        _ = navigationController?.popToRootViewController(animated: true)
        navigationController?.popViewController(animated: true)
    }
    @IBAction func checkInButtonClicked(_ sender: Any) {
        comingFrom = "checkIn"
        performSegue(withIdentifier: "purposeSegue", sender: nil)
    }
    @IBAction func checkOutButtonClicked(_ sender: Any) {
        comingFrom = "checkOut"
        performSegue(withIdentifier: "userSearchSegue", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "purposeSegue"{
            
        }
        if segue.identifier == "userSearchSegue"{
            let theDestination = (segue.destination as! SearchViewController)
            theDestination.comingFrom = comingFrom
        }
    }
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    
    
    
    //In your view controller
    @IBAction func printButton(sender: AnyObject) {
        /*
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "My Print Job"
        
        // Set up print controller
        let printController1 = UIPrintInteractionController.shared
        printController1.printInfo = printInfo
        
        // Assign a UIImage version of my UIView as a printing iten
        printController1.printingItem = self.view.toImage()
        
        // If you want to specify a printer
//        guard let printerURL = URL(string: "Your printer URL here, e.g. ipps://HPDC4A3E0DE24A.local.:443/ipp/print") else { return }
//        guard let currentPrinter = UIPrinter(url: printerURL) else { return }
        
//        printController.print(to: currentPrinter, completionHandler: nil)
        
        // Do it
        printController1.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)
        */
        
        var pInfo : UIPrintInfo = UIPrintInfo.printInfo()
        pInfo.outputType = UIPrintInfoOutputType.general
        pInfo.jobName = "Test Job Name"
        pInfo.orientation = UIPrintInfoOrientation.portrait
        
        
        var printController = UIPrintInteractionController.shared
        printController.printInfo = pInfo
        printController.printingItem = self.view.toImage()
//        printController.showsPageRange = true
//        printController.printFormatter =
        
        // If you want to specify a printer
        let printerURL = URL(string: "192.168.1.4")
        let currentPrinter = UIPrinter(url: printerURL!)
        
        printController.print(to: currentPrinter, completionHandler: nil)
        
//        printController.present(animated: true, completionHandler: nil)
        
    }
}


//create an extension to covert the view to an image
extension UIView {
    func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


