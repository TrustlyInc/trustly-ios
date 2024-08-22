//
//  SettingsManager.swift
//  Pods
//
//  Created by Marcos Rivereto on 22/08/24.
//

import Foundation


/** @abstract Will check if sdk need to call the settings endpoint, or just return the value stored in the cache.
 @param establish: [AnyHashable : Any]
 @param completionHandler: @escaping(TrustlySettings?) -> Void
 */
func getTrustlySettingsWith(establish: [AnyHashable : Any], completionHandler: @escaping(TrustlySettings?) -> Void) {
    
    if let trustlySettings: TrustlySettings = readDataFrom(keyStorage: .settings),
       trustlySettings.isValid() {
        
        completionHandler(trustlySettings)
        
    } else {
        APIRequest.getTrustlySettingsWith(establish: establish) { trustlySettings in
            
            if let trustlySettings = trustlySettings {
                let settings = TrustlySettings(settings: trustlySettings.settings, createdDateTime: Date())
                
                saveData(settings, keyStorage: .settings)
            }
            
            completionHandler(trustlySettings)
        }
    }
}
