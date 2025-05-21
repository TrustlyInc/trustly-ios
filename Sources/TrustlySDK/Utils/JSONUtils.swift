//
//  JSONUtils.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 08/02/24.
//

import Foundation
import os

struct JSONUtils {
    
    static private func getJsonDataFrom(dictionary: [AnyHashable : Any]) -> Data? {
        
        do {

            let jsonData:Data = try JSONSerialization.data(withJSONObject: dictionary)

            return jsonData
            
        } catch {
            Logs.error(log: Logs.jsonUtils, message: "Error when try to get json from data: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    static private func getJsonStringFrom(dictionary: [String : AnyHashable]) -> String? {
        
        guard let jsonData = getJsonDataFrom(dictionary: dictionary) else { return nil }

        let jsonString:String = String(data: jsonData, encoding: .utf8)!
        
        return jsonString
            
    }
    
    static func getJsonBase64From(dictionary: [AnyHashable : Any]) -> String? {
        
        guard let jsonData = getJsonDataFrom(dictionary: dictionary) else { return nil }
        let jsonBase64 = jsonData.base64EncodedString()
        
        return jsonBase64
            
    }
    
    static func getDictionaryFrom(jsonStringBase64: String) -> [String : String]? {
        
        do {

            if let decodedData = Data(base64Encoded: jsonStringBase64) {
                let newDictionary = try JSONSerialization.jsonObject(with: decodedData, options: []) as? [String: String]
                
                return newDictionary
                
            } else {
                Logs.error(log: Logs.jsonUtils, message: "Not Base64")
            }
            
        } catch {
            Logs.error(log: Logs.jsonUtils, message: "Error when try to get dicitionary from json string base 64: \(error.localizedDescription)")
        }
        
        return nil
    }
}
