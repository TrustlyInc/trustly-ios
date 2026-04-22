//
//  MerchantWidgetViewController.swift
//  TrustlySDK_Example
//
//  Created by Marcos Rivereto on 28/01/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import TrustlySDK

class MerchantWidgetViewController: BaseViewController {
    
    @IBOutlet weak var amountTextView: UITextField!
    @IBOutlet weak var widgetView: UIView!
    var establishData: Dictionary<AnyHashable,Any> = [:]
    
    private var lightboxViewController: LightBoxViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let widgetVC = WidgetViewController(establishData: establishData)
        widgetVC.delegate = self

        widgetVC.view.frame.size = widgetView.frame.size
        widgetView.addSubview(widgetVC.view)
       
    }
    
    private func openLightbox(){
        if let amountText = amountTextView.text,
           let amount = Double(amountText) {
            
            establishData["amount"] = String(format: "%.2f", amount)
        } else {
            establishData["amount"] = "0.00"
        }
        
        lightboxViewController = LightBoxViewController(establishData: establishData)
        lightboxViewController?.delegate = self

        self.present(lightboxViewController!, animated: true)
    }
}

//MARK: WidgetProtocol
extension MerchantWidgetViewController: TrustlySDKProtocol {
    func onReturn(_ returnParameters: [AnyHashable : Any]) {
        lightboxViewController?.dismiss(animated: true)
        
        self.showSuccessView()

    }
    
    func onCancel(_ returnParameters: [AnyHashable : Any]) {
        lightboxViewController?.dismiss(animated: true)
        
        self.showFailureAlert()

    }
    
    func onBankSelected(data: [AnyHashable: Any]) {
        print("returnParameters:\(data)")
        self.establishData = data
        
        self.openLightbox()
    }
    
    func onExternalUrl(onExternalUrl: TrustlyViewCallback?) {
        print("onExternalUrl")
    }
    
    func onChangeListener(_ eventName: String, _ eventDetails: [AnyHashable : Any]) {
        print("eventName: \(eventName), eventDetails: \(eventDetails)")
    }
}
