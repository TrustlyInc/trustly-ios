//
//  DeviceHelper.swift
//  Pods-TrustlySDK_Example
//
//  Created by Marcos Rivereto on 05/06/23.
//

import Foundation
import os
import UIKit


func getDeviceUUID () -> String? {
    
    if let uuid = UIDevice.current.identifierForVendor?.uuidString {
        return uuid
        
    } else {
        OSLog.info(log: .deviceHelper, message: "Unable to retrieve device ID.")

    }

    return nil
}
