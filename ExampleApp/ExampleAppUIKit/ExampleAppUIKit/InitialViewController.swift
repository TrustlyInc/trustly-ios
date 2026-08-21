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

                    "merchantId": "110005514",

                    "currency": "USD",

                    "amount": "0.00",

                    "merchantReference": "178429265014rnut&ˆ#$@!+Rtm20coisinha",

                    "paymentType": "Retrieval",

                    "customer.customerId": "1010888303",

                    "customer.externalId": "1010888303",

                    "customer.name": "John Smith",

                    "customer.address.address1": "105 Alternate2 Street",

                    "customer.address.city": "Beverly Hills",

                    "customer.address.state": "CA",

                    "customer.address.zip": "90210",

                    "customer.address.country": "US",

                    "customer.phone": "+1123456789",

                    "customer.email": "jsmith@email.com",

                    "customer.enrollDate": "1784043744000",

                    "customer.dateOfBirth": "2001-01-01",

                    "requestSignature": "J45h+F3GVJ8pONBeRnIIJIsVaLU=",

                    "metadata.deepLinkStrategy": "deeplink-url",

                    "metadata.deepLinkUrl": "https://trustly.one/trustly-alpha",

                    "returnUrl": "/returnUrl",

                    "cancelUrl": "/cancelUrl",

                    "env": "sandbox"]

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
