//
//  DeviceHelper.swift
//  Pods-TrustlySDK_Example
//
//  Created by Marcos Rivereto on 05/06/23.
//

import Foundation
import UIKit


class DeviceHelper {
 
    static func getDeviceUUID () -> String? {
        
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            return uuid
            
        } else {
            print("Unable to retrieve device ID.")
            
        }

        return nil
    }

    static func systemName() -> String {
        return UIDevice.current.systemName
    }

    static func systemVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    static func model() -> String {
        return UIDevice.current.model
    }
}
