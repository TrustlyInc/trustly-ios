//
//  TrustlyLightBoxViewController.swift
//  TrustlySDK_Example
//


import Foundation
import TrustlySDK

protocol TrustlyLightboxViewProtocol {
    func onReturnWithTransactionId(transactionId: String, controller: TrustlyLightBoxViewController)
    func onCancelWithTransactionId(transactionId: String, controller: TrustlyLightBoxViewController)
}

class TrustlyLightBoxViewController: UIViewController {
    
    var establishData:Dictionary<AnyHashable,Any>?
    var delegate: TrustlyLightboxViewProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()     
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let trustlyLightboxPanel = TrustlyView()
        
        if let establishData = self.establishData {
            self.view = trustlyLightboxPanel.establish(establishData: establishData,
                                                       onReturn: {(payWithMyBank, returnParameters)->Void in
                self.delegate?.onReturnWithTransactionId(transactionId: returnParameters["transactionId"] as! String, controller: self)
                
            }, onCancel: {(payWithMyBank, returnParameters)->Void in
                let response = returnParameters as! [String:String]
                self.delegate?.onCancelWithTransactionId(transactionId: response["transactionId"] ?? "No Transaction ID", controller: self)
            })
            
        } else {
            self.delegate?.onCancelWithTransactionId(transactionId: "Empty establishData", controller: self)
        }
    }
}
