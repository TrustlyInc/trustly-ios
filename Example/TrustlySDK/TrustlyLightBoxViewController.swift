//
//  TrustlyLightBoxViewController.swift
//  TrustlySDK_Example
//
//  Created by Marcos Rivereto on 06/04/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
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
        
        let trustlyLightboxPanel = TrustlyView()
        
        if let establishData = self.establishData {
            self.view = trustlyLightboxPanel.establish(establishData: establishData,
                                                       onReturn: {(payWithMyBank, returnParameters)->Void in
                let response = returnParameters as! [String:String]
                self.delegate?.onReturnWithTransactionId(transactionId: response["transactionId"]!, controller: self)
                
            }, onCancel: {(payWithMyBank, returnParameters)->Void in
                let response = returnParameters as! [String:String]
                self.delegate?.onCancelWithTransactionId(transactionId: response["transactionId"]!, controller: self)
            })
            
        } else {
            self.delegate?.onCancelWithTransactionId(transactionId: "Empty establishData", controller: self)
        }
        
    }
}
