//
//  JSONUtils.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 08/02/24.
//

import Foundation

struct JSONUtils {
    
    static private func getJsonDataFrom(dictionary: [String : AnyHashable]) -> Data? {
        
        do {

            let jsonData:Data = try JSONSerialization.data(withJSONObject: dictionary)

            return jsonData
            
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    static private func getJsonStringFrom(dictionary: [String : AnyHashable]) -> String? {
        
        guard let jsonData = getJsonDataFrom(dictionary: dictionary) else { return nil }

        let jsonString:String = String(data: jsonData, encoding: .utf8)!
        
        return jsonString
            
    }
    
    static func getJsonBase64From(dictionary: [String : AnyHashable]) -> String? {
        
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
                print("Not Base64")
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}
