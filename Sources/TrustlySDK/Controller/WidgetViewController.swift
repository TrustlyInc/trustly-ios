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
import UIKit
@preconcurrency import WebKit


public class WidgetViewController: UIViewController {
    
    private var mainWebView:WKWebView!
    private var webViewManager: WebViewManager?
    
    public weak var delegate: TrustlySDKProtocol?
    
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
