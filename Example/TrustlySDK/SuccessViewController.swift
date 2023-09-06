//
//  SuccessViewController.swift
//  TrustlySDK_Example
//
//  Created by Marcos Rivereto on 28/04/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class SuccessViewController: BaseViewController {
    
    var email: String?
    var transactionId: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default
                          .addObserver(self,
                                       selector: #selector(registrationSuccess(_:)),
                                       name: NSNotification.Name (super.getPassKeyManager().REGISTRATION_SUCCESS),                                           object: nil)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        
        if let email = email, !email.isEmpty {
            Task {
                let result = await super.getPassKeyManager().register(username: email, transactionId: transactionId ?? "")
                print(result)
            }
        }
    }
    
    @objc private func registrationSuccess(_ notification: Notification){
        print("registrationSuccess")
    }


    // MARK: - Actions
    
    @IBAction func newTransaction(_ sender: Any){
        self.view.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "MainViewController")
    }

}
