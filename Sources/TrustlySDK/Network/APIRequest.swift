//
//  APIRequest.swift
//  Pods
//
//  Created by Marcos Rivereto on 08/08/24.
//

import Foundation
import os

enum TrustlyAddress: String {
    case trustlySettings = "settings"
}


struct APIRequest {
    
    /** @abstract Returns all settings that sdk should considerer to run.
     @param url: String
     @param token: String
     @param completionHandler: @escaping(TrustlySettings?) -> Void
     */
    static func getTrustlySettingsWith(url: URL, token: String, completionHandler: @escaping(TrustlySettings?) -> Void) {

        let session = URLSession.shared
        
        if let url = URL(string: "\(url)?token=\(token)") {
            
            let dataTask = session.dataTask(with: url) { (data, response, error) in
                
                // Check for errors
                if let error = error {
                    Logs.error(log: Logs.apiRequest, message: "Error: \(error)")

                    return
                }
                
                // Check if data is available
                guard let responseData = data else {
                    Logs.info(log: Logs.apiRequest, message: "No data received")
                    
                    return
                }
                
                // Process the received data
                do {
                    let settings = try JSONDecoder().decode(TrustlySettings.self, from: responseData)
                    completionHandler(settings)
                    
                } catch {
                    Logs.error(log: Logs.apiRequest, message: "Error parsing JSON: \(error)")
                    
                    completionHandler(nil)
                }
            }
            
            dataTask.resume()
        }
    }
}
