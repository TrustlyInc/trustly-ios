//
//  APIRequest.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 03/05/23.
//

import Foundation

struct APIPayload: Codable, Hashable {
    let username: String
}

struct User: Codable, Hashable {
    let id: Int?
    let username: String?
    let name: String?
    let email: String?
    
}

struct RP: Codable, Hashable {
    let name: String?
    
}

struct PassKeyResult: Codable, Hashable {
    let status: String?
    let challenge: String?
    let user: User?
    let rp: RP?
    
}


struct APIRequest {
    
    private static let BASE_URL = "https://ac1d-2804-14d-1289-9843-cdbc-54f9-9043-21e7.ngrok-free.app"
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
