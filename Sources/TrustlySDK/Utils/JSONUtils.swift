//
//  JSONUtils.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 08/02/24.
//

import Foundation

struct JSONUtils {
    
    static private func getJsonDataFrom(dicticionary: [String : Any]) -> Data? {
        
        do {

            let jsonData:Data = try JSONSerialization.data(withJSONObject: dicticionary)

            return jsonData
            
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    static func getJsonStringFrom(dicticionary: [String : Any]) -> String? {
        
        guard let jsonData = getJsonDataFrom(dicticionary: dicticionary) else { return nil }

        let jsonString:String = String(data: jsonData, encoding: .utf8)!
        
        return jsonString
            
    }
    
    static func getJsonBase64From(dicticionary: [String : Any]) -> String? {
        
        guard let jsonData = getJsonDataFrom(dicticionary: dicticionary) else { return nil }
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
