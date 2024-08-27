//
//  URLUtils.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 29/01/24.
//

import Foundation

enum ResourceUrls: String {
    case index = "index"
    case widget = "widget"
    case establish = "establish"
    case selectBank = "selectBank"
    case setup = "setup"
}

enum PathUrls: String {
    case selectBank = "start/selectBank"
    case mobile = "frontend/mobile"
}

struct URLUtils {
    
    /** @abstract Merge, format and encode all parameters.
     @param domain: String,
     @param subDomain: String
     @param path: String
     @param resource: String
     @param build: String
     @param isLocalUrl: Bool
     @param environment: String
     @result String
     */
    static func buildStringUrl(domain: String, subDomain: String, path:String, resource: String, isLocalUrl: Bool, environment: String) -> String {

        var urlString = ""
        
        if isLocalUrl {
            let localDomain = domain.isEmpty ? "localhost" : domain
            urlString = "http://\(localDomain):8000/\(path)/\(resource)"

        } else if (environment == "dynamic") {
            urlString = "https://\(domain).int.trustly.one/\(path)/\(resource)"

        } else {
            var urlSubdomain = ""
            
            if !subDomain.isEmpty {
                urlSubdomain = "\(subDomain)."
            }
            
            urlString = "https://\(urlSubdomain)paywithmybank.com/\(path)/\(resource)"
        }
                
        return "\(urlString)"
    }
    
    // MARK: Encode url and parameters
    /** @abstract Merge, format and encode all parameters.
     @param data:[AnyHashable : Any]
     @result String
     */
    static func urlEncoded(_ data:[AnyHashable : Any]) -> String {
        var parts = [String]()
        for (key,value) in data {
            let part = String(format:"%@=%@", urlEncode(key), urlEncode(value))
            parts.append(part)
         }
        return parts.joined(separator: "&")
    }
    
    /** @abstract Add all Percent encoding.
     @param object: Any
     @result String
     */
    private static func urlEncode(_ object: Any) -> String {
        guard let str = object as? String else { return "" }
        
        let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789-._~")

        return str.addingPercentEncoding(withAllowedCharacters: set) ?? ""
    }

    /** @abstract Remove all Percent encoding.
     @param object: Any
     @result String
     */
    static func urlDecode(_ object: Any) -> String {
        guard let str = object as? String else { return "" }

        return str.removingPercentEncoding ?? ""
    }
    
    /** @abstract Validate if we are handling with local environment.
     @param environment: String
     @result Bool
     */
    static func isLocalUrl(environment: String) -> Bool {
        return !environment.isEmpty && "local" == environment
    }
}
