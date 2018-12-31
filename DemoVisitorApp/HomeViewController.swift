//
//  HomeViewController.swift
//  DemoVisitorApp
//
//  Created by Nitesh Meshram on 3/5/18.
//  Copyright © 2018 V2Solutions. All rights reserved.
//

import UIKit
import Kingfisher

class HomeViewController: BaseviewController,UITextFieldDelegate {

    var initialOrientation = true
    var isInPortrait = false
    
    var activationCode : String = ""
    var userDeviceId: String?
    

    var format : DateFormatter!
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var topLine1Label: UILabel!
    @IBOutlet weak var topLine2Label: UILabel!
    @IBOutlet weak var activationCodeText: UITextField!
    
    var userActivation: UserDeviceDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.activationCodeText.text = self.userActivation?.activation_code
        
        self.topLine1Label.text = self.userActivation?.topline1text
        self.topLine2Label.text = self.userActivation?.topline2text
        
        

        let date = Date()
        format = CheapDateFormatter.formatter()
        self.dateTimeLabel.text = format.string(from: date)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
        
       
        print("1st")
        
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        
        
    }
    
    //Update clock every second
    @objc func updateClock() {
        let now = NSDate()
        self.dateTimeLabel.text =  format.string(from: now as Date)
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.navigationController!.viewControllers.removeAll()

         print("3st")
    }

//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//         print("2st")
//    }

    @IBAction func nextButtonClick(_ sender: Any) {
        
    }
    
    @IBAction func activateNowClicked(_ sender: Any) {
        self.activationAPICall()

//        self.performSegue(withIdentifier: "mainFlowSegue", sender: nil)
    }
    

    override func viewWillLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
         print("4st")

        
    }
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("landscape")
        } else {
            print("portrait")
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
    
//    override func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        return false
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mainFlowSegue" {

        }
    }
    
    
    func activationAPICall() {
        var loginDict = [String: Any]()
        
        if let deviceInfo = UserDeviceDetails.checkDataExistOrNot() {
            loginDict = ["a":"activate-device" ,
                         "deviceid":deviceInfo.deviceUniqueId!,
                         "acode": deviceInfo.activation_code!]
        }
        
        

        DataManager.activationWithKey(userDetailDict: loginDict, closure: {Result in
            
            switch Result {
            case .success(let activationDetails):
//                self.performSegue(withIdentifier: "mainFlowSegue", sender: nil)
                
                if activationDetails.hasError == VisitorError.success.rawValue{
//                    errorCode
                    if activationDetails.errorCode == "105" {
                        self.performSegue(withIdentifier: "mainFlowSegue", sender: nil)
                    }
                    
                }
                else {
                    
                    if activationDetails.errorCode == "203" {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        let initialViewController = storyboard.instantiateViewController(withIdentifier: "errorScreen") as! ErrorViewController
                        
                        if let errorMsg = activationDetails.errorMessage {
                            initialViewController.errorMessgeText = errorMsg
                        }
                        self.present(initialViewController, animated: true, completion: nil)
                    }
                    else {
                        self.showValidationAlert(title: activationDetails.errorHeading!, message: activationDetails.errorMessage!)
                    }
                    
                    
                    
                }
                

                
                break
            case .failure(let errorMessage):
                print(errorMessage)
                
                break
            }
        })
        
    }
    
}
extension UITextField {
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
