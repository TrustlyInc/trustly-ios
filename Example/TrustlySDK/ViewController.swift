//
//  ViewController.swift
//  TrustlySDK
//


import UIKit
import TrustlySDK

class ViewController: UIViewController {

    @IBOutlet weak var trustlyView: TrustlyView!
    @IBOutlet weak var amountTextView: UITextField!

    var alertObj:UIAlertController?
    var establishData:Dictionary<AnyHashable,Any> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.establishData = [
                                "accessId": "A48B73F694C4C8EE6306",
                                            "merchantId" : "110005514",
                                              "currency" : "USD",
                                              "amount" : "1.00",
                                              "merchantReference" : "cac73df7-52b4-47d7-89d3-9628d2cfb65e",
                                              "paymentType" : "Retrieval",
                                              "returnUrl": "/returnUrl",
                                              "cancelUrl": "/cancelUrl",
                                              "requestSignature": "HT5mVOqBXa8ZlvgX2USmPeLns5o=",
                                              "customer.name": "John",
                                              "customer.address.country": "US",
                                              "metadata.urlScheme": "demoapp://",
                                              "description": "First Data Mobile Test",
                                              "env": "int",
                                              "localUrl": "192.168.0.13"]

        
        self.trustlyView.onChangeListener { (eventName, attributes) in
            print("onChangeListener: \(eventName) \(attributes)")
        }

        let _ = self.trustlyView.selectBankWidget(establishData: establishData) { (view, data) in
            print("returnParameters:\(data)")
            self.establishData = data
            
            self.openLightbox()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func openLightbox(){
        if let amountText = amountTextView.text,
           let amount = Double(amountText) {
            
            establishData["amount"] = String(format: "%.2f", amount)
        } else {
            establishData["amount"] = "0.00"
        }
        
        let trustlyLightboxViewController = TrustlyLightBoxViewController()
        trustlyLightboxViewController.delegate = self
        
        trustlyLightboxViewController.establishData = self.establishData

        self.present(trustlyLightboxViewController, animated: true)
        
    }    
}

extension ViewController: TrustlyLightboxViewProtocol {
    
    func onReturnWithTransactionId(transactionId: String, controller: TrustlyLightBoxViewController) {
        controller.dismiss(animated: true)
        self.showSuccessView(transactionId: transactionId)
    }
    
    func onCancelWithTransactionId(transactionId: String, controller: TrustlyLightBoxViewController) {
        controller.dismiss(animated: true)
        self.showFailureAlert()
    }
    
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
