//
//  BaseViewController.swift
//  TrustlySDK_Example
//
//  Created by Marcos Rivereto on 28/04/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//


import UIKit
import TrustlySDK

class BaseViewController: UIViewController {
    
    // MARK: Helpers
    func getPassKeyManager() -> PassKeyManager {
        if let passKey = (UIApplication.shared.delegate as? AppDelegate)?.passKeyManager {
            return passKey
        }
        
        return PassKeyManager()
    }
    
    func getWindow() -> UIWindow {
        guard let window = self.view.window else { fatalError("The view was not in the app's view hierarchy!") }
        return window
    }
}
