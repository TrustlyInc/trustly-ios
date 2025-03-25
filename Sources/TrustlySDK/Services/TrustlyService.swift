//
//  TrustlyService.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 18/02/25.
//

import Foundation

protocol TrustlyServiceProtocol {
    func showLightbox(data: Data?, url: URL?)
}


class TrustlyService {
    
    private let CUSTOMER_ADDRESS_COUNTRY = "customer.address.country"
    private let CUSTOMER_ADDRESS_STATE = "customer.address.state"
    
    private var sessionCid = "ios wrong sessionCid"
    private var cid = "ios wrong cid"
    
    public var delegate: TrustlyServiceProtocol?

    
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
        
        if establishData[CUSTOMER_ADDRESS_COUNTRY] != nil {
            query[CUSTOMER_ADDRESS_COUNTRY] = establishData[CUSTOMER_ADDRESS_COUNTRY]
        }
        
        if (establishData[CUSTOMER_ADDRESS_COUNTRY] == nil || establishData[CUSTOMER_ADDRESS_COUNTRY] as! String == "us") &&
            establishData[CUSTOMER_ADDRESS_STATE] != nil{
            query[CUSTOMER_ADDRESS_STATE] = establishData[CUSTOMER_ADDRESS_STATE]
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
    
    public func establishWebView(establishData eD: [AnyHashable : Any]) {
        
        var establishData = EstablishDataUtils.prepareEstablish(establishData: eD, cid: cid, sessionCid: sessionCid)
        
        if establishData.index(forKey: "metadata.integrationContext") == nil {
            establishData["metadata.integrationContext"] = Constants.inAppIntegrationContext
        }
        
        do {
            let environment = try buildEnvironment(
                resourceUrl: .index,
                environment: (establishData["env"] ?? "") as! String,
                localUrl: (establishData["envHost"] ?? "") as! String,
                paymentType: (establishData["paymentType"] ?? "") as! String,
                build: Constants.buildSDK
            )

            loadLightbox(establish: establishData, url: environment.url) { (data, response, error) in
                
                if error == nil, let response = response {
                    self.delegate?.showLightbox(data: data, url: response.url)
                }
            }
            
        } catch NetworkError.invalidUrl {
            print("Error: Invalid url.")
            
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    
    public func chooseIntegrationStrategy(establishData: [AnyHashable : Any], completionHandler: @escaping(String) -> Void) {
        
        getTrustlySettingsWith(establish: establishData) { trustlySettings in

            if let settings = trustlySettings?.settings {
                completionHandler(settings.integrationStrategy)
                
            } else {
                completionHandler(Constants.lightboxContentWebview)
            }
        }
    }
}
