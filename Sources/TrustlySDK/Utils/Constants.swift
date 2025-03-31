//
//  Constants.swift
//  Pods-TrustlySDK_Example
//
//  Created by Marcos Rivereto on 29/01/24.
//

import Foundation


struct Constants {
    static let buildSDK = "4.0.0"
    static let baseDomain = "paywithmybank.com"
    
    static let returnURL = "msg://return"
    static let cancelURL = "msg://cancel"
    static let establishVersion = "2"
    static let deviceType = "mobile"
    static let devicePlatform = "ios:native"
    static let paymentTypeVerification = "Verification"
    
    static let lightboxContentInApp = "in-app-browser"
    static let lightboxContentWebview = "webview"
    
    static let settingsCacheTimeLimit = 15 // minutes
    
    static let portApi = "8000"
    static let portFrontend = "10000"
    
    // MARK: Establish validation
    static let requiredKeys: Set<AnyHashable> = [AnyHashable("accessId"),
                                                 AnyHashable("merchantId"),
                                                 AnyHashable("merchantReference"),
                                                 AnyHashable("returnUrl"),
                                                 AnyHashable("cancelUrl"),
                                                 AnyHashable("requestSignature"),
                                                 AnyHashable("customer.address.country")]
    static let inAppIntegrationContext = "InAppBrowser"
    static let messageWebviewHandler = "PayWithMyBankNativeSDK"
    
    static let widgetPage = "widget"
    static let loadingType = "loading"
    
    static let undefinedURI = "/undefined"
    
    static let establishDataDocsLink = "https://amer.developers.trustly.com/payments/docs/establish-data#base-properties"

    static let trustlyCloseWebview = "trustly.close.webView"
    
    static let widgetView:Int = 100
    
    static let oauthLoginPath = "/oauth/login/"
    
    static let baseUrls = ["paywithmybank.com", "trustly.one"]
    
    // MARK: OsLog
    static let categoryLogWidgetVC = "widgetViewController"
    static let categoryLogLightboxVC = "lightboxViewController"
    static let categoryWebViewManager = "webViewManager"
    static let categoryNetworkHelper = "networkHelper"

}
