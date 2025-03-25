//
//  LightBoxViewController.swift
//  Pods
//
//  Created by Marcos Rivereto on 11/02/25.
//

import Foundation
import UIKit
@preconcurrency import WebKit

public class LightBoxViewController: UIViewController {
    
    public weak var delegate: TrustlySDKProtocol?
    
    private var mainWebView:WKWebView!
    private var webViewManager: WebViewManager?
    private let loading = UIActivityIndicatorView()
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initWebView()
        
        self.webViewManager?.onChangeListener { (eventName, attributes) in
            self.delegate?.onChangeListener(eventName, attributes)
        }
    }
    
    func initWebView() {

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

        self.view.addSubview(mainWebView)
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
    
    func showLightbox(data: Data?, url: URL?) {
        
        DispatchQueue.main.async {
            if let data = data, let url = url {
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
    public func establish(establishData eD: [AnyHashable : Any], onReturn: TrustlyViewCallback?, onCancel: TrustlyViewCallback?) {
        
        self.startLoading()

        self.webViewManager?.establishData = eD
        self.webViewManager?.returnHandler = onReturn
        self.webViewManager?.cancelHandler = onCancel
        
        let service = TrustlyService()
        service.delegate = self

        service.chooseIntegrationStrategy(establishData: eD, completionHandler: { integrationStrategy -> Void in

            if integrationStrategy == Constants.lightboxContentWebview {
                service.establishWebView(establishData: eD)

            } else {
                //TODO: oAuth
                print("oAuth")
            }
        })
    }
}

//extension Notification.Name{
//    @available(iOS 12.0, *)
//    static let trustlyCloseWebview = Notification.Name(TrustlyView.trustlyCloseWebview)
//}
