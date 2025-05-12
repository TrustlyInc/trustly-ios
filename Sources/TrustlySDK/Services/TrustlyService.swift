//
//  TrustlyService.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 18/02/25.
//

import Foundation

protocol TrustlyServiceProtocol {
    func showLightbox(data: Data?, url: URL?)
    func showLightboxOAuth(url: URL, urlScheme: String)
}


class TrustlyService {
    
    private var sessionCid = "ios wrong sessionCid"
    private var cid = "ios wrong cid"
    
    public var delegate: TrustlyServiceProtocol?

    
    init () {
        if let tempCid = generateCid() {
            cid = tempCid
            sessionCid = getOrCreateSessionCid(cid)
        }
    }
    
    func selectBankWidget(establishData eD: [AnyHashable : Any]) -> URLRequest? {
        
        var establishData = eD
        
        establishData["sessionCid"] = sessionCid
        establishData["metadata.cid"] = cid
        
        let deviceType = establishData["deviceType"] ?? "mobile" + ":ios:native"
        establishData["deviceType"] = deviceType
        
        if let lang = establishData["metadata.lang"] as? String {
            establishData["lang"] = lang
        }

        establishData["grp"] = EstablishDataUtils.getGrp()
        establishData["dynamicWidget"] = "true"
        establishData["sessionCid"] = establishData["sessionCid"]
        establishData["cid"] = establishData["metadata.cid"]
        
        EstablishDataUtils.validateEstablishData(establishData: establishData)

        do {
            let environment = try buildEnvironment(
                resourceUrl: .widget,
                environment: (establishData["env"] ?? "") as! String,
                localUrl: (establishData["envHost"] ?? "") as! String,
                paymentType: (establishData["paymentType"] ?? "") as! String,
                build: Constants.buildSDK,
                query: establishData
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
    
    func establishWebView(establishData eD: [AnyHashable : Any]) {
        
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
    
    func establishASWebAuthentication(establishData eD: [AnyHashable : Any], onReturn: TrustlyViewCallback?, onCancel: TrustlyViewCallback?) {
        
        var establishData = eD
        
        guard let scheme = establishData["metadata.urlScheme"] as? String else {
            return
        }
        
        establishData["returnUrl"] = scheme
        establishData["cancelUrl"] = scheme
        
        do {
            let environment = try buildEnvironment(
                resourceUrl: .establish,
                environment: (establishData["env"] ?? "") as! String,
                localUrl: (establishData["envHost"] ?? "") as! String,
                paymentType: (establishData["paymentType"] ?? "") as! String,
                build: Constants.buildSDK,
                path: .mobile
            )
            
            var url = environment.url.absoluteString
            
            let normalizedEstablish:[String : AnyHashable] = EstablishDataUtils.normalizeEstablishWithDotNotation(establish: establishData as! [String : AnyHashable])
            
            if let token = JSONUtils.getJsonBase64From(dictionary: normalizedEstablish) {

                url = "\(url)?token=\(token)"
                let cleanScheme = scheme.components(separatedBy: ":")[0]
                
                self.delegate?.showLightboxOAuth(url: URL(string: url)!, urlScheme: cleanScheme)

            }
            
        } catch NetworkError.invalidUrl {
            print("Error: Invalid url.")
            
        } catch {
            print("Error: building url.")
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
