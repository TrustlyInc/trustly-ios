//
//  MerchantViewController.swift
//  TrustlySDK_Example
//
//  Created by Marcos Rivereto on 28/01/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import TrustlySDK

class MerchantViewController: UIViewController {
    
    @IBOutlet weak var amountTextView: UITextField!
    var establishData: Dictionary<AnyHashable,Any> = [:]
    
    private var lightboxViewController: LightBoxViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.establishData = ["accessId": "<ACCESS_ID>",
                              "merchantId" : "<MERCHANT_ID>",
                              "currency" : "USD",
                              "amount" : "1.00",
                              "merchantReference" : "<MERCHANT_REFERENCE>",
                              "paymentType" : "Retrieval",
                              "returnUrl": "/returnUrl",
                              "cancelUrl": "/cancelUrl",
                              "requestSignature": "<REQUEST_SIGNATURE>",
                              "customer.name": "John",
                              "customer.address.country": "US",
                              "theme": "dark",
                              "metadata.theme": "dark",
                              "metadata.urlScheme": "demoapp://",
                              "description": "First Data Mobile Test",
                              "env": "<[int, sandbox, local]>",
                              "localUrl": "<YOUR LOCAL URL WHEN `ENV` PROPERTY IS `LOCAL` (ex: https://192.168.0.30:8000)>"]
        
        let widgetVC = WidgetViewController(establishData: establishData)
        widgetVC.delegate = self

        widgetVC.view.frame = CGRect(x: 15, y: 170, width: 400, height: 500)
        view.addSubview(widgetVC.view)
       
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

extension MerchantViewController {
    
    // MARK: - Alert functions
    private func showAlert(title: String, message: String){
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
         })
        
        //Add OK button to a dialog message
        dialogMessage.addAction(ok)
        // Present Alert to
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    private func showSuccessView(transactionId: String){
        let successViewController = SuccessViewController(nibName: "SuccessViewController", bundle: nil)
        successViewController.email = self.establishData["customer.email"] as? String
        successViewController.transactionId = transactionId
        
        self.getWindow().rootViewController = successViewController
    }
    
    private func showFailureAlert(){
        self.showAlert(title: "Failure", message: "Failure when to try to process your payment. Try again later")
    }
    
    private func getWindow() -> UIWindow {
        guard let window = self.view.window else { fatalError("The view was not in the app's view hierarchy!") }
        return window
    }

}

//MARK: WidgetProtocol
extension MerchantViewController: TrustlySDKProtocol {
    func onReturn(_ returnParameters: [AnyHashable : Any]) {
        lightboxViewController?.dismiss(animated: true)
        
        self.showSuccessView(transactionId: returnParameters["transactionId"] as! String)

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
