//
//  BaseViewController.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 10/06/25.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    
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
    
    private func getWindow() -> UIWindow {
        guard let window = self.view.window else { fatalError("The view was not in the app's view hierarchy!") }
        return window
    }

    func showSuccessView(){
        let successViewController = SuccessViewController(nibName: "SuccessViewController", bundle: nil)

        self.getWindow().rootViewController = successViewController
    }

    func showFailureAlert(){
        self.showAlert(title: "Failure", message: "Failure when to try to process your payment. Try again later")
    }

}
