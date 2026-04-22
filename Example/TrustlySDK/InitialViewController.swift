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
            "accessId": "BananaPie012345",
            "merchantId" : "1196",
            "currency" : "USD",
            "amount" : "1.00",
            "merchantReference" : "3D51F3A42EFE499A",
            "paymentType" : "Retrieval",
            "returnUrl": "/returnUrl",
            "cancelUrl": "/cancelUrl",
            "requestSignature": "HT5mVOqBXa8ZlvgX2USmPeLns5o=",
            "customer.name": "John",
            "customer.address.country": "US",
//            "metadata.deepLinkStrategy": "<[url-scheme, deeplink-url]>",
            "metadata.deepLinkUrl": "https://alpha-merchant.tools.devent.trustly.one/start/oauth/app/",
            "metadata.urlScheme": "demoapp://",
            "description": "Globex Demo",
            "env": "sandbox",
            "envHost": "192.168.0.13:8000"
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
