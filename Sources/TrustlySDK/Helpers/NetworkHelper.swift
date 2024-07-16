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
func buildEnvironment(function: String, environment: String, localUrl: String, paymentType: String, build: String) throws -> (url: URL, isLocal: Bool)  {
    var fn = function
    var subDomain = ""
    var urlString = ""

    if !environment.isEmpty {
        subDomain = String(format:"%@.", environment)
    }

    if  "index" == fn &&
        "Verification" != paymentType {
        fn = "selectBank"
    }
    
    if isLocalUrl(environment: environment) {
        let domain = localUrl.isEmpty ? "localhost" : localUrl
        urlString = "http://\(domain):8000/start/selectBank/\(fn)?v=\(build)-ios-sdk"

    } else if (environment == "dynamic") {
        urlString = "https://\(localUrl).int.trustly.one/start/selectBank/\(fn)?v=\(build)-ios-sdk"

    } else {
        urlString = "https://\(subDomain)paywithmybank.com/start/selectBank/\(fn)?v=\(build)-ios-sdk"
    }
    
    guard let url = URL(string: urlString) else {
        print("Invalid url: \(urlString)")
        throw NetworkError.invalidUrl
    }
        
    return (url: url, isLocal: isLocalUrl(environment: environment))
}

/** @abstract Validate if we are handling with local environment.
 @param environment: String
 @result Bool
 */
func isLocalUrl(environment: String) -> Bool {
    return !environment.isEmpty && "local" == environment
}
