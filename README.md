# TrustlySDK

[![License](https://badgen.net/badge/license/MIT/blue?icon=swift)](https://cocoapods.org/pods/TrustlySDK)
[![Swift Version](https://badgen.net/badge/swift/5/orange?icon=swift)](https://cocoapods.org/pods/TrustlySDK)
[![Platform](https://badgen.net/badge/iOS/v12/green?icon=swift)](https://cocoapods.org/pods/TrustlySDK)
[![Cocoapods Version](https://badgen.net/badge/cocoapods/v1.12.0/blue?icon=swift)](https://cocoapods.org/pods/TrustlySDK)
[![Pod Version](https://badgen.net/badge/pod/v3.0.0/yellow?icon=swift)](https://cocoapods.org/pods/TrustlySDK)
[![Swift Package Maager](https://badgen.net/badge/spm/available/green?icon=swift)](https://cocoapods.org/pods/TrustlySDK)

## Example App
---
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
---
- iOS 12 or higher

## Installation
---
<details open>
<summary>Cocoapods</summary>
<br />

TrustlySDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TrustlySDK'
```

For development and test reasons, you can install the pod from a branch in github:
```ruby
pod 'TrustlySDK', :git => 'https://github.com/TrustlyInc/trustly-ios.git', :branch => '<BRANCH_NAME>'
```
</details>

<details open>
<summary>Swift Package Manager - SPM</summary>
<br />
TrustlySDK is available through [Swift Package Manager](https://cocoapods.org). To install
it, simply click on File -> Add packages -> Search or Enter Package URL, paste the github url about this package `https://github.com/TrustlyInc/trustly-ios.git`:

![Add package url](docs/images/swift_package_manager.png)

For production reason choose the `main` branch, but for test or validation choose the branch described in the [release version table](#versions).
</details>
<br />

## Usage

```swift
import TrustlySDK

class ViewController: UIViewController {

    ...

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
                              "metadata.urlScheme": "demoapp://",
                              "description": "First Data Mobile Test",
                              "env": "<[int, sandbox, local]>",
                              "localUrl": "<YOUR LOCAL URL WHEN `ENV` PROPERTY IS `LOCAL` (ex: https://192.168.0.30:8000)>"]
        
        self.trustlyView.onChangeListener { (eventName, attributes) in
            print("onChangeListener: \(eventName) \(attributes)")
        }

        self.trustlyView.selectBankWidget(establishData: establishData) { (view, data) in
            print("returnParameters:\(data)")
            self.establishData = data
        }

        self.view = trustlyLightboxPanel.establish(establishData: establishData,
                                                    onReturn: {(payWithMyBank, returnParameters)->Void in
            let response = returnParameters as! [String:String]
            //TODO: implement your success behavior here
            
        }, onCancel: {(payWithMyBank, returnParameters)->Void in
            let response = returnParameters as! [String:String]
            //TODO: implement your cancel or failure behavior here
        })

    }

    ...

}
```
<br />

## Versions
___

| VERSION   | DESCRIPTION   | BRANCH |
| :-------: | :-----------  | :----------- |
3.0.0     | Add cocoapods, and swift package manager support | *main*


<br />

## License
___

TrustlySDK is available under the MIT license. See the LICENSE file for more info.
