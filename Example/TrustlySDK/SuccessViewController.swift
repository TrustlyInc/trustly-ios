//
//  SuccessViewController.swift
//  TrustlySDK_Example
//
//  Created by Marcos Rivereto on 28/04/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }



    // MARK: - Actions
    
    @IBAction func newTransaction(_ sender: Any){
        self.view.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "MainViewController")
    }

}
