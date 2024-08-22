//
//  APIRequest.swift
//  Pods
//
//  Created by Marcos Rivereto on 08/08/24.
//

import Foundation

enum TrustlyAddress: String {
    case trustlySettings = "settings"
}


struct APIRequest {
    
    private static func getUrl(address: String) -> String {
        return "https://\(Constants.baseDomain)/\(address)"
    }
    
    /** @abstract Returns all settings that sdk should considerer to run.
     @param address: TrustlyAddress
     @param completionHandler: @escaping(TrustlySettings?) -> Void
     */
    static func getTrustlySettingsWith(establish: [AnyHashable : Any], completionHandler: @escaping(TrustlySettings?) -> Void) {
// TODO: Uncomment these lines when the backend is ready
//        let session = URLSession.shared
//        
//        if let url = URL(string: self.getUrl(address: address.rawValue)) {
//            
//            let dataTask = session.dataTask(with: url) { (data, response, error) in
//                
//                // Check for errors
//                if let error = error {
//                    print("Error: \\(error)")
//                    return
//                }
//                
//                // Check if data is available
//                guard let responseData = data else {
//                    print("No data received")
//                    return
//                }
//                
//                // Process the received data
//                do {
//                    let settings = try JSONDecoder().decode(Settings.self, from: responseData)
//                    completionHandler(settings)
//                    
//                } catch {
//                    print("Error parsing JSON: \(error)")
//                }
//            }
//            
//            dataTask.resume()
//        }

// TODO: Delete all code bellow when the backend is ready
        sleep(4)
        let stringJson = """
                    {
                      "settings": {
                        "lightbox": {
                            "context": "in-app-browser"
                        }
                      }
                    }
        """
        print(stringJson)
        do {
            let data = Data(stringJson.utf8)
            let trustlySettings = try JSONDecoder().decode(TrustlySettings.self, from: data)
            completionHandler(trustlySettings)

        } catch {
            print("Error parsing JSON: \(error)")
        }
    }
}
