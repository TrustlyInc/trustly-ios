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
func buildEnvironment(function: String, environment: String, localUrl: String, paymentType: String, build: String, query: [String : Any]? = nil, hash: [String : Any]? = nil) throws -> (url: URL, isLocal: Bool)  {
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
    
    if let query = query {
        urlString = "\(urlString)&\(urlEncoded(query))"
    }
    
    if let hash = hash {
        urlString = "\(urlString)#\(urlEncoded(hash))"
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

/** @abstract Merge, format and encode all parameters.
 @param data:[AnyHashable : Any]
 @result String
 */
func urlEncoded(_ data:[AnyHashable : Any]) -> String {
    var parts = [String]()
    for (key,value) in data {
        let part = String(format:"%@=%@", urlEncode(key), urlEncode(value))
        parts.append(part)
     }
    return parts.joined(separator: "&")
}

/** @abstract Remove all Percent encoding.
 @param object: Any
 @result String
 */
func urlDecode(_ object: Any) -> String {
    guard let str = object as? String else { return "" }

    return str.removingPercentEncoding ?? ""
}

/** @abstract Add all Percent encoding.
 @param object: Any
 @result String
 */
private func urlEncode(_ object: Any) -> String {
    guard let str = object as? String else { return "" }
    
    let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789-._~")

    return str.addingPercentEncoding(withAllowedCharacters: set) ?? ""
}
