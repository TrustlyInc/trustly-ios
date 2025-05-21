/*  ___________________________________________________________________________________________________________
 *
 *    TRUSTLY CONFIDENTIAL AND PROPRIETARY INFORMATION
 *  ___________________________________________________________________________________________________________
 *
 *      Copyright (c) 2012 - 2020 Trustly
 *      All Rights Reserved.
 *
 *   NOTICE:  All information contained herein is, and remains, the confidential and proprietary property of
 *   Trustly and its suppliers, if any. The intellectual and technical concepts contained herein are the
 *   confidential and proprietary property of Trustly and its suppliers and  may be covered by U.S. and
 *   Foreign Patents, patents in process, and are protected by trade secret or copyright law. Dissemination of
 *   this information or reproduction of this material is strictly forbidden unless prior written permission is
 *   obtained from Trustly.
 *   ___________________________________________________________________________________________________________
*/

import Foundation
import os
import UIKit
@preconcurrency import WebKit

public class LightBoxViewController: UIViewController {
    
    public weak var delegate: TrustlySDKProtocol?
    
    private var establishData: [AnyHashable: Any]?
    private var mainWebView:WKWebView!
    private var webViewManager: WebViewManager?
    private let loading = UIActivityIndicatorView()
    
    public init(establishData: [AnyHashable: Any]) {
        super.init(nibName: nil, bundle: nil)
        
        self.establishData = establishData
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initWebView()
        
        self.webViewManager?.onChangeListener { (eventName, attributes) in
            self.delegate?.onChangeListener(eventName, attributes)
        }
        
        if let establishData = self.establishData {
            self.establish(establishData: establishData)
        }
        AnalyticsHelper.sendMerchantDeviceInfo()
    }
    
    func initWebView() {
        
        Logs.debug(log: Logs.lightboxVC, message: "Starting to build lightbox webview")

        webViewManager = WebViewManager()
        
        let configuration = WKWebViewConfiguration()
        let userController = WKUserContentController()
        
        guard let webViewManager = self.webViewManager else { return }
        
        userController.add(webViewManager, name: Constants.messageWebviewHandler)
        configuration.userContentController = userController
        
        let wkPreferences = WKPreferences()
        wkPreferences.javaScriptCanOpenWindowsAutomatically = true
        
        configuration.preferences = wkPreferences

        let frame = CGRect(x:0, y:0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        mainWebView = WKWebView(frame:frame, configuration:configuration)
        mainWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainWebView.navigationDelegate = webViewManager
        mainWebView.uiDelegate = webViewManager
        mainWebView.scrollView.bounces = false
        mainWebView.backgroundColor = UIColor.clear
        mainWebView.isOpaque = false
        
        webViewManager.mainWebView = mainWebView
        
        if #available(iOS 16.4, *) {
            mainWebView.isInspectable = true
        }
        
        Logs.debug(log: Logs.lightboxVC, message: "Adding lightbox webview into view")
        
        self.view.addSubview(mainWebView)
        
        Logs.debug(log: Logs.lightboxVC, message: "Finishing to build lightbox webview")
    }
}

// MARK: Support functions
extension LightBoxViewController {
    
    private func startLoading() {
        self.loading.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        self.loading.center = self.view.center
        self.loading.hidesWhenStopped = true
        self.loading.color = .gray
        self.loading.hidesWhenStopped = true
        
        if #available(iOS 13.0, *) {
            self.loading.style = .large
        } else {
            self.loading.style = .gray
        }
        
        self.view.addSubview(self.loading)
        
        self.loading.startAnimating()
        self.loading.isHidden = false
    }
    
    private func stopLoading() {
        self.loading.stopAnimating()
        self.loading.isHidden = true
    }
}

// MARK: TrustlyService protocol
extension LightBoxViewController: TrustlyServiceProtocol {
    
    func showLightboxOAuth(url: URL, urlScheme: String) {
        self.webViewManager?.openOAuth(url: url, urlScheme: urlScheme)
    }
    
    
    func showLightbox(data: Data?, url: URL?) {
        
        DispatchQueue.main.async {
            if let data = data, let url = url {
                Logs.info(log: Logs.lightboxVC, message: "Loading lightbox url: \(url)")
                
                self.mainWebView.load(data, mimeType:"text/html", characterEncodingName:"UTF-8", baseURL: url)
            }
            self.stopLoading()
        }
            
    }
}


// MARK: Establish
extension LightBoxViewController {

    /** @abstract This function is responsible to open the lightbox, according to TrustlySettings service. If the context of the lightbox is `web view`, this function will
     return a UIView instance with a WebView embedded, in case the context valeu be `in-app-browser`, this function will return a empty UIView, andwill open the
     lightbox in an ASWebAuthentication instance.
     @param establishData eD: [AnyHashable : Any]
     @param onReturn: TrustlyViewCallback?
     @param onCancel: TrustlyViewCallback?
     */

    private func establish(establishData eD: [AnyHashable : Any]) {
        
        Logs.debug(log: Logs.lightboxVC, message: "Call establish with establishData: \(eD)")
        
        self.startLoading()

        self.webViewManager?.establishData = eD
        self.webViewManager?.returnHandler = self.onReturn(_:)
        self.webViewManager?.cancelHandler = self.onCancel(_:)
        
        let service = TrustlyService()
        service.delegate = self

        service.chooseIntegrationStrategy(establishData: eD, completionHandler: { integrationStrategy -> Void in

            if integrationStrategy == Constants.lightboxContentWebview {
                Logs.info(log: Logs.lightboxVC, message: "Calling lightbox in webview")
                service.establishWebView(establishData: eD)
                
            } else {
                Logs.info(log: Logs.lightboxVC, message: "Calling lightbox in ASWebAuthentication")
                service.establishASWebAuthentication(establishData: eD, onReturn: self.onReturn, onCancel: self.onCancel)
            }
        })
    }
    
    private func onReturn(_ returnParameters: [AnyHashable : Any]) -> Void{
        self.delegate?.onReturn(returnParameters)
    }
    
    private func onCancel(_ returnParameters: [AnyHashable : Any]) -> Void{
        self.delegate?.onCancel(returnParameters)
    }
}
