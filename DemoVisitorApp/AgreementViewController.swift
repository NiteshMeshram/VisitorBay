//
//  AgreementViewController.swift
//  DemoVisitorApp
//
//  Created by V2Solutions on 17/04/18.
//  Copyright © 2018 V2Solutions. All rights reserved.
//

import Foundation
import SwiftyJSON

import UIKit

class AgreementViewController: BaseviewController, YPSignatureDelegate,UIWebViewDelegate {
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var signatureView: YPDrawSignatureView!
    @IBOutlet weak var webView: UIWebView!
    
    
    var initialOrientation = true
    var isInPortrait = false
    
    var format : DateFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signatureView.delegate = self
        signatureView.backgroundColor = UIColor.clear
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        
        if let deviceInfo = UserDeviceDetails.checkDataExistOrNot() {
            let url = URL (string: "http://dev.visitorbay.com/api/?a=get-agreement&deviceid=\(deviceInfo.deviceUniqueId!)")
            let requestObj = URLRequest(url: url!)
            webView.loadRequest(requestObj)
        }

        // Do any additional setup after loading the view, typically from a nib.
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonClick(_ sender: Any) {
        
        
        if let signatureImage = self.signatureView.getSignature(scale: 10) {
            
            if let imageData = signatureImage.jpeg(.lowest) {
                let signatureBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                
                VisitorsDetailsManager.shared.finalUserData.updateValue(signatureBase64, forKey: "signatureBase64")
            }
//            performSegue(withIdentifier: "profileSegue", sender: nil)

            if let activationDetails = DeviceActivationDetails.checkDataExistOrNot(){
                    if activationDetails.isVisitorphoto {
                        performSegue(withIdentifier: "profileSegue", sender: nil)
                    }
                    else {
//                        performSegue(withIdentifier: "thankyouFromAgreementScreenSegue", sender: nil)
                        saveData()
                    }
            }
            
            
        } else {
            self.showValidationAlert(title: "Error", message: "You must signing this document before continuing")
        }
        
        
        
    }
    
    func saveData() {
        
        var loginDict = [String: Any]()
        
        var deviceID = ""
        if let deviceInfo = UserDeviceDetails.checkDataExistOrNot() {
            deviceID = deviceInfo.deviceUniqueId!
            loginDict = ["a":"save-visitor" ,
                         "deviceid":deviceInfo.deviceUniqueId!,
                         "formdata": VisitorsDetailsManager.shared.finalUserData]
            
        }
        
        DataManager.postUserData(userDetailDict: loginDict, deviceID: deviceID, closure: {Result in
            
            switch Result {
            case .success(let userData):
                
                print(userData)
                
                if userData["response"]["status"].stringValue == VisitorError.resposeCode105.rawValue {
                    self.performSegue(withIdentifier: "thankyouFromAgreementScreenSegue", sender: userData)
                }
                
                break
            case .failure(let errorMessage):
                
                print(errorMessage)
                
                break
            }
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "thankyouFromAgreementScreenSegue" {
            let theDestination = (segue.destination as! ThankyouViewController)
            let jsonData = sender as!  JSON
            theDestination.thankYorResponse = jsonData
        }
    }
    
    
    @IBAction func backButtonClick(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    
}

extension AgreementViewController {
    // Function for clearing the content of signature view
    @IBAction func clearSignature(_ sender: UIButton) {
        // This is how the signature gets cleared
        self.signatureView.clear()
    }
    
    // Function for saving signature
    @IBAction func saveSignature(_ sender: UIButton) {
        // Getting the Signature Image from self.drawSignatureView using the method getSignature().
        if let signatureImage = self.signatureView.getSignature(scale: 10) {
            
            // Saving signatureImage from the line above to the Photo Roll.
            // The first time you do this, the app asks for access to your pictures.
            UIImageWriteToSavedPhotosAlbum(signatureImage, nil, nil, nil)
            
            // Since the Signature is now saved to the Photo Roll, the View can be cleared anyway.
            self.signatureView.clear()
        }
    }
    
    // MARK: - Delegate Methods
    
    // The delegate functions gives feedback to the instanciating class. All functions are optional,
    // meaning you just implement the one you need.
    
    // didStart(_ view: YPDrawSignatureView) is called right after the first touch is registered in the view.
    // For example, this can be used if the view is embedded in a scroll view, temporary
    // stopping it from scrolling while signing.
    func didStart(_ view: YPDrawSignatureView) {
        print("Started Drawing")
    }
    
    // didFinish(_ view: YPDrawSignatureView) is called rigth after the last touch of a gesture is registered in the view.
    // Can be used to enabe scrolling in a scroll view if it has previous been disabled.
    func didFinish(_ view: YPDrawSignatureView) {
        print("Finished Drawing")
    }
}
