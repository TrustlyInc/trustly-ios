//
//  NetworkHelper.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 16/07/24.
//

import Foundation
import os

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
func buildEnvironment(resourceUrl:ResourceUrls, env: String?, paymentType: String, build: String, path:PathUrls = .selectBank, query: [AnyHashable : Any]? = nil, hash: [AnyHashable : Any]? = nil) throws -> (url: URL, isLocal: Bool)  {
    let resource = resourceUrl
    let environment = TrustlyEnvironment(env: env)
    var urlComponents = environment.baseURL
    
    if environment.isLocal {
        let port = path == .selectBank ? Constants.portApi : Constants.portFrontend
        urlComponents.port = port
    }
    
    urlComponents.path = "/\(path.rawValue)/\(resource.rawValue)"

    // Build query items
    var queryItems: [URLQueryItem] = []
    
    if path == .selectBank {
        queryItems.append(URLQueryItem(name: "v", value: "\(build)-ios-sdk"))
        
        let lastUsed = getLastBankUsedFrom(country: query?["customer.address.country"] as? String ?? "")
        if !lastUsed.isEmpty {
            queryItems.append(URLQueryItem(name: "lastUsed", value: lastUsed))
        }
    }
    
    // Add custom query parameters
    if let query = query {
        for (key, value) in query {
            if let keyStr = key as? String, let valueStr = value as? String {
                let encodedKey = keyStr.urlEncodedForm()
                let encodedValue = valueStr.urlEncodedForm()
                queryItems.append(URLQueryItem(name: encodedKey, value: encodedValue))
            }
        }
    }
    
    urlComponents.percentEncodedQueryItems = queryItems.isEmpty ? nil : queryItems
    
    // Add fragment (hash)
    if let hash = hash {
        var fragmentItems: [URLQueryItem] = []
        for (key, value) in hash {
            if let keyStr = key as? String, let valueStr = value as? String {
                fragmentItems.append(URLQueryItem(name: keyStr, value: valueStr))
            }
        }
        urlComponents.fragment = fragmentItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
    }
    
    guard let url = urlComponents.url else {
        Logs.fault(log: Logs.networkHelper, message: "Failed to build URL with components")
        throw NetworkError.invalidUrl
    }
    
    return (url: url, isLocal: environment.isLocal)
}
