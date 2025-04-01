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


public class WidgetViewController: UIViewController {
    
    private var establishData: [AnyHashable : Any]?
    private var mainWebView:WKWebView!
    private var webViewManager: WebViewManager?
    
    public weak var delegate: TrustlySDKProtocol?
    
    public init(establishData: [AnyHashable : Any]){
        super.init(nibName: nil, bundle: nil)
        
        self.establishData = establishData
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initWebView()
        
        self.webViewManager?.onChangeListener { (eventName, attributes) in
            self.delegate?.onChangeListener(eventName, attributes)
        }
        
        self.selectBankWidget()
        AnalyticsHelper.sendMerchantDeviceInfo()
    }
    
    func initWebView() {
        
        OSLog.debug(log: .widgetVC, message: "Starting to build widget webview")

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

        OSLog.debug(log: .lightboxVC, message: "Adding widget webview into view")
        
        self.view.addSubview(mainWebView)
        
        OSLog.debug(log: .lightboxVC, message: "Finishing to build widget webview")

    }
}

extension WidgetViewController {

    private func selectBankWidget() {
        
        OSLog.debug(log: .widgetVC, message: "Call selectBankWidget with establishData: \(establishData)")
        
        if !EstablishDataUtils.establisDataIsValid(establishData: establishData) {
            
            OSLog.debug(log: .widgetVC, message: "EstablishData is invalid because are missing one of this fileds: \(establishData)")
            
            return
        }
        
        let service = TrustlyService()
        
        self.webViewManager?.establishData = establishData
        
        if let urlRequest = service.selectBankWidget(establishData: establishData) {
            
            OSLog.info(log: .widgetVC, message: "Loading widget url: \(urlRequest)")
            
            self.mainWebView.load(urlRequest)
        }
        
        self.webViewManager?.bankSelectedHandler = { establishData in
            self.delegate?.onBankSelected(data: establishData)
        }
    }
}
