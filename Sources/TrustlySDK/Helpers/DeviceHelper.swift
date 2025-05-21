//
//  DeviceHelper.swift
//  Pods-TrustlySDK_Example
//
//  Created by Marcos Rivereto on 05/06/23.
//

import Foundation
import os

class DeviceHelper {
    static func getDeviceUUID () -> String? {
        
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            return uuid
            
        } else {
            Logs.info(log: Logs.deviceHelper, message: "Unable to retrieve device ID.")
        }

        return nil
    }

    static func systemName() -> String {
        return UIDevice.current.systemName
    }

    static func systemVersion() -> String {
        return UIDevice.current.systemVersion
    }

    static func merchantAppBuildNumber () -> String {
        if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return buildNumber
        }
        
        return ""
    }

    static func merchantAppVersion () -> String {
        if let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return versionNumber
        }
        
        return ""
    }

    static func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
         
        return identifier
    }
}
