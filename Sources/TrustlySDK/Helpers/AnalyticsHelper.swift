//
//  AnalyticsHelper.swift
//  Pods
//
//  Created by Marcos Rivereto on 31/03/25.
//

import Foundation

class AnalyticsHelper {
    

    static func sendMerchantDeviceInfo() {
        var merchantData = [String: String]()
        
        merchantData["deviceModel"] = DeviceHelper.deviceModel()
        merchantData["merchantAppBuildNumber"] = DeviceHelper.merchantAppBuildNumber()
        merchantData["merchantAppVersion"] = DeviceHelper.merchantAppVersion()
        merchantData["systemName"] = DeviceHelper.systemName()
        merchantData["systemVersion"] = DeviceHelper.systemVersion()
        
        // TODO: send to core backend
        print("SDk Analytics: \(merchantData)")
    }
}
