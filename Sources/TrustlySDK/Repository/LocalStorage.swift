//
//  LocalStorage.swift
//  Pods
//
//  Created by Marcos Rivereto on 19/02/26.
//

class LocalStorage {
    
    static let userDefaults:UserDefaults = UserDefaults.standard
    
    static func getFrom(key:String, defaultValue: String = "") -> String {
        return userDefaults.string(forKey: key) ?? defaultValue
    }
    
    static func save(_ value: String, forKey key: String) {
        userDefaults.set(value,forKey: key)
    }
}
