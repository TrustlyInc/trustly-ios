//
//  Logger+Extension.swift
//  Pods
//
//  Created by Marcos Rivereto on 31/03/25.
//

import os


extension OSLog {
    
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = "TrustlySDK"

    /// All logs related to widget ViewController
    static let widgetVC = OSLog(subsystem: subsystem, category: Constants.categoryLogWidgetVC)

    /// All logs related to lightbox ViewController
    static let lightboxVC = OSLog(subsystem: subsystem, category: Constants.categoryLogLightboxVC)
    
    /// All logs related to lightbox ViewController
    static let deviceHelper = OSLog(subsystem: subsystem, category: Constants.categoryDeviceHelper)
    
    /// All logs related to lightbox ViewController
    static let networkHelper = OSLog(subsystem: subsystem, category: Constants.categoryNetworkHelper)

    /// All logs related to lightbox ViewController
    static let apiRequest = OSLog(subsystem: subsystem, category: Constants.categoryApiRequest)
    /// All logs related to WebViewManager
    static let webViewManager = OSLog(subsystem: subsystem, category: Constants.categoryLogLightboxVC)
    
    //Debug-level logs are intended for use in a development environment while actively debugging. This level will not show in device's logs.
    static func debug(log: OSLog, message: String) {
        os_log("%@", log: log, type:.debug, message)
    }

    //Use this log to capture information that may be helpful, but isn’t essential, for troubleshooting. This level will not show in device's logs.
    static func info(log: OSLog, message: String) {
        os_log("%@", log: log, type:.info, message)
    }
    
    //Error-level logs are intended for reporting critical errors and failures. This level will show in device's logs.
    static func error(log: OSLog, message: String) {
        os_log("%@", log: log, type:.error, message)
    }
    
    //Fault-level messages are intended for capturing system-level or multi-process errors only. This level will show in device's logs.
    static func fault(log: OSLog, message: String) {
        os_log("%@", log: log, type:.fault, message)
    }
}
