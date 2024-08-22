//
//  StorageHelper.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 05/06/23.
//

import Foundation


enum StorageHelper: String {
    case session_cid = "SESSION_CID"
    case settings = "SETTINGS"
}


/** @abstract Save data into UserDefaults.
 @param _ data: T (generic type) to be saved
 @param keyStorage: StorageHelper the key where we will save the data.
 */
func saveData<T: Codable>(_ data: T, keyStorage: StorageHelper) {
    
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(data) {
        let defaults = UserDefaults.standard
        defaults.set(encoded, forKey: keyStorage.rawValue)
    }
}

/** @abstract Read data into UserDefaults.
 @param keyStorage: StorageHelper the key from we will read the data.
 @result T(generic type) data storage in defaults, or nil
 */
func readDataFrom<T: Codable>(keyStorage: StorageHelper) -> T? {
    let defaults = UserDefaults.standard
    
    if let savedData = defaults.object(forKey: keyStorage.rawValue) as? Data {
        let decoder = JSONDecoder()
        
        if let loadedData = try? decoder.decode(T.self, from: savedData) {
            return loadedData
        }
    }
    
    return nil
}
