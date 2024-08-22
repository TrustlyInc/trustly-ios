//
//  SettingsManager.swift
//  Pods
//
//  Created by Marcos Rivereto on 22/08/24.
//

import Foundation


/** @abstract Will check if sdk need to call the settings endpoint, or just return the value stored in the cache.
 @param establish: [AnyHashable : Any]
 @param completionHandler: @escaping(TrustlyConfig?) -> Void
 */
func getTrustlySettingsWith(establish: [AnyHashable : Any], completionHandler: @escaping(TrustlyConfig?) -> Void) {
    
    if let trustlyConfig: TrustlyConfig = readDataFrom(keyStorage: .settings),
       trustlyConfig.isValid() {
        
        completionHandler(trustlyConfig)
        
    } else {
        APIRequest.getTrustlyConfigWith(establish: establish) { trustlyConfig in
            
            if let trustlyConfig = trustlyConfig {
                let config = TrustlyConfig(settings: trustlyConfig.settings, createdDateTime: Date())
                
                saveData(config, keyStorage: .settings)
            }
            
            completionHandler(trustlyConfig)
        }
    }
}
