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
        do {
            let environment = try buildEnvironment(
                resourceUrl: .setup,
                environment: (establish["env"] ?? "") as! String,
                localUrl: (establish["envHost"] ?? "") as! String,
                paymentType: (establish["paymentType"] ?? "") as! String,
                build: Constants.buildSDK,
                path: .mobile
            )
            
            let normalizedEstablish = EstablishDataUtils.normalizeEstablishWithDotNotation(establish: establish as! [String : AnyHashable])
            
            if let token = JSONUtils.getJsonBase64From(dictionary: normalizedEstablish) {
                
                APIRequest.getTrustlySettingsWith(url: environment.url, token: token) { trustlySettings in
                    
                    if let trustlySettings = trustlySettings {
                        let settings = TrustlySettings(settings: trustlySettings.settings, createdDateTime: Date())
                        
                        saveData(settings, keyStorage: .settings)
                        
                        completionHandler(settings)
                    }
                    
                    completionHandler(nil)
                }
            }
            
        } catch {
            print("SettingsManager Error: building url.")
        }
    }
}
