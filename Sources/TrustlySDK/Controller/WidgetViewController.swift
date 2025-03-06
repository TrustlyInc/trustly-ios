//
//  WidgetViewController.swift
//  Pods-TrustlySDK_Example
//
//  Created by Marcos Rivereto on 31/01/25.
//

import Foundation
import UIKit
@preconcurrency import WebKit

public protocol WidgetViewControllerProtocol: AnyObject {
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


public class WidgetViewController: UIViewController {
    
    private let widgetView:Int = 100
    
    private var mainWebView:WKWebView!
    private var webViewManager: WebViewManager?
    
    public weak var delegate: WidgetViewControllerProtocol?
    
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
        mainWebView.tag = widgetView
        
        if #available(iOS 16.4, *) {
            mainWebView.isInspectable = true
        }

        self.view = self.mainWebView
    }
}

extension WidgetViewController {

    public func selectBankWidget(establishData: [AnyHashable : Any], onBankSelected: @escaping TrustlyViewCallback) {
        
        let service = TrustlyService()
        
        self.webViewManager?.establishData = establishData
        
        if let urlRequest = service.selectBankWidget(establishData: establishData) {
            self.mainWebView.load(urlRequest)
        }
        
        self.webViewManager?.bankSelectedHandler = onBankSelected

    }
}
