//
//  DeviceActivationDetails+CoreDataProperties.swift
//  DemoVisitorApp
//
//  Created by Nitesh Meshram on 04/11/18.
//  Copyright © 2018 V2Solutions. All rights reserved.
//
//

import Foundation
import CoreData


extension DeviceActivationDetails {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DeviceActivationDetails> {
        return NSFetchRequest<DeviceActivationDetails>(entityName: "DeviceActivationDetails")
    }

    @NSManaged public var appuiBackground: String?
    @NSManaged public var appuiCheckinbtntxt: String?
    @NSManaged public var appuiCheckoutbtntxt: String?
    @NSManaged public var appuiFontcolor: String?
    @NSManaged public var appuiShowcheckoutbtn: String?
    @NSManaged public var checkoutmessage: String?
    @NSManaged public var deviceUniqueId: String?
    @NSManaged public var errorCode: String?
    @NSManaged public var errorHeading: String?
    @NSManaged public var errorMessage: String?
    @NSManaged public var hasError: String?
    @NSManaged public var isAgreement: Bool
    @NSManaged public var isRepeated: Bool
    @NSManaged public var isVisitorphoto: Bool
    @NSManaged public var logoURL: String?
    @NSManaged public var responseApikey: String?
    @NSManaged public var welcometxt: String?
    @NSManaged public var deviceDetails: UserDeviceDetails?

}
