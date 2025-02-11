//
//  LightBoxViewController.swift
//  Pods
//
//  Created by Marcos Rivereto on 11/02/25.
//

import Foundation
import UIKit

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
    var trustlyView:TrustlyView = TrustlyView()
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .cyan
        
        self.trustlyView.onChangeListener { (eventName, attributes) in
            self.delegate?.onChangeListener(eventName, attributes)
            
            print("onChangeListener: \(eventName) \(attributes)")
        }
    
    }
}

extension LightBoxViewController {
    
    public func establish(establishData: [AnyHashable : Any], onReturn: TrustlyViewCallback?, onCancel: TrustlyViewCallback?) {
        self.view = trustlyView.establish(establishData: establishData,
                                                   onReturn: { returnParameters ->Void in
            print(returnParameters)
            onReturn?(returnParameters)

        }, onCancel: { returnParameters ->Void in
            print(returnParameters)
            onCancel?(returnParameters)
        })

    }
}
