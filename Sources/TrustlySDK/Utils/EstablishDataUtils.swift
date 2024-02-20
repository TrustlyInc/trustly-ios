//
//  EstablishDataUtils.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 15/02/24.
//

import Foundation


struct EstablishDataUtils {
    
    // MARK: normalizeEstablishWithDotNotation
    
    /// Transform the establish removing the dot notation. Example: from ["customer.address.country": "US"] to ["customer":  ["address": [country": "US"]]]
    ///
    /// - Parameter establish: An establish to be transformed
    /// - Returns: A new [String : AnyHashable] object normalized
    static func normalizeEstablishWithDotNotation(establish: [String : AnyHashable]) -> [String : AnyHashable] {
        
        var newEstablish = [String : AnyHashable]()
        
        establish.forEach { (key: String, value: AnyHashable) in
            
            if key.contains(".") {
                parseData(origin: &newEstablish, key: key, value: value)
                
            } else {
                newEstablish[key] = value

            }
            
        }
        
        return newEstablish
        
    }
    
    /// Responsible to parse the dot notation key, in a clean dictionary key. Example: from ["customer.address.country": "US"] to ["customer":  ["address": [country": "US"]]]
    ///
    /// - Parameters:
    ///     - origin: The origin dictionary
    ///     - key: The key with dot notation
    ///     - value: The value of the key
    static private func parseData(origin: inout [String : AnyHashable], key: String, value: AnyHashable ) {
        
        if key.contains(".") {
            origin.removeValue(forKey: key)
            
            let splitKeys = splitDotNotationKeys(key)

            var newObject: [String : AnyHashable]
            
            if let object = origin[splitKeys.mainKey] {

                newObject = object as! [String : AnyHashable]
                newObject[splitKeys.complementKey] = value
                
            } else {
                newObject = [splitKeys.complementKey: value]
            }
            
            parseData(origin: &newObject, key: splitKeys.complementKey, value: value)
            origin[splitKeys.mainKey] = newObject
            
        } else {
            origin[key] = value
            
        }
    }
    
    /// Split the dot notation key in 2 parts, mainKey and complementKey. Example: from "customer.address.country" to (mainKey: customer, complementKey: address.country)
    ///
    /// - Parameters:
    ///     - key: The key with dot notation
    ///     - value: The value of the key
    /// - Returns: (mainKey: String, complementKey: String)
    static private func splitDotNotationKeys(_ key: String) -> (mainKey: String, complementKey: String) {
        var keys = key.split(separator: ".")
        
        let firstKey = String(keys[0])
        keys.remove(at: 0)
        let secondKey = keys.joined(separator: ".")
            
        return (mainKey: firstKey, complementKey: secondKey)
    }
    
    // MARK: buildEstablishFrom
    
    /// Convert url string with parameter to a normalized establish
    ///
    /// - Parameters:
    ///     - urlWithParameters
    /// - Returns: [String : AnyHashable]
    static func buildEstablishFrom(urlWithParameters: String) -> [String : AnyHashable] {
        var establish: [String : AnyHashable] = [:]
        establish["url"] = urlWithParameters
        
        let parameters = urlWithParameters.split(separator: "?")[1]
        
        for parameter in parameters.split(separator: "&") {
            let keyAndValue = parameter.split(separator: "=")
            
            establish[String(keyAndValue[0])] = String(keyAndValue[1])
        }
        
        return normalizeEstablishWithDotNotation(establish: establish)
    }
}
