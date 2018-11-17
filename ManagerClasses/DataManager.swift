//
//  DataManager.swift
//  
//
//  Created by Nitesh Meshram on 28/06/18.
//

import Foundation
import SwiftyJSON
import UIKit

enum URI {
    case UserActivation
//    case SaveData
    case SaveData_WithID (deviceId: String)
    
    
    func uriString() -> String {
        switch self {
        //http://dev.visitorbay.com/api/?a=device-info&deviceid=1111111111111
        case .UserActivation: return "" //"http://dev.visitorbay.com/api"
//        case .SaveData: return "/?a=save-visitor&deviceid=DD45B2AD-EB43-4B3B-9941-D284BC3D0930"
            
        case .SaveData_WithID(let deviceId): return "/?a=save-visitor&deviceid=\(deviceId)"
            
            
            
            
            
        //http://dev.visitorbay.com/api/?a=activate-device&deviceid=<>&acode=<activationcode>
        }
    }
}

// http://dev.visitorbay.com/api/?a=save-visitor&deviceid=<deviceid>formdata={}


enum VisitorError: String {
    case fail = "1"
    case success = "0"
    case resposeCode105 = "105"
}


class DataManager {
    
    //MARK: - Datamanager sharedInstance
    static var userDeviceId: String = ""
    
    class func sharedInstance() -> DataManager {
        struct Static {
            static let sharedInstance = DataManager()
            //userDeviceId = UIDevice.current.identifierForVendor?.uuidString
        }
        return Static.sharedInstance
    }
    
    func initialize() {
        DataManager.userDeviceId = (UIDevice.current.identifierForVendor?.uuidString)!
    }
    //MARK: - Registration
    class func userActivation(userDetailDict: [String:Any], closure: @escaping(Result<UserDeviceDetails,String>) ->Void){
        
        ServerManager.sharedInstance().getRequest(queryStringData: userDetailDict, apiName: .UserActivation, extraHeader: nil) { Result in
            
            switch Result {
            case .success(let jsonResponse):

                var userActivation =  UserDeviceDetails.convertJsonToObject(jsonString: jsonResponse, deviceId: userDetailDict["deviceid"] as! String)!
                
                closure(.success(userActivation))
                break
            case .failure(let errorMessage):
                closure(.failure(errorMessage))
            }
        }
    }
    
    
    
    // Activation

    class func activationWithKey(userDetailDict: [String:Any], closure: @escaping(Result<DeviceActivationDetails,String>) ->Void){
        
        ServerManager.sharedInstance().getRequest(queryStringData: userDetailDict, apiName: .UserActivation, extraHeader: nil) { Result in
            
            switch Result {
            case .success(let jsonResponse):
                var userActivation = DeviceActivationDetails.convertJsonToObject(jsonString: jsonResponse, userDeviceId: userDetailDict["deviceid"] as! String)!
                closure(.success(userActivation))
                break
            case .failure(let errorMessage):
                closure(.failure(errorMessage))
            }
        }
    }
    
    
    class func postUserData(userDetailDict: [String:Any], deviceID: String, closure: @escaping(Result<JSON,String>) ->Void){
        

        

        ServerManager.sharedInstance().postRequest(postData: userDetailDict, apiName: .SaveData_WithID(deviceId: deviceID) , extraHeader: nil) { Result in
            switch Result {
            case .success(let jsonResponse):
                print(jsonResponse)
                closure(.success(jsonResponse))
                break
            case .failure(let errorMessage):
                print(errorMessage)
                closure(.failure(errorMessage))
            }
        }
        /*
        ServerManager.sharedInstance().getRequest(queryStringData: userDetailDict, apiName: .UserActivation, extraHeader: nil) { Result in
            switch Result {
            case .success(let jsonResponse):
                print(jsonResponse)
                closure(.success(jsonResponse))
                break
            case .failure(let errorMessage):
                print(errorMessage)
                closure(.failure(errorMessage))
            }
        }*/
    }
    
    class func userFormAPI(userDetailDict: [String:Any], closure: @escaping(Result<JSON,String>) ->Void){
        
