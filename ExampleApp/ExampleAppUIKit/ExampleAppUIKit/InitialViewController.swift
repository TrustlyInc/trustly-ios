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
            "accessId": "TSwGyK52Mnpt5b8C",
            "merchantId" : "1127",
            "currency" : "USD",
            "amount" : "1.00",
            "merchantReference" : "SDK-01",
            "paymentType" : "Retrieval",
            "returnUrl": "/returnUrl",
            "cancelUrl": "/cancelUrl",
            // "requestSignature": "<REQUEST_SIGNATURE>",
            "customer.name": "John",
            "customer.address.country": "US",
            "theme": "dark",
            "metadata.theme": "dark",
            "metadata.deepLinkStrategy": "url-scheme",
            // "metadata.deepLinkUrl": "<custom deeplink url>",
            "metadata.urlScheme": "demoapp://",
            "description": "iOS SDK ExampleAppUIKit Test",
//            "metadata.flowType": "" // Uncomment and set a value in order to use a specific payment flow
            "env": "sandbox",
            // "envHost": "<YOUR LOCAL URL WHEN `ENV` PROPERTY IS `LOCAL` (ex: https://192.168.0.30)>"
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
