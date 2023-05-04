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


    init(username: String){
        self.username = username
        self.attestationObject = nil
        self.clientDataJSON = nil
        self.credentialID = nil
        self.authenticatorData = nil
        self.signature = nil
        self.userID = nil
    }
    
    init(attestationObject: String, clientDataJSON: String, credentialID: String){
        self.attestationObject = attestationObject
        self.clientDataJSON = clientDataJSON
        self.credentialID = credentialID
        self.username = nil
        self.authenticatorData = nil
        self.signature = nil
        self.userID = nil
    }
    
    init(clientDataJSON: String, credentialID: String, authenticatorData: String, signature: String, userID: String){
        self.clientDataJSON = clientDataJSON
        self.credentialID = credentialID
        self.authenticatorData = authenticatorData
        self.signature = signature
        self.userID = userID
        self.username = nil
        self.attestationObject = nil
    }
    
}

struct User: Codable, Hashable {
    let id: String?
    let username: String?
    let name: String?
    let email: String?
    
}

struct RP: Codable, Hashable {
    let name: String?
    
}

struct PassKeyResult: Codable, Hashable {
    let status: String?
    let message: String?
    let challenge: String?
    let user: User?
    let rp: RP?
    
}


struct APIRequest {
    
    private static let BASE_URL = "https://9f37-2804-14d-1289-9843-ad9a-7d5c-21b7-24cd.ngrok-free.app/passkey"
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
    
//    func doRequest(address: String, httpMethod: String, token: String?) {
//        var request = URLRequest(url: URL(string: self.getUrl(address: address))!)
//
//        print(request)
//
//        //You can pass any required content types her
//        request.httpMethod = httpMethod
//
//        // Some bad practice hard coding tokens in the Controller code instead of keychain.
//        if let access_token = token {
//            //You endpoint is setup as OAUTH 2.0 and we are sending Bearer token in Authorization header
//            request.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
//
//        }
//ApiCli
//        let session = URLSession.shared
//
//        session.dataTask(with: request) { data, response, err in
//
//            do{
//
//                let JSON = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
//
//                let dataSet = (JSON.value(forKeyPath: "parentNode-childNode") as! NSArray).object(at: 0) as! NSDictionary
//
//                DispatchQueue.main.async {
//
//                    let Val = dataSet.value(forKey: "subChildNode")
//
//                    // This is specific to the graph UI that is used, and requires CGFloat type.
//
//                    //currentSteps is my graph UI.
//
////                    self.currentSteps.setValue(Val as! CGFloat, animateWithDuration: 1)
//
//                }
//
//            } catch {
//
//                print("json error: \(error)")
//
//            }
//
//        }.resume()
//
//    }
}
