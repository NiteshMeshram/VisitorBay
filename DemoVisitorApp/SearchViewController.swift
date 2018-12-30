//
//  SearchViewController.swift
//  DemoVisitorApp
//
//  Created by V2Solutions on 19/05/18.
//  Copyright © 2018 V2Solutions. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Kingfisher

private let collectionCellIdentifier = "myProfileViewIdentifier"

class SearchViewController: BaseviewController {
    
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var companyLogo: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchUser: UISearchBar!
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    var searchString: String!
    var userId: String!
    
    var dataSource: JSON?
    var backOutDataSource: JSON?
    
    var initialOrientation = true
    var isInPortrait = false
    
    var comingFrom: String = ""
    
    var searchParametes = [String: Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.searchUserApi()
        
        
        let date = Date()
        let formatter = CheapDateFormatter.formatter()
        self.dateTimeLabel.text = formatter.string(from: date)
        
        if let activationDetails = DeviceActivationDetails.checkDataExistOrNot(){
            
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
            
        }
        
        
        
        let textFieldInsideSearchBar = self.searchUser.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar.leftViewMode = UITextFieldViewMode.never
//        self.searchUser.appearance()
//        UISearchBar.appearance().backgroundColor = UIColor.clear
        self.customizeSearchBar()
        
        let nibName = UINib(nibName: "ProfileCollectionCell", bundle: nil)
        self.collectionView.register(nibName, forCellWithReuseIdentifier: collectionCellIdentifier)
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout{
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            let size = CGSize(width:(collectionView!.bounds.width-30)/2, height: 90)
            layout.itemSize = size
        }
        
        
        if comingFrom == "checkOut" {
            
            
            if let deviceInfo = UserDeviceDetails.checkDataExistOrNot() {
                searchParametes = ["a":"list-visitor" ,
                             "deviceid":deviceInfo.deviceUniqueId!,
                             "searchstr": ""]
            }
            self.searchUserApiForSignOut()
//            self.signOutAPI()
            
            
//            self.searchUserApi(searchText: "")
            
            //userList.isHidden = false
            //userOneButton.isHidden = true
        }
        else {
            //userList.isHidden = true
            //userOneButton.isHidden = false
        }
        
    }
    
