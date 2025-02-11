//
//  WidgetViewController.swift
//  Pods-TrustlySDK_Example
//
//  Created by Marcos Rivereto on 31/01/25.
//

import Foundation
import UIKit

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
    
    public weak var delegate: WidgetViewControllerProtocol?
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

extension WidgetViewController {

    public func selectBankWidget(establishData: [AnyHashable : Any], onBankSelected: @escaping TrustlyViewCallback) {
        self.view = self.trustlyView.selectBankWidget(establishData: establishData) { data in
            print("returnParameters:\(data)")
            
            onBankSelected(data)

        }
    }
}
