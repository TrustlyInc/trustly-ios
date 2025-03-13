//
//  LightBoxViewController.swift
//  Pods
//
//  Created by Marcos Rivereto on 11/02/25.
//

import Foundation
import UIKit
import WebKit

public protocol LightBoxViewControllerProtocol: AnyObject {
    /*!
        @brief Sets a callback to handle external URLs
        @param onExternalUrl Called when the TrustlySDK panel must open an external URL. If not handled an internal in app WebView will show the external URL.The external URL is sent on the returnParameters entry key “url”.
    */
    func onExternalUrl(onExternalUrl: TrustlyViewCallback?) -> Void;
    
    /*!
        @brief Sets a callback to handle event triggered by javascript
        @param eventName Name of the event.
        @param eventDetails Dictionary with information about the event.
    */
    func onChangeListener(_ eventName: String, _ eventDetails: [AnyHashable : Any]) -> Void;
}


public class LightBoxViewController: UIViewController {
    
    public weak var delegate: LightBoxViewControllerProtocol?
    
    private var mainWebView:WKWebView!
    private var webViewManager: WebViewManager?
    private let loading = UIActivityIndicatorView()

        
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initWebView()
        
        self.webViewManager?.onChangeListener { (eventName, attributes) in
            self.delegate?.onChangeListener(eventName, attributes)
            
            print("onChangeListener: \(eventName) \(attributes)")
        }
    
    }
    
    func initWebView() {
        
        let configuration = WKWebViewConfiguration()
        
        let frame = CGRect(x:0, y:0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        mainWebView = WKWebView(frame:frame, configuration:configuration)
        
        webViewManager = WebViewManager(webView: mainWebView)
        webViewManager?.notifyEvent(Constants.widgetPage, Constants.loadingType)
        
        let userController = WKUserContentController()
        
        if let webViewManager = webViewManager {
            userController.add(webViewManager, name: Constants.messageWebviewHandler)
        }
        
        configuration.userContentController = userController
        
        let wkPreferences = WKPreferences()
        wkPreferences.javaScriptCanOpenWindowsAutomatically = true
        
        configuration.preferences = wkPreferences

        mainWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainWebView.navigationDelegate = webViewManager
        mainWebView.uiDelegate = webViewManager
        mainWebView.scrollView.bounces = false
        mainWebView.backgroundColor = UIColor.clear
        mainWebView.isOpaque = false
        
        if #available(iOS 16.4, *) {
            mainWebView.isInspectable = true
        }

        self.view = self.mainWebView
    }
}

extension LightBoxViewController {
    
    public func establish(establishData: [AnyHashable : Any], onReturn: TrustlyViewCallback?, onCancel: TrustlyViewCallback?) {
        
        self.startLoading()
        
        let service = TrustlyService()
        service.delegate = self
        
        self.webViewManager?.establishData = establishData
        self.webViewManager?.cancelHandler = onCancel
        self.webViewManager?.returnHandler = onReturn
        
        service.chooseIntegrationStrategy(establishData: establishData, completionHandler: { integrationStrategy -> Void in
          
            if integrationStrategy == Constants.lightboxContentWebview {
                service.establishWebView(establishData: establishData)
                
            } else {
                //TODO: oAuth
                print("oAuth")
            }
        })
    }
    
    // MARK: Support functions
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

extension LightBoxViewController: LightboxProtocol {
    
    func showLightbox(data: Data?, url: URL?) {
        
        DispatchQueue.main.async {
            if let data = data, let url = url {
                self.mainWebView?.load(data, mimeType:"text/html", characterEncodingName:"UTF-8", baseURL: url)
            }
            
            self.stopLoading()
        }
    }
}
