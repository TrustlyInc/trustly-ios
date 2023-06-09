//
//  DeviceHelper.swift
//  Pods-TrustlySDK_Example
//
//  Created by Marcos Rivereto on 05/06/23.
//

import Foundation


func getDeviceUUID () -> String? {
    
    if let uuid = UIDevice.current.identifierForVendor?.uuidString {
        return uuid
        
    } else {
        print("Unable to retrieve device ID.")
        
    }

    return nil
}
