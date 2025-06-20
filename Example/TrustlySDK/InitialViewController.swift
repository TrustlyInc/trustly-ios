//
//  InitialViewController.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 09/06/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import TrustlySDK

class InitialViewController: UIViewController {
    
    var establishData:Dictionary<AnyHashable,Any> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.establishData = [
            "accessId": "<ACCESS_ID>",
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
            "localUrl": "<YOUR LOCAL URL WHEN `ENV` PROPERTY IS `LOCAL` (ex: https://192.168.0.30:8000)>"
        ]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lightbox" {
            let destinationViewController = segue.destination as! TrustlyLightBoxViewController
            destinationViewController.establishData = self.establishData
        }
        
        if segue.identifier == "widget" {
            let destinationViewController = segue.destination as! ViewController
            destinationViewController.establishData = self.establishData
        }
    }

}
