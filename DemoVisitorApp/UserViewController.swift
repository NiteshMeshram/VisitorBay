//
//  UserViewController.swift
//  DemoVisitorApp
//
//  Created by V2Solutions on 18/03/18.
//  Copyright © 2018 V2Solutions. All rights reserved.
//

import Foundation
import SwiftyJSON

import UIKit
import Kingfisher

class UserViewController: BaseviewController, UITextFieldDelegate {
    
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var companyLogo: UIImageView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var personToMeetTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    @IBOutlet weak var userInputTextField: CustomUITextField!
    var nextElement = 0
    var dataDictionary: Any!
    var dropDownTextField: CustomUITextField!
    var dropDown: UIPickerView!
    
    var arrayOfControls = [CustomUITextField]()

    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
   
    var list = [String]()

    
    var formData: JSON?
//    var formDataArray = []
    var formDataArray = [Any]()
    
    
    var initialOrientation = true
    var isInPortrait = false
    
    var format : DateFormatter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.populateUIElemente()
        
//       self.UIElementesData()
        
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
    
    //Update clock every second
    @objc func updateClock() {
        let now = NSDate()
        
        self.dateTimeLabel.text =  format.string(from: now as Date)
    }
    
    func populateUIElemente() {
        if let titel = formData!["response"]["form caption"].string {
            self.headerTitle.text = titel
        }
        formDataArray = formData!["formdata"].array!
        
        self.loadData()
        
        
        
    }
    
