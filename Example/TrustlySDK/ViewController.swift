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
    var passKeyManager = PassKeyManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default
                          .addObserver(self,
                                       selector: #selector(loginSuccess(_:)),
                                       name: NSNotification.Name (super.getPassKeyManager().LOGIN_SUCCESS),                                           object: nil)
        
        self.establishData = ["accessId": "A48B73F694C4C8EE6306",
                              "merchantId" : "110005514",
                              "currency" : "USD",
                              "amount" : "1.00",
                              "merchantReference" : "g:cac73df7-52b4-47d7-89d3-9628d4cfb65e",
                              "paymentType" : "Retrieval",
                              "returnUrl": "/returnUrl",
                              "cancelUrl": "/cancelUrl",
                              "requestSignature": "HT5mVOqBXa8ZlvgX2USmPeLns5o=",
                              "customer.name": "John IOS",
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
            if(super.getPassKeyManager().isPasskeyOn()) {
                await super.getPassKeyManager().login( preferImmediatelyAvailableCredentials: true)
            }
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
        
        if let emailText = emailTextView.text, !emailText.isEmpty {

            establishData["customer.email"] = emailText

        }

        trustlyLightboxViewController.establishData = establishData

        self.present(trustlyLightboxViewController, animated: true)
        
    }
    
    // MARK: Helpers
    private func getWindow() -> UIWindow {
        guard let window = self.view.window else { fatalError("The view was not in the app's view hierarchy!") }
        return window
    }
    
    private func showPassKey(email: String?) {
        
        if let email = email {
            self.passKeyManager.signUpWith(email: email, anchor: self.getWindow())
        }
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
    
    @objc private func loginSuccess(_ notification: Notification){
        print("loginSuccess: \(notification.object)")
    }

}
