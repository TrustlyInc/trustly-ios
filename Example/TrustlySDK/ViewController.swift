//
//  ViewController.swift
//  TrustlySDK
//


import UIKit
import TrustlySDK

class ViewController: BaseViewController {

    @IBOutlet weak var trustlyView: TrustlyView!
    @IBOutlet weak var amountTextView: UITextField!
    @IBOutlet weak var emailTextView: UITextField!
    var enrollmentId: String?
    var alertObj:UIAlertController?
    var establishData:Dictionary<AnyHashable,Any> = [:]
    var trustlyPanel = TrustlyView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.establishData = ["accessId": "A48B73F694C4C8EE6306",
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
                              "metadata.urlScheme": "demoapp://",
                              "description": "First Data Mobile Test",
                              "env": "sandbox"]
        
        self.trustlyView.onChangeListener { (eventName, attributes) in
            print("onChangeListener: \(eventName) \(attributes)")
        }

        self.trustlyView.selectBankWidget(establishData: establishData) { (view, data) in
            print("returnParameters:\(data)")
            self.establishData = data
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        Task {
            await super.getPassKeyManager().login(presentationAnchor: super.getWindow(), preferImmediatelyAvailableCredentials: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - IBActions
    
    @IBAction func pay(_ sender: Any) {
        
        let trustlyLightboxViewController = TrustlyLightBoxViewController()
        trustlyLightboxViewController.delegate = self

        if let amountText = amountTextView.text,
           let amount = Double(amountText) {

            establishData["amount"] = String(format: "%.2f", amount)
        }

        if let emailText = emailTextView.text, !emailText.isEmpty {

            establishData["customer.email"] = emailText

        }

        trustlyLightboxViewController.establishData = establishData

        self.present(trustlyLightboxViewController, animated: true)
        
    }
    
}

extension ViewController: TrustlyLightboxViewProtocol {
    
    func onReturnWithTransactionId(transactionId: String, controller: TrustlyLightBoxViewController) {
        controller.dismiss(animated: true)
        self.showSuccessView()
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
    
    private func showSuccessView(){
        let successViewController = SuccessViewController(nibName: "SuccessViewController", bundle: nil)
        successViewController.email = self.establishData["customer.email"] as? String
        self.getWindow().rootViewController = successViewController
    }
    
    private func showFailureAlert(){
        self.showAlert(title: "Failure", message: "Failure when to try to process your payment. Try again later")
    }

}