        ServerManager.sharedInstance().getRequest(queryStringData: userDetailDict, apiName: .UserActivation, extraHeader: nil) { Result in
            
            switch Result {
            case .success(let jsonResponse):
                print(jsonResponse)
//                var userActivation = DeviceActivationDetails.convertJsonToObject(jsonString: jsonResponse, userDeviceId: userDetailDict["deviceid"] as! String)!
                closure(.success(jsonResponse))
                break
            case .failure(let errorMessage):
                closure(.failure(errorMessage))
            }
        }
    }
//    http://dev.visitorbay.com/api/?a=render-form&deviceid=<deviceid>
    
    
    class func searchUser(userDetailDict: [String:Any], closure: @escaping(Result<JSON,String>) ->Void){
        // http://dev.visitorbay.com/api/?a=search-visitor&deviceid=DD45B2AD-EB43-4B3B-9941-D284BC3D0930&searchstr=123
        ServerManager.sharedInstance().getRequest(queryStringData: userDetailDict, apiName: .UserActivation, extraHeader: nil) { Result in
            
            switch Result {
            case .success(let jsonResponse):
                if jsonResponse["response"]["status"].stringValue == VisitorError.resposeCode105.rawValue {
                    closure(.success(jsonResponse))
                }
                else if (jsonResponse["response"][0]["status"].stringValue == VisitorError.resposeCode105.rawValue) {
                    closure(.success(jsonResponse))
                }
                    
                else {
                    closure(.success(nil))
                }
                break
            case .failure(let errorMessage):
                closure(.failure(errorMessage))
            }
        }
    }
    
    
    class func searchUserForSignOut(userDetailDict: [String:Any], closure: @escaping(Result<JSON,String>) ->Void){
        // http://dev.visitorbay.com/api/?a=search-visitor&deviceid=DD45B2AD-EB43-4B3B-9941-D284BC3D0930&searchstr=123
        ServerManager.sharedInstance().getRequest(queryStringData: userDetailDict, apiName: .UserActivation, extraHeader: nil) { Result in
            
            switch Result {
            case .success(let jsonResponse):
                if (jsonResponse["response"][0]["status"].stringValue == VisitorError.resposeCode105.rawValue) {
                    if let userList = jsonResponse["userList"].array {
                        debugPrint(userList)
                        closure(.success(jsonResponse))
                    }
                }
                else {
                    closure(.success(nil))
                }
                break
            case .failure(let errorMessage):
                closure(.failure(errorMessage))
            }
        }
    }
    
    // http://dev.visitorbay.com/api/?a=quick-checkin&deviceid=<deviceid>&id=<id>

    
    class func checkinUser(userDetailDict: [String:Any], closure: @escaping(Result<JSON,String>) ->Void){
        // http://dev.visitorbay.com/api/?a=search-visitor&deviceid=DD45B2AD-EB43-4B3B-9941-D284BC3D0930&searchstr=123
        ServerManager.sharedInstance().getRequest(queryStringData: userDetailDict, apiName: .UserActivation, extraHeader: nil) { Result in
            
            switch Result {
            case .success(let jsonResponse):
                if jsonResponse["response"]["status"].stringValue == VisitorError.resposeCode105.rawValue {
                    closure(.success(jsonResponse))
                }
                break
            case .failure(let errorMessage):
                closure(.failure(errorMessage))
            }
        }
    }
    
    
    // please call http://dev.visitorbay.com/api/?a=sign-out&deviceid=<deviceid>&id=<id>
    
    class func signOutUser(userDetailDict: [String:Any], closure: @escaping(Result<JSON,String>) ->Void){
        // http://dev.visitorbay.com/api/?a=search-visitor&deviceid=DD45B2AD-EB43-4B3B-9941-D284BC3D0930&searchstr=123
        ServerManager.sharedInstance().getRequest(queryStringData: userDetailDict, apiName: .UserActivation, extraHeader: nil) { Result in
            
            switch Result {
            case .success(let jsonResponse):
                if jsonResponse["response"]["status"].stringValue == VisitorError.resposeCode105.rawValue {
                    closure(.success(jsonResponse))
                }
                break
            case .failure(let errorMessage):
                closure(.failure(errorMessage))
            }
        }
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
    
    func updateImageOrientionUpSide() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        }
        UIGraphicsEndImageContext()
        return nil
    }
}
