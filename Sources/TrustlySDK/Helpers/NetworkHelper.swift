//
//  NetworkHelper.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 16/07/24.
//

import Foundation

enum NetworkError: Error {
    case invalidUrl
}


/** @abstract Get all informations to build the correct environment informations.
 @param function: String
 @param environment: String
 @param localUrl: String
 @param paymentType: String
 @param build: String
 @throws NetworkError.invalidUrl
 @result (url: URL, isLocal: Bool)
 */
func buildEnvironment(resourceUrl:ResourceUrls, environment: String, localUrl: String, paymentType: String, build: String, path:PathUrls = .selectBank, query: [AnyHashable : Any]? = nil) throws -> (url: URL, isLocal: Bool)  {
    var resource = resourceUrl
    var subDomain = ""
    var urlString = ""

    if !environment.isEmpty {
        subDomain = environment
    }
    
    switch resourceUrl {
    case .index:
        if paymentType != "Verification" {
            resource = .selectBank
        }
    default:
        break;
    }
    
    let isLocalUrl = URLUtils.isLocalUrl(environment: environment)
    
    urlString = URLUtils.buildStringUrl(
        domain: localUrl,
        subDomain: subDomain,
        path: path.rawValue,
        resource: resource.rawValue,
        isLocalUrl: isLocalUrl,
        environment: environment,
        port: path == .selectBank ? Constants.PORT_API : Constants.PORT_FRONTEND
    )
    
    if path == .selectBank {
        urlString = "\(urlString)?v=\(build)-ios-sdk"
    }
    
    if let query = query {
        let parameters = URLUtils.urlEncoded(query)
        
        urlString = "\(urlString)&\(parameters)#\(parameters.base64())"
    }
    
    guard let url = URL(string: urlString) else {
        print("Invalid url: \(urlString)")
        throw NetworkError.invalidUrl
    }
        
    return (url: url, isLocal: isLocalUrl)
}
