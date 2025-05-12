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
        
        return establish
// TODO: This code was commented, because for now we will not normalize the return
//        return normalizeEstablishWithDotNotation(establish: establish)

    }
    
    static func validateEstablishData(establishData: [AnyHashable : Any]) {
        
        var errorMsg = ""
        
        Constants.requiredKeys.forEach {
            if !establishData.keys.contains(AnyHashable($0)) {
                errorMsg += "Required attribute missing: \($0).\n"
            }
        }
        
        if !errorMsg.isEmpty {
            print("############ ESTABLISH DATA VALIDATION ############")
            print(errorMsg)
            print("Learn more at Trustly Docs: \(Constants.establishDataDocsLink)")
            print("###################################################")
        }
        
    }
    
    static func prepareEstablish(establishData eD: [AnyHashable : Any], cid:String, sessionCid: String) -> [AnyHashable : Any] {
        
        var establishData = eD
        
        establishData["sessionCid"] = sessionCid
        establishData["metadata.cid"] = cid

        let deviceType = "\(establishData["deviceType"] ?? Constants.deviceType):\(Constants.devicePlatform)"
        establishData["deviceType"] = deviceType
        
        if let lang = establishData["metadata.lang"] as? String {
            establishData["lang"] = lang
        }
        
        establishData["metadata.sdkIOSVersion"] = Constants.buildSDK

        establishData["returnUrl"] = Constants.returnURL
        establishData["cancelUrl"] = Constants.cancelURL
        establishData["version"] = Constants.establishVersion
        establishData["grp"] = self.getGrp()

        if establishData["paymentProviderId"] != nil {
            establishData["widgetLoaded"] = "true"
        }
        
        return establishData
    }
    
    static func extractUrlSchemeFrom(_ establishData: [AnyHashable : Any]) -> String {
        
        if let scheme = establishData["metadata.urlScheme"] as? String {
            return scheme.components(separatedBy: ":")[0]
        }
        
        return ""
    }
    
    static func getGrp() -> String! {
        return getDefault(key: "Trustly.grp", def: generateGrp())
    }
    
    static func getDefault(key:String, def: String) -> String{
        let userDefaults:UserDefaults = UserDefaults.standard
        var value = userDefaults.object(forKey: key) as? String
        if(value == nil){
            value = def
            userDefaults.set(value,forKey: key)
            userDefaults.synchronize()
        }
        return value ?? ""
    }

    static func generateGrp() -> String! {
        var grp:String!
        let grpInt:Int = Int(arc4random_uniform(100))
        grp = String(format:"%d", grpInt)
        return grp
    }
}
