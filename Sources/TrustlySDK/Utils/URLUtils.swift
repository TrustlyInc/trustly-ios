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

    static func buildEndpointUrl(function:String, establishData:[String:String]) throws -> String {
        
        var httpProtocol = "https"
        var domain = Constants.baseDomain
        var resource = function
        
        
        if let environment = establishData["env"], !environment.isEmpty {
            
            if environment == "local" {
                httpProtocol = "http"
                
                if let localUrl = establishData["localUrl"], !localUrl.isEmpty {
                    domain = localUrl
                    
                } else {
                    print("Error: When env is local, you must provide the localUrl.")
                    throw TrustlyURLError.missingLocalUrl
                }

            } else {
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
