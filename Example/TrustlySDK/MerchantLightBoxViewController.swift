//
//  MerchantLightBoxViewController.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 10/06/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//


import Foundation
import TrustlySDK


class MerchantLightBoxViewController: BaseViewController {
    
    @IBOutlet weak var amountTextView: UITextField!
    var establishData:Dictionary<AnyHashable,Any> = [:]
    var lightboxViewController: LightBoxViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Lightbox
    @IBAction func openLightbox(_ sender: UIButton) {
        if let amountText = amountTextView.text,
           let amount = Double(amountText) {
            
            establishData["amount"] = String(format: "%.2f", amount)
        } else {
            establishData["amount"] = "0.00"
        }

        self.showLighbox()
    }
    
    // MARK: Lightbox
    private func showLighbox(){

        lightboxViewController = LightBoxViewController(establishData: establishData)
        lightboxViewController?.delegate = self

        self.present(lightboxViewController!, animated: true)
    }
}

extension MerchantLightBoxViewController: TrustlySDKProtocol {
    func onReturn(_ returnParameters: [AnyHashable : Any]) {
        lightboxViewController?.dismiss(animated: true)
        
        showSuccessView()

    }
    
    func onCancel(_ returnParameters: [AnyHashable : Any]) {
        lightboxViewController?.dismiss(animated: true)
        
        self.showFailureAlert()

    }
    
    func onBankSelected(data: [AnyHashable: Any]) {
        print("returnParameters:\(data)")
    }
    
    func onExternalUrl(onExternalUrl: TrustlyViewCallback?) {
        print("onExternalUrl")
    }
    
    func onChangeListener(_ eventName: String, _ eventDetails: [AnyHashable : Any]) {
        print("eventName: \(eventName), eventDetails: \(eventDetails)")
    }
}
