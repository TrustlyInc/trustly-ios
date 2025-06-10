//
//  InitialViewController.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 10/06/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//


import UIKit
import TrustlySDK

class InitialViewController: UIViewController {

    var establishData:Dictionary<AnyHashable,Any> = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.establishData = [
            "accessId": "A48B73F694C4C8EE6306",
            "merchantId" : "110005514",
            "currency" : "USD",
            "amount" : "1.00",
            "merchantReference" : "cac73df7-52b4-47d7-89d3-9628d4cfb65e",
            "paymentType" : "Retrieval",
            "returnUrl": "/returnUrl",
            "cancelUrl": "/cancelUrl",
            "requestSignature": "HT5mVOqBXa8ZlvgX2USmPeLns5o=",
            "customer.name": "John",
            "customer.address.country": "US",
            "theme": "dark",
            "metadata.theme": "dark",
            "metadata.urlScheme": "demoapp://",
            "description": "First Data Mobile Test",
            "flowType": "",
            "env": "sandbox",
            "env”Host": "192.168.0.13:8000"
        ]

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "lightbox" {
            let destinationViewController = segue.destination as! MerchantLightBoxViewController
            destinationViewController.establishData = self.establishData
        }

        if segue.identifier == "widget" {
            let destinationViewController = segue.destination as! MerchantWidgetViewController
            destinationViewController.establishData = self.establishData
        }
    }

}
