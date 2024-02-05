//
//  URLUtils.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 29/01/24.
//

import Foundation

enum TrustlyURLError: Error {
    case missingLocalUrl
}

struct URLUtils {
    
    static var isLocalEnvironment = false

    // MARK: Build url
    static func buildEndpointUrl(function:String, establishData:[String:String]) throws -> String {
        
        var httpProtocol = "https"
        var domain = Constants.baseDomain
        var resource = function
        
        
        if let environment = establishData["env"], !environment.isEmpty {
            
            if environment == "local" {
                isLocalEnvironment = true
                httpProtocol = "http"
                
                if let localUrl = establishData["localUrl"], !localUrl.isEmpty {
                    domain = localUrl
                    
                } else {
                    throw TrustlyURLError.missingLocalUrl
                }

            } else {
                isLocalEnvironment = false
                httpProtocol = "https"
                domain = "\(environment).\(domain)"
            }
        }
        
        if  "index" == resource &&
            "Verification" != establishData["paymentType"] &&
            establishData["paymentType"] != nil {
            resource = "selectBank"
        }
        

        return buildStringUrl(httpProtocol: httpProtocol, domain: domain, resource: resource, build: Constants.buildSDK)
    }

    private static func buildStringUrl(httpProtocol: String, domain: String, resource: String, build: String) -> String{
        return "\(httpProtocol)://\(domain)/start/selectBank/\(resource)?v=\(build)-ios-sdk"
    }
    
    
    // MARK: Encode url and parameters
    static func urlEncoded(_ data:[AnyHashable : Any?]) -> String! {
        var parts = [String]()
        for (key,value) in data {
            let part = String(format:"%@=%@", urlEncode(key)!, urlEncode(value)!)
            parts.append(part)
         }
        return parts.joined(separator: "&")
    }
    
    private static func urlEncode(_ object: Any?) -> String? {
        let str = toString(object)
        let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789-._~")

        return str?.addingPercentEncoding(withAllowedCharacters: set)
    }

    static func urlDecode(_ object: Any?) -> String? {
        let string = toString(object)

        return string?.removingPercentEncoding
    }
    
    private static func toString(_ object: Any?) -> String? {
        if let object = object {
            return "\(object)"
        }
        return nil
    }
    
}
