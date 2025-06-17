//
//  TrustlySettings.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 22/08/24.
//

import Foundation


struct TrustlySettings: Codable, Hashable {
    let settings: Settings
    var createdDateTime: Date?
    
    func isValid() -> Bool {
        let dateNow = Date()
        
        if let createdTime = createdDateTime {
            
            let diffs = Calendar.current.dateComponents([.minute], from: createdTime, to: dateNow)
            
            if let minutes = diffs.minute {
                return minutes < Constants.SETTINGS_CACHE_TIME_LIMIT
            }
        }
        
        return false
    }
}

struct Settings: Codable, Hashable {
    var webviewUserAgent = ""
    var inAppUserAgent: String {
        "Mozilla/5.0 (\(DeviceHelper.model()); CPU iPhone OS \(DeviceHelper.systemVersion().replacingOccurrences(of: ".", with: "_")) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) InAppBrowser/1.0 Mobile/15E148 Safari/605.1.15"
    }

    let integrationStrategy: String
    
    var userAgent: String {
        self.isInAppBrowserEnabled() ? self.inAppUserAgent : self.webviewUserAgent
    }
    
    func isInAppBrowserEnabled() -> Bool {
        return false//self.integrationStrategy == Constants.LIGHTBOX_CONTEXT_INAPP
    }
    
    enum CodingKeys: String, CodingKey {
        case integrationStrategy
    }
}
