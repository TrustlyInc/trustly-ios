//
//  TrustlyLightBoxViewController.swift
//  TrustlySDK_Example
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.showLighbox()
    }
    
    private func showLighbox(){
        let trustlyLightboxPanel = TrustlyView()
        
        if let establishData = self.establishData {
            self.view = trustlyLightboxPanel.establish(establishData: establishData,
                                                       onReturn: {(payWithMyBank, returnParameters)->Void in
                print("Teste transactionId: \(returnParameters["transactionId"] as! String)")
                
                if let delegate = self.delegate {
                    delegate.onReturnWithTransactionId(transactionId: returnParameters["transactionId"] as! String, controller: self)
                    
                } else {
                    self.showSuccessView(transactionId: returnParameters["transactionId"] as! String)
                }
                
            }, onCancel: {(payWithMyBank, returnParameters)->Void in
                if let delegate = self.delegate {
                    let response = returnParameters as! [String:String]
                    delegate.onCancelWithTransactionId(transactionId: response["transactionId"] ?? "No Transaction ID", controller: self)
                    
                } else {
                    self.showLighbox()
                    self.showFailureAlert()
                }
            })
            
        } else {
            self.delegate?.onCancelWithTransactionId(transactionId: "Empty establishData", controller: self)
        }
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
        successViewController.email = self.establishData?["customer.email"] as? String
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