    func signOutAPI() {
        var loginDict = [String: Any]()
        if let deviceInfo = UserDeviceDetails.checkDataExistOrNot() {
            if let profileDict = dataSource!["result"].dictionary {
                userId = profileDict["id"]?.stringValue
            }
            loginDict = ["a":"quick-checkin" ,
                         "deviceid":deviceInfo.deviceUniqueId!,
                         "id": userId!] 
        }
        
        DataManager.checkinUser(userDetailDict: loginDict, closure: {Result in
            
            switch Result {
            case .success(let checkinResult):
                self.performSegue(withIdentifier: "thankYouSegue", sender: checkinResult)
                break
            case .failure(let errorMessage):
                print(errorMessage)
                break
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.backButton.isUserInteractionEnabled = true
    }
    
    @IBAction func nextButtonClick(_ sender: Any) {
        
        //        performSegue(withIdentifier: "chekInChecOutSegue", sender: nil)
    }
    
    @IBAction func backButtonClick(_ sender: Any) {
        self.backButton.isUserInteractionEnabled = false
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func userOneSelected(_ sender: Any) {
//
        performSegue(withIdentifier: "thankYouSegue", sender: nil)

    }
    
    @IBAction func userListSelected(_ sender: Any) {
    
        performSegue(withIdentifier: "thankYouSegue", sender: nil)
    }
    
    func customizeSearchBar()
    {
        for subview in searchUser.subviews
        {
            for view in subview.subviews
            {
                if let searchField = view as? UITextField
                {
                    let imageView = UIImageView()
                    let image = UIImage(named: "searchImage")
                    imageView.image = image
                    let point = CGPoint(x: 523,y :100) // CGFloat, Double, Int
                    let rect = CGRect(origin: point, size: CGSize(width: 27, height: 27))
                    imageView.frame = rect
                    searchField.leftView = imageView
                    searchField.leftViewMode = UITextFieldViewMode.always
                }
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "thankYouSegue" {
            let theDestination = (segue.destination as! ThankyouViewController)
            let jsonData = sender as!  JSON
            theDestination.thankYorResponse = jsonData
        }
    }
    
}

extension SearchViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "thankYouSegue", sender: nil)
        
        var loginDict = [String: Any]()
        if let deviceInfo = UserDeviceDetails.checkDataExistOrNot() {
            if let profileDict = self.dataSource![indexPath.row].dictionary {
                userId = profileDict["id"]?.stringValue
            }
            
            if comingFrom == "checkOut" {
                loginDict = ["a":"sign-out" ,
                             "deviceid":deviceInfo.deviceUniqueId!,
                             "id": userId!]
            }else {
                loginDict = ["a":"quick-checkin" ,
                             "deviceid":deviceInfo.deviceUniqueId!,
                             "id": userId!]
            }
            
            
        }
        
        DataManager.checkinUser(userDetailDict: loginDict, closure: {Result in
            
            switch Result {
            case .success(let checkinResult):
                self.performSegue(withIdentifier: "thankYouSegue", sender: checkinResult)
                break
            case .failure(let errorMessage):
                print(errorMessage)
                break
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if dataSource != nil {
            return (dataSource?.count)!
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as! ProfileCollectionCell
        
        var bcolor : UIColor = UIColor( red: 0.2, green: 0.2, blue:0.2, alpha: 0.3 )
        
        cell.layer.borderColor = bcolor.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 3

        let profileDict = self.dataSource![indexPath.row].dictionary
        
        cell.labelOne.text = profileDict!["name"]!.stringValue
        cell.labelTwo.text = profileDict!["phone"]!.stringValue
        let imageUrlString = profileDict!["userpic"]!.stringValue
        cell.profilePic.image = UIImage(url: URL(string: imageUrlString))
        cell.profilePic.contentMode = .scaleAspectFill
        cell.profilePic.translatesAutoresizingMaskIntoConstraints = false
        
        /*
         
        print(profileDict!["phone"]!)
        print(profileDict!["name"]!)
        print(profileDict!["id"]!)
        print(profileDict!["userpic"]!)
         
         */
        
        
        
        return cell
        
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    //MARK: - SEARCH
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            //reload your data source if necessary
            
//            self.searchUserApi(searchText: searchBar.text!)
            
            if let deviceInfo = UserDeviceDetails.checkDataExistOrNot() {
                searchParametes = ["a":"search-visitor" ,
                                   "deviceid":deviceInfo.deviceUniqueId!,
                                   "searchstr": searchBar.text!]
            }
            self.searchUserApi()
            
            
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            //reload your data source if necessary
            if comingFrom == "checkOut" {
                
                if self.comingFrom == "checkOut" && self.backOutDataSource != nil {
                    self.dataSource = self.backOutDataSource 
                }

                
//                self.dataSource = nil
            }
            else {
                self.dataSource = nil
            }
            
            self.collectionView?.reloadData()
        }
    }
    
    

}


extension SearchViewController {
    // http://dev.visitorbay.com/api/?a=search-visitor&deviceid=DD45B2AD-EB43-4B3B-9941-D284BC3D0930&searchstr=123
    func searchUserApi()//(searchText: String)
    {
        DataManager.searchUser(userDetailDict: searchParametes, closure: {Result in
            
            switch Result {
            case .success(let searchDetails):
                
                if searchDetails != nil {
                    if self.comingFrom == "checkOut" && self.dataSource != nil {
                            self.backOutDataSource = self.dataSource
                    }
                    self.dataSource = searchDetails["userList"]
                    
                    print(searchDetails)
                }
                else {
                    self.dataSource = nil

                }
                self.collectionView?.reloadData()
                self.searchUser.resignFirstResponder()
                
                
                break
            case .failure(let errorMessage):
                print(errorMessage)
                
                break
            }
        })
    }
    
    func searchUserApiForSignOut()//(searchText: String)
    {
        DataManager.searchUserForSignOut(userDetailDict: searchParametes, closure: {Result in
            
            switch Result {
            case .success(let searchDetails):
                
                if searchDetails != nil {
                    
//                    searchDetails["userList"]
                    self.dataSource = searchDetails["userList"]
                    
                    print(searchDetails)
                }
                else {
                    self.dataSource = nil
                    
                }
                self.collectionView?.reloadData()
                
                
                
                break
            case .failure(let errorMessage):
                print(errorMessage)
                
                break
            }
        })
    }
    
    
//    searchUserForSignOut
    
}

extension UIImage {
    convenience init?(url: URL?) {
        guard let url = url else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data)
        } catch {
            print("Cannot load image from url: \(url) with error: \(error)")
            return nil
        }
    }
}


