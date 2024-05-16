//
//  APIRequest.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 03/05/23.
//

import Foundation

struct APIPayload: Codable, Hashable {
    let username: String?
    let attestationObject: String?
    let clientDataJSON: String?
    let credentialID: String?
    let authenticatorData: String?
    let signature: String?
    let userID: String?
    let transactionId: String?
    let os: String?


    init(username: String, transactionId: String){
        self.username = username
        self.transactionId = transactionId
        self.attestationObject = nil
        self.clientDataJSON = nil
        self.credentialID = nil
        self.authenticatorData = nil
        self.signature = nil
        self.userID = nil
        self.os = "ios"
    }
    
    init(attestationObject: String, clientDataJSON: String, credentialID: String){
        self.attestationObject = attestationObject
        self.clientDataJSON = clientDataJSON
        self.credentialID = credentialID
        self.username = nil
        self.authenticatorData = nil
        self.signature = nil
        self.userID = nil
        self.transactionId = nil
        self.os = "ios"
    }
    
    init(clientDataJSON: String, credentialID: String, authenticatorData: String, signature: String, userID: String){
        self.clientDataJSON = clientDataJSON
        self.credentialID = credentialID
        self.authenticatorData = authenticatorData
        self.signature = signature
        self.userID = userID
        self.username = nil
        self.attestationObject = nil
        self.transactionId = nil
        self.os = "ios"
    }
    
}

public struct User: Codable, Hashable {
    public let id: String?
    public let username: String?
    public let name: String?
    public let email: String?
    public let lastTransactionAuth: String?
    
}

struct RP: Codable, Hashable {
    let name: String?
    
}

public struct PassKeyResult: Codable, Hashable {
    let status: String?
    let challenge: String?
    let message: String?
    
    let domain: String?
    public let user: User?
    
}


struct APIRequest {
    
    private static let BASE_URL = "https://alpha-merchant.tools.devent.trustly.one/passkey"
    static let CHALLENGE_ADDRESS = "challenge"
    static let REGISTER_ADDRESS = "register"
    static let FINISH_ADDRESS = "finish"
    
    
    private static func getUrl(address: String) -> String {
        return "\(BASE_URL)/\(address)"
    }
    
    static func doRequest(address: String, httpMethod: String, bodyData: APIPayload? = nil) async throws -> PassKeyResult? {
        
        var request = URLRequest(url: URL(string: self.getUrl(address: address))!)

        //You can pass any required content types her
        request.httpMethod = httpMethod
        
        if let body = bodyData {
            do {
                let jsonData = try JSONEncoder().encode(body)
                request.httpBody = jsonData
                
            } catch {
                print(error.localizedDescription)
            }
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        print(request)

        let session = URLSession.shared
        
        let (data, _) = try await session.data(for: request)
        
        let passKeyResult = try JSONDecoder().decode(PassKeyResult.self, from: data)
        
        return passKeyResult
    }
    
}
