//
//  VisitorsCommon.swift
//  DemoVisitorApp
//
//  Created by Nitesh Meshram on 31/10/18.
//  Copyright © 2018 V2Solutions. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

extension DeviceActivationDetails {
    
    static func checkDataExistOrNot() -> DeviceActivationDetails? {
        
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        do {
            let fetchRequest : NSFetchRequest<DeviceActivationDetails> = DeviceActivationDetails.fetchRequest()
            /*
             let uuid: String? = UserDefaults.standard.object(forKey: "userDeviceId") as? String
             fetchRequest.predicate = NSPredicate(format: "deviceUniqueId == %@", uuid!)
             */
            let fetchedResults = try context.fetch(fetchRequest)
            if let deviceActivation = fetchedResults.first {
                return deviceActivation
            }
        }
        catch {
            print ("fetch task failed", error)
        }
        return nil
        
    }
    
    
    static func convertJsonToObject(jsonString: JSON, userDeviceId: String) -> DeviceActivationDetails? {
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "UserDeviceDetails")
        let predicate = NSPredicate(format: "deviceUniqueId = '\(userDeviceId)'")
        fetchRequest.predicate = predicate
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        
        do
        {
            let deviceInfoData = try context.fetch(fetchRequest)
            let deviceInfo: UserDeviceDetails = deviceInfoData.first as! UserDeviceDetails
            var activationData: DeviceActivationDetails?
            if let activationData = DeviceActivationDetails.checkDataExistOrNot() {
//                print(activationData)
                deviceInfo.activationsDetails = activationData
            }
            else {
//                print("No Data")
                activationData = DeviceActivationDetails(context: context)
                deviceInfo.activationsDetails = activationData
            }
            
            if let errorDict = jsonString["error"].dictionary {
                if errorDict["hasError"]?.stringValue == VisitorError.success.rawValue {
                    if let dict = jsonString["response"].dictionary {
                        deviceInfo.activationsDetails?.deviceUniqueId = deviceInfo.deviceUniqueId
                        
                        /* Start 1 */
                        if let appui = jsonString["appui"].dictionary {
                            if let fontcolor = appui["fontcolor"]?.stringValue{
                                deviceInfo.activationsDetails?.appuiFontcolor = fontcolor
                            }
                            if let background = appui["background"]?.stringValue{
                                deviceInfo.activationsDetails?.appuiBackground = background
                            }
                            if let checkinbtntxt = appui["checkinbtntxt"]?.stringValue{
                                deviceInfo.activationsDetails?.appuiCheckinbtntxt = checkinbtntxt
                            }
                            if let showcheckoutbtn = appui["showcheckoutbtn"]?.stringValue{
                                deviceInfo.activationsDetails?.appuiShowcheckoutbtn = showcheckoutbtn
                            }
                            if let checkoutbtntxt = appui["checkoutbtntxt"]?.stringValue{
                                deviceInfo.activationsDetails?.appuiCheckoutbtntxt = checkoutbtntxt
                            }
                        }
                        /* End 1 */
                        
                        /* Start 2 */
                        
                        if let welcometxtDict = jsonString["welcometxt"].dictionary {
                            if let showwelcome = welcometxtDict["showwelcome"]?.stringValue{
                                if showwelcome == "1" {
                                    if let welcometxt = welcometxtDict["welcometxt"]?.stringValue{
                                        deviceInfo.activationsDetails?.welcometxt = welcometxt
                                    }
                                }
                            }
                        }
                        
                        /* End 2 */
                        
                        
                        if let errorCode = errorDict["hasError"]?.stringValue {
                            deviceInfo.activationsDetails?.hasError = errorCode
                        }
                        
                        if let errorStatus = dict["status"]?.stringValue {
                            deviceInfo.activationsDetails?.errorCode = errorStatus
                        }
                        
                        if let errorHeading = dict["errorHeading"]?.stringValue {
                            deviceInfo.activationsDetails?.errorHeading = errorHeading
                        }
                        
                        if let errorMessage = dict["errorMessage"]?.stringValue {
                            deviceInfo.activationsDetails?.errorMessage = errorMessage
                        }
                        
                        
                        if let logoDict = jsonString["logo"].dictionary {
                            if let showwelcome = logoDict["showLogo"]?.stringValue{
                                if showwelcome == "1" {
                                    if let logoDetails = logoDict["logo"]?.stringValue{
                                        deviceInfo.activationsDetails?.logoURL = logoDetails
                                    }
                                }
                                else {
                                    deviceInfo.activationsDetails?.logoURL = ""
                                }
                                
                            }

                            
                        }
                    }
                }
            }
            
            do{
                try context.save()
                return deviceInfo.activationsDetails
            }
            catch
            {
                print(error)
            }
        }
        catch
        {
            print(error)
        }
        
