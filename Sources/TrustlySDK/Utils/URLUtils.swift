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
    
}
