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
}