        return nil
    }
}

///


extension UserDeviceDetails {
    static func createDeviceEntity() {
        
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let deviceEntity = NSEntityDescription.insertNewObject(forEntityName: "UserDeviceDetails", into: context) as? UserDeviceDetails {
            
            //            deviceEntity.deviceUniqueId = UIDevice.current.identifierForVendor?.uuidString
            
            if UserDefaults.standard.hasValue(forKey: "deviceUDID") {
                let defaults = UserDefaults.standard
                let deviceId = defaults.string(forKey: "deviceUDID") //Retrieving the value from user default
                deviceEntity.deviceUniqueId = deviceId
            }
            
            do {
                try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    static func checkDeviceId() -> UserDeviceDetails? {
        
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        do {
            let fetchRequest : NSFetchRequest<UserDeviceDetails> = UserDeviceDetails.fetchRequest()
            
            if UserDefaults.standard.hasValue(forKey: "deviceUDID") {
                let defaults = UserDefaults.standard
                let deviceId = defaults.string(forKey: "deviceUDID") //Retrieving the value from user default
                fetchRequest.predicate = NSPredicate(format: "deviceUniqueId == %@", deviceId!)
            }
            else {
                let defaults = UserDefaults.standard
                defaults.set(UIDevice.current.identifierForVendor?.uuidString, forKey: "deviceUDID")
                //                defaults.set("7148141D-5363-49C9-BE16-FF141E1B760F", forKey: "deviceUDID")
                
                defaults.synchronize()
                
                self.createDeviceEntity()
            }
            let fetchedResults = try context.fetch(fetchRequest)
            if let deviceInfo = fetchedResults.first {
                return deviceInfo
            }
            return nil
        }
        catch {
            print ("fetch task failed", error)
        }
        return nil
        
    }
    
    static func checkDataExistOrNot() -> UserDeviceDetails? {
        
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        do {
            let fetchRequest : NSFetchRequest<UserDeviceDetails> = UserDeviceDetails.fetchRequest()
            /*
             let uuid: String? = UserDefaults.standard.object(forKey: "userDeviceId") as? String
             fetchRequest.predicate = NSPredicate(format: "deviceUniqueId == %@", uuid!)
             */
            let fetchedResults = try context.fetch(fetchRequest)
            if let deviceInfo = fetchedResults.first {
                return deviceInfo
            }
        }
        catch {
            print ("fetch task failed", error)
        }
        return nil
        
    }
    
    static func checkDeviceActivationCode() -> UserDeviceDetails? {
        
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        do {
            let fetchRequest : NSFetchRequest<UserDeviceDetails> = UserDeviceDetails.fetchRequest()
            /*
             let uuid: String? = UserDefaults.standard.object(forKey: "userDeviceId") as? String
             fetchRequest.predicate = NSPredicate(format: "deviceUniqueId == %@", uuid!)
             */
            let fetchedResults = try context.fetch(fetchRequest)
            if let deviceInfo = fetchedResults.first {
                if deviceInfo.activation_code != nil {
                    return deviceInfo
                }
                else {
                    return nil
                }
                
            }
        }
        catch {
            print ("fetch task failed", error)
        }
        return nil
        
    }
    
    static func convertJsonToObject(jsonString: JSON, deviceId: String) -> UserDeviceDetails? {
        
        if let userDevice = checkDataExistOrNot() {
            if let errorDict = jsonString["error"].dictionary {
                
                if errorDict["hasError"]?.stringValue == VisitorError.success.rawValue {
                    
                    if let dict = jsonString["response"].dictionary {
                        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
                        if let topLineText = dict["topline1text"]?.stringValue{
                            userDevice.topline1text = topLineText
                        }
                        
                        if let topline2text = dict["topline2text"]?.stringValue{
                            userDevice.topline2text = topline2text
                        }
                        
                        if let activation_code = dict["activation_code"]?.stringValue{
                            userDevice.activation_code = activation_code
                        }
                        
                        if let activatebtntxt = dict["activatebtntxt"]?.stringValue{
                            userDevice.activatebtntxt = activatebtntxt
                        }
                        
                        if let errorCode = errorDict["hasError"]?.stringValue {
                            userDevice.hasError = errorCode
                        }
                        
                        if let errorStatus = dict["status"]?.stringValue {
                            userDevice.errorCode = errorStatus
                        }
                        
                        if let errorHeading = dict["errorHeading"]?.stringValue {
                            userDevice.errorHeading = errorHeading
                        }
                        
                        if let errorMessage = dict["errorMessage"]?.stringValue {
                            userDevice.errorMessage = errorMessage
                        }
                        
                        /******/
                        
                       
                        
                        if userDevice.activationsDetails != nil {
                             /* Start 1 */
                            if let appui = jsonString["appui"].dictionary {
                                if let fontcolor = appui["fontcolor"]?.stringValue{
                                    userDevice.activationsDetails?.appuiFontcolor = fontcolor
                                }
                                if let background = appui["background"]?.stringValue{
                                    userDevice.activationsDetails?.appuiBackground = background
                                }
                                if let checkinbtntxt = appui["checkinbtntxt"]?.stringValue{
                                    userDevice.activationsDetails?.appuiCheckinbtntxt = checkinbtntxt
                                }
                                if let showcheckoutbtn = appui["showcheckoutbtn"]?.stringValue{
                                    userDevice.activationsDetails?.appuiShowcheckoutbtn = showcheckoutbtn
                                }
                                if let checkoutbtntxt = appui["checkoutbtntxt"]?.stringValue{
                                    userDevice.activationsDetails?.appuiCheckoutbtntxt = checkoutbtntxt
                                }
                            }
                            
                            /* End 1 */
                            
                            
                            /* Start 2 */
                            
                            if let welcometxtDict = jsonString["welcometxt"].dictionary {
                                if let showwelcome = welcometxtDict["showwelcome"]?.stringValue{
                                    if showwelcome == "1" {
                                        if let welcometxt = welcometxtDict["welcometxt"]?.stringValue{
                                            userDevice.activationsDetails?.welcometxt = welcometxt
                                        }
                                    }
                                    else{
                                        userDevice.activationsDetails?.welcometxt = ""
                                    }
                                }
                            }
                            
                            /* End 2 */
                            
                            if let logoDict = jsonString["logo"].dictionary {
                                if let showwelcome = logoDict["showLogo"]?.stringValue{
                                    if showwelcome == "1" {
                                        if let logoDetails = logoDict["logo"]?.stringValue{
                                            userDevice.activationsDetails?.logoURL = logoDetails
                                        }
                                    }else {
                                        userDevice.activationsDetails?.logoURL = ""
                                    }
                                }
                            }
                            
                            if let checkOutMsg = jsonString["checkoutmessage"].dictionary {
                                if let chkOutMsg = checkOutMsg["checkoutmessage"]?.stringValue{
                                    userDevice.activationsDetails?.checkoutmessage = chkOutMsg
                                }
                            }
                            
                        }
                        
                        
                        
                        
                        
                        /***End of Activation Details Saving***/
                        
                        do {
                            try context.save()
                        } catch let error {
                            print(error)
                        }
                        
                        return userDevice
                        
                    }
                    
                }
                else {
                    print("Error Data ")
                    
                    if let dict = jsonString["response"].dictionary {
                        
                        if let errorCode = errorDict["hasError"]?.stringValue {
                            userDevice.hasError = errorCode
                        }
                        
                        if let errorStatus = dict["status"]?.stringValue {
                            userDevice.errorCode = errorStatus
                        }
                        
                        if let errorHeading = dict["errorHeading"]?.stringValue {
                            userDevice.errorHeading = errorHeading
                        }
                        
                        if let errorMessage = dict["errDesc"]?.stringValue {
                            userDevice.errorMessage = errorMessage
                        }
                        
                        return userDevice
                    }
                    
                    
                    
                }
            }
            
        }
        return nil
    }
}
