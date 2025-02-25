//
//  Constants.swift
//  Pods-TrustlySDK_Example
//
//  Created by Marcos Rivereto on 29/01/24.
//

import Foundation


struct Constants {
    static let buildSDK = "3.3.0"
    static let baseDomain = "paywithmybank.com"
    
    static let RETURN_URL = "msg://return"
    static let CANCEL_URL = "msg://cancel"
    static let ESTABLISH_VERSION = "2"
    static let DEVICE_TYPE = "mobile"
    static let DEVICE_PLATFORM = "ios:native"
    static let PAYMENTTYPE_VERIFICATION = "Verification"
    
    static let LIGHTBOX_CONTEXT_INAPP = "in-app-browser"
    static let LIGHTBOX_CONTEXT_WEBVIEW = "webview"
    
    static let SETTINGS_CACHE_TIME_LIMIT = 15 // minutes
    
    static let PORT_API = "8000"
    static let PORT_FRONTEND = "10000"
    
    static let IN_APP_INTEGRATION_CONTEXT = "InAppBrowser"
    static let MESSAGE_WEBVIEW_HANDLER = "PayWithMyBankNativeSDK"
    
    static let WIDGET_PAGE = "widget"
    static let LOADING_TYPE = "loading"
    
}
