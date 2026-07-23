//
//  String+Extension.swift
//  Pods
//
//  Created by Marcos Rivereto on 22/04/25.
//

import Foundation


extension String {

    func base64() -> String {
        
        guard let data = self.data(using: .utf8) else { return "" }

        let base64String = data.base64EncodedString()

        return base64String
    }
    
    func base64ToDictionary() -> [String: Any] {

        guard let data = Data(base64Encoded: self) else {
            Logs.debug(log: Logs.stringExtensions, message: "Error: Could not decode Base64 string to Data")
            return [:]
        }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            if let dictionary = jsonObject as? [String: Any] {
                return dictionary
            } else {
                Logs.debug(log: Logs.stringExtensions, message: "Error: JSON object is not a dictionary")
                return [:]
            }
        } catch {
            Logs.debug(log: Logs.stringExtensions, message: "Error: Could not deserialize Data to JSON object: \(error.localizedDescription)")
            return [:]
        }
    }
    
    func urlEncodedForm() -> String {
        // 1. Remove existing percent-encoding if the string was already encoded
        let rawString = self.removingPercentEncoding ?? self
        
        // 2. Strict allowed characters
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-_.*")
        
        // 3. Percent-encode non-alphanumeric characters
        let encoded = rawString.addingPercentEncoding(withAllowedCharacters: allowed) ?? rawString
        
        // 4. Convert spaces to '+'
        return encoded.replacingOccurrences(of: "%20", with: "+")
    }
    
}
