//
//  LightboxManager.swift
//  Pods
//
//  Created by Marcos Rivereto on 30/08/24.
//

import Foundation

/** @abstract Will call trustly core to render the lightbox.
 @param establish: [AnyHashable : Any]
 @param url: URL
 @param completionHandler: @escaping(Data?, URLResponse?, Error?) -> Void
 */
func loadLightbox(establish: [AnyHashable : Any], url: URL, completionHandler: @escaping(Data?, URLResponse?, Error?) -> Void) {
        
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField:"Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")

        let requestData = URLUtils.urlEncoded(establish).data(using: .utf8)

        request.setValue(String(format:"%lu", requestData!.count), forHTTPHeaderField:"Content-Length")
        request.httpBody = requestData
                
        URLSession.shared.dataTask(with: request) { (data, resp, err) in

            completionHandler(data, resp, err)
            
        }.resume()
    
}
