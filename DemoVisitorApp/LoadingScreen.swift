
//
//  LoadingScreen.swift
//  DemoVisitorApp
//
//  Created by Nitesh Meshram on 05/09/18.
//  Copyright © 2018 V2Solutions. All rights reserved.
//

import Foundation
import UIKit

class LoadingScreen: BaseviewController {
    @IBOutlet weak var loadImageView: UIImageView!
    var isFromThankyouPage = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.addBackground(imageName: "splash_h", contentMode: .scaleToFill)
 
        var loginDict = [String: Any]()
        
        let info = DeviceInfo.sharedConfiguration.createDictionary()
        
        if let deviceInfo = UserDeviceDetails.checkDeviceId() {
            loginDict = ["a":"device-info" ,
                         "deviceid":deviceInfo.deviceUniqueId!,
                         "devicedetail": info]
        }
        
        print(loginDict)
        
        DataManager.userActivation(userDetailDict: loginDict, closure: {Result in
            
            switch Result {
            case .success(let userActivation):
                
                //else
                if userActivation.hasError == VisitorError.success.rawValue{

                    if userActivation.errorCode == VisitorError.resposeCode105.rawValue {
                        self.performSegue(withIdentifier: "signInOutScreenSegue", sender: nil)
                    }
                    else {
                        self.performSegue(withIdentifier: "activationScreenSegue", sender: userActivation)
                    }
                    
                    
                    
                }
                else {
                    
                    if UserDefaults.standard.hasValue(forKey: "loggedInUser") {
                        var userDefaults = UserDefaults.standard
                        userDefaults.removeObject(forKey: "loggedInUser")
                        userDefaults.synchronize()
                    }
                    
                    if userActivation.errorCode == "203"   {
                        self.performSegue(withIdentifier: "errorScreenSegue", sender: userActivation)
                        
                    }else {
                        
                        self.showValidationAlert(title: userActivation.errorHeading!, message: userActivation.errorMessage!)
                    }
                }
                break
            case .failure(let errorMessage):
                print(errorMessage) //errorScreen
                
                self.performSegue(withIdentifier: "errorScreenSegue", sender: nil)
                
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.hasValue(forKey: "fromThankyouPage") {
            var userDefaults = UserDefaults.standard
            userDefaults.removeObject(forKey: "fromThankyouPage")
            userDefaults.synchronize()
            self.performSegue(withIdentifier: "signInOutScreenSegue", sender: nil)
            
        }
       
    }
    /*
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: {
            _ in
            
            if UIDevice.current.orientation.isLandscape {
                print("Landscape")//splash_v
//                self.loadImageView.image =  #imageLiteral(resourceName: "splash_h")
                self.view.addBackground(imageName: "splash_h", contentMode: .scaleToFill)
                
                
            } else {
                print("Portrait")
                self.loadImageView.image = #imageLiteral(resourceName: "splash_v")
                
            }
        })
        
    }
    */
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "activationScreenSegue" {
            var homeViewController = segue.destination as! HomeViewController
            let deviceDetails = sender as!  UserDeviceDetails
            homeViewController.userActivation = deviceDetails
            //            vc.data = "Data you want to pass"
            //Data has to be a variable name in your RandomViewController
        }
        if segue.identifier == "errorScreenSegue" {
            var errorViewController = segue.destination as! ErrorViewController
            let deviceDetails = sender as!  UserDeviceDetails
            errorViewController.errorMessgeText = deviceDetails.errorMessage
            
        }
    }
    
    
    
    
}

extension UIView {
    func addBackground(imageName: String, contentMode: UIViewContentMode) {
        let imageViewBackground = UIImageView()
        imageViewBackground.image = UIImage(named: imageName)
        
        // you can change the content mode:
        imageViewBackground.contentMode = contentMode
        imageViewBackground.clipsToBounds = true
        imageViewBackground.translatesAutoresizingMaskIntoConstraints = false
        
        self.insertSubview(imageViewBackground, at: 0)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[imageViewBackground]|",
                                                                           options: [],
                                                                           metrics: nil,
                                                                           views: ["imageViewBackground": imageViewBackground]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageViewBackground]|",
                                                                           options: [],
                                                                           metrics: nil,
                                                                           views: ["imageViewBackground": imageViewBackground]))
    }
}


