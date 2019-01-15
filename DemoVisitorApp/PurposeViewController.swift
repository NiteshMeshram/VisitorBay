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

private let collectionCellIdentifier = "myPurposeViewIdentifier"


class PurposeViewController: BaseviewController {
    
    var purposeTypeJSON: JSON?
    var dataListArray = [Any]()
    
    var initialOrientation = true
    var isInPortrait = false
    
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var companyLogo: UIImageView!
    var format : DateFormatter!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.isUserInteractionEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        VisitorsDetailsManager.shared.finalUserData.removeAll()
        dataListArray = purposeTypeJSON!["meetingType"].array!
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let date = Date()
        format = CheapDateFormatter.formatter()
        self.dateTimeLabel.text = format.string(from: date)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
        
        if let activationDetails = DeviceActivationDetails.checkDataExistOrNot(){
            self.setLogoImage()
            
            self.view.backgroundColor = activationDetails.appBackgroundColor()
        }
        
        let nibName = UINib(nibName: "MeetingTypeCollectionViewCell", bundle: nil)
        self.collectionView.register(nibName, forCellWithReuseIdentifier: collectionCellIdentifier)
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout{
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            let size = CGSize(width:(collectionView!.bounds.width-30)/2, height: 90)
            layout.itemSize = size
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

extension PurposeViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        performSegue(withIdentifier: "thankYouSegue", sender: nil)
        self.collectionView.isUserInteractionEnabled = false
        
        let typeData = self.dataListArray[indexPath.row] as! JSON
//        cell.purposeTypeLabel.text = typeData["type"].string
        
        VisitorsDetailsManager.shared.finalUserData.updateValue(typeData["type"].string!, forKey: "purpose")
        
        
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
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /*
        if dataSource != nil {
            return (dataSource?.count)!
        }*/
        return dataListArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as! MeetingTypeCollectionViewCell
        
        var bcolor : UIColor = UIColor( red: 0.2, green: 0.2, blue:0.2, alpha: 0.3 )
        
        cell.layer.borderColor = bcolor.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 3
        
        let typeData = self.dataListArray[indexPath.row] as! JSON
        cell.purposeTypeLabel.text = typeData["type"].string
        
        
//        print(typeData)
        
//        cell.labelOne.text = typeData!["type"]!.stringValue
        
        /*
        let profileDict = self.dataSource![indexPath.row].dictionary
        cell.labelOne.text = profileDict!["name"]!.stringValue
        cell.labelTwo.text = profileDict!["phone"]!.stringValue
        let imageUrlString = profileDict!["userpic"]!.stringValue
        cell.profilePic.image = UIImage(url: URL(string: imageUrlString))
        cell.profilePic.contentMode = .scaleAspectFill
        cell.profilePic.translatesAutoresizingMaskIntoConstraints = false
        */
        
        
        
        return cell
        
    }
    
}
