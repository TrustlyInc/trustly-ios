//
//  TrustlyService.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 18/02/25.
//

import Foundation


class TrustlyService {
    
    private var sessionCid = "ios wrong sessionCid"
    private var cid = "ios wrong cid"

    
    init () {
        if let tempCid = generateCid() {
            cid = tempCid
            sessionCid = getOrCreateSessionCid(cid)
        }
    }
    
    public func selectBankWidget(establishData eD: [AnyHashable : Any]) -> URLRequest? {
        
        var establishData = eD
        
        establishData["sessionCid"] = sessionCid
        establishData["metadata.cid"] = cid
        
        var query = [String : Any]()
        var hash = [String : Any]()
        
        let deviceType = establishData["deviceType"] ?? "mobile" + ":ios:native"
        query["deviceType"] = deviceType
        
        if let lang = establishData["metadata.lang"] as? String {
            query["lang"] = lang
        }

        query["onlinePPSubType"] = establishData["onlinePPSubType"]
        query["accessId"] = establishData["accessId"]
        query["merchantId"] = establishData["merchantId"]
        query["paymentType"] = establishData["paymentType"] ?? "Instant"
        query["deviceType"] = deviceType
        query["grp"] = EstablishDataUtils.getGrp()
        query["dynamicWidget"] = "true"
        query["sessionCid"] = establishData["sessionCid"]
        query["cid"] = establishData["metadata.cid"]
        
        if establishData["customer.address.country"] != nil {
            query["customer.address.country"] = establishData["customer.address.country"]
        }
        
        if (establishData["customer.address.country"] == nil || establishData["customer.address.country"] as! String == "us") &&
            establishData["customer.address.state"] != nil{
            query["customer.address.state"] = establishData["customer.address.state"]
        }
        
        hash["merchantReference"] = establishData["merchantReference"] ?? ""
        hash["customer.externalId"] = establishData["customer.externalId"] ?? ""

        do {
            let environment = try buildEnvironment(
                resourceUrl: .widget,
                environment: (establishData["env"] ?? "") as! String,
                localUrl: (establishData["envHost"] ?? "") as! String,
                paymentType: (establishData["paymentType"] ?? "") as! String,
                build: Constants.buildSDK,
                query: query,
                hash: hash
            )
            
            var request = URLRequest(url: environment.url)
            request.httpMethod = "GET"
            request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField:"Accept")
            
            return request
            
        } catch NetworkError.invalidUrl {
            print("Error: Invalid url.")
            
        } catch {
            print("Unexpected error: \(error).")
        }
        
        return nil
    }
    
}
