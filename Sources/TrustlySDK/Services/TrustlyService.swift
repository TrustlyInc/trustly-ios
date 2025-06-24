//
//  TrustlyService.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 18/02/25.
//

import Foundation
import os

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
        
        let establishData = EstablishDataUtils.prepareEstablish(establishData: eD, cid: cid, sessionCid: sessionCid)
        
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
            Logs.error(log: Logs.trustlyService, message: "Error: Invalid url.")
            
        } catch {
            Logs.error(log: Logs.trustlyService, message: "Unexpected error: \(error).")

        }
        
        return nil
    }
    
    func establish(establishData eD: [AnyHashable : Any], settings: Settings) {
    
        let establishData = EstablishDataUtils.prepareEstablish(establishData: eD, cid: self.cid, sessionCid: self.sessionCid, inAppBrowser: settings.isInAppBrowserEnabled())
        
        do {
            let environment = try buildEnvironment(
                resourceUrl: .index,
                environment: (establishData["env"] ?? "") as! String,
                localUrl: (establishData["envHost"] ?? "") as! String,
                paymentType: (establishData["paymentType"] ?? "") as! String,
                build: Constants.buildSDK
            )

            loadLightbox(establish: establishData, url: environment.url, settings: settings) { (data, response, error) in
                
                if error == nil, let url = response?.url, let data = data {
                    if settings.isInAppBrowserEnabled() {
                        self.delegate?.showLightboxOAuth(url: url, urlScheme: EstablishDataUtils.extractUrlSchemeFrom(establishData))
                        
                    } else {
                        self.delegate?.showLightbox(data: data, url: url)
                    }
                }
            }
            
        } catch NetworkError.invalidUrl {
            Logs.error(log: Logs.trustlyService, message: "Error: Invalid url.")
            
        } catch {
            Logs.error(log: Logs.trustlyService, message: "Unexpected error: \(error).")
        }
        
    }
    
    public func chooseIntegrationStrategy(establishData: [AnyHashable : Any], completionHandler: @escaping(Settings) -> Void) {
        
        getTrustlySettingsWith(establish: establishData) { trustlySettings in
            if let settings = trustlySettings?.settings {
                completionHandler(settings)
            } else {
                completionHandler(Settings(integrationStrategy: Constants.lightboxContentWebview))
            }
        }
    }
}
