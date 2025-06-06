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
                return minutes < Constants.settingsCacheTimeLimit
            }
        }
        
        return false
    }
}

struct Settings: Codable, Hashable {
    let integrationStrategy: String
}