    func loadData(){
        
        dataDictionary = formDataArray[nextElement]
        
        let dataAtIndex:JSON = dataDictionary as! JSON
        /*
         {
         "label" : "Full name",
         "type" : "text",
         "name" : "vname",
         "id" : "1",
         "req" : 1
         },*/
        
        if let labelText = dataAtIndex["label"].string {
            self.userInputTextField.text = ""
            self.userInputTextField.placeholder = labelText
            
            if labelText == "Phone" {
                self.userInputTextField.keyboardType = UIKeyboardType.phonePad
            }
            else {
                self.userInputTextField.keyboardType = UIKeyboardType.default
            }
            
        }
        
        
        if dataAtIndex["req"].stringValue.toBool() {
            self.userInputTextField.isRequired = dataAtIndex["req"].stringValue.toBool()
        }
        
        if let keyName = dataAtIndex["name"].string {
            self.userInputTextField.keyName = keyName
        }
        
        
        if let controltype = dataAtIndex["type"].string {
            if controltype == "select" {
                
                for (key, listValue) in dataAtIndex["choice"] {
                    self.list.append(listValue.string!)
                }
                
                self.dropDown = UIPickerView()
                self.dropDown.delegate = self
                self.dropDown.dataSource = self
                self.userInputTextField.inputView = self.dropDown
//                self.arrayOfControls.append(self.userInputTextField)
                
            }
            else {
                
            }
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
    
    
    
    @IBAction func loadNextUIElement(_ sender: UIButton) {
        
        var errorString: String = ""
        
        if nextElement >= formDataArray.count - 1  {
            print("IF-Block")
        }
        else {
            print("ELSE-Block")
            nextElement = nextElement + 1
            print("nextElement ==> ",nextElement)
            
            
            if self.userInputTextField.isRequired && (self.userInputTextField.text?.isEmpty)! {
                errorString = errorString + self.userInputTextField.placeholder! + "\n"
            }
            
            VisitorsDetailsManager.shared.finalUserData.updateValue(self.userInputTextField.text!, forKey: self.userInputTextField.keyName)
            
            if !(errorString.isEmpty) {
                self.showValidationAlert(title: "Plese fill below data", message: errorString)
            }
            else {
                self.loadData()
            }
            
            
            
        }
    }
    

    func UIElementesData(){
        

        let xPos : CGFloat = 300
        var yPos : CGFloat = 250
        if let titel = formData!["response"]["form caption"].string {
            self.headerTitle.text = titel
        }
        for (key,value) in Array(formData!["formdata"]).sorted(by: {$0.0 < $1.0}) {
            
            
            
            if value["type"] == "text" {
                let tf = CustomUITextField()
                tf.keyName = value["name"].stringValue
                if value["req"].stringValue == "1" {
                    tf.isRequired = true
                }
                else {
                    tf.isRequired = false
                }
                
                tf.frame = CGRect(x: xPos, y: yPos, width: 450, height: 40)
//                tf.backgroundColor = UIColor.black
                
                
                tf.placeholder = value["label"].string
                
                
                
                
                
                tf.borderStyle = UITextBorderStyle.roundedRect
                tf.autocorrectionType = UITextAutocorrectionType.no
                
                
                if value["label"].string == "Phone" {
                    tf.keyboardType = UIKeyboardType.phonePad
                }
                else {
                    tf.keyboardType = UIKeyboardType.default
                }
                tf.returnKeyType = UIReturnKeyType.done
                tf.clearButtonMode = UITextFieldViewMode.whileEditing
                tf.contentVerticalAlignment = UIControlContentVerticalAlignment.center
                tf.delegate = self
                self.view.addSubview(tf)
                self.arrayOfControls.append(tf)
                yPos += 86

            }
            if value["type"] == "select" {

                for (key, listValue) in value["choice"] {
                    self.list.append(listValue.string!)
                }
                
                self.dropDownTextField = CustomUITextField()
                self.dropDownTextField.keyName = value["name"].stringValue
                if value["req"].stringValue == "1" {
                    dropDownTextField.isRequired = true
                }
                else {
                    dropDownTextField.isRequired = false
                }
                self.dropDownTextField.delegate = self
                self.dropDownTextField.frame = CGRect(x: xPos, y: yPos, width: 450, height: 40)
                
                self.dropDownTextField.borderStyle = UITextBorderStyle.roundedRect
                self.dropDownTextField.autocorrectionType = UITextAutocorrectionType.no
                self.dropDownTextField.keyboardType = UIKeyboardType.default
                self.dropDownTextField.returnKeyType = UIReturnKeyType.done
                self.dropDownTextField.clearButtonMode = UITextFieldViewMode.whileEditing
                self.dropDownTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
                self.dropDownTextField.placeholder = value["label"].string
                self.dropDownTextField.delegate = self
                
                self.dropDown = UIPickerView()
                self.dropDown.delegate = self
                self.dropDown.dataSource = self
                self.dropDownTextField.inputView = self.dropDown
                self.view.addSubview(self.dropDownTextField)
                self.arrayOfControls.append(self.dropDownTextField)
                
                yPos += 86
            }
            
        }
        
//        print(formData!["formdata"])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonClick(_ sender: Any) {
        /*nextElement = nextElement + 1
        dataDictionary = formDataArray[nextElement]
        
        let dataAtIndex:JSON = dataDictionary as! JSON
        
        print(dataAtIndex["type"])*/
        
        /*
//        var userFormData = [String: Any]()
        
        var errorString: String = ""
        
        for object in self.arrayOfControls as [CustomUITextField] {
            

            if object.isRequired && (object.text?.isEmpty)! {
                errorString = errorString + object.placeholder! + "\n"
            }
            
            VisitorsDetailsManager.shared.finalUserData.updateValue(object.text!, forKey: object.keyName)
            
        }
        if !(errorString.isEmpty) {
             self.showValidationAlert(title: "Plese fill below data", message: errorString)
        }
        else {
            
        }
        
        if let activationDetails = DeviceActivationDetails.checkDataExistOrNot(){
            
            if activationDetails.isAgreement {
                performSegue(withIdentifier: "agreementSegue", sender: nil)
            }
            else {
                if activationDetails.isVisitorphoto {
                    performSegue(withIdentifier: "profileFromUserScreenSegue", sender: nil)
                }
                else {
//                    performSegue(withIdentifier: "thankyouFromUserScreenSegue", sender: nil)
                    self.saveData()
                }
            }
        }
        */
        
        
        
        
        if let activationDetails = DeviceActivationDetails.checkDataExistOrNot(){
            
            if activationDetails.isAgreement {
                performSegue(withIdentifier: "agreementSegue", sender: nil)
            }
            else {
                if activationDetails.isVisitorphoto {
                    performSegue(withIdentifier: "profileFromUserScreenSegue", sender: nil)
                }
                else {
                    //                    performSegue(withIdentifier: "thankyouFromUserScreenSegue", sender: nil)
                    self.saveData()
                }
            }
        }
        
        
//        performSegue(withIdentifier: "agreementSegue", sender: nil)
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
                    self.performSegue(withIdentifier: "thankyouFromUserScreenSegue", sender: userData)
                }
                
                break
            case .failure(let errorMessage):
                
                print(errorMessage)
                
                break
            }
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "thankyouFromUserScreenSegue" {
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
        
//       self.AdjustConstraint()
        
    }
    
//    func AdjustConstraint() {
//        if UIDevice.current.orientation.isPortrait {
//            self.topConstraint.constant = 130.00
//        }
//        else {
//            self.topConstraint.constant = 00.00
//        }
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}

class CustomUITextField: UITextField {
    var keyName: String = ""
    var isRequired: Bool = false
//    public var keyName : String {
//        get
//        {
//            return self.keyName
//        }
//
//        set
//        {
//            self.keyName = newValue
//
//        }
//    }
}

extension UITextField {
    
    
//    public var keyName : String {
//        get
//        {
//            return self.keyName
//        }
//
//        set
//        {
//            self.keyName = newValue
//
//        }
//    }
    
    func setBottomLine(borderColor: UIColor) {
        
        self.borderStyle = UITextBorderStyle.none
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.withAlphaComponent(1.0).cgColor
            
//            UIColor.lightGrayColor().colorWithAlphaComponent(0.2).CGColor

        
//        self.borderStyle = UITextBorderStyle.none
//        self.backgroundColor = UIColor.clear
//
//        let borderLine = UIView()
//        let height = 1.0
//        borderLine.frame = CGRect(x: 0, y: Double(self.frame.height) - height, width: Double(self.frame.width), height: height)
//
//        borderLine.backgroundColor = borderColor
//        self.addSubview(borderLine)
    }
}


extension Dictionary {
    subscript(i:Int) -> (key:Key,value:Value) {
        get {
            return self[index(startIndex, offsetBy: i)];
        }
    }
}

extension UserViewController : UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.userInputTextField.text = list[row]
    }
}


