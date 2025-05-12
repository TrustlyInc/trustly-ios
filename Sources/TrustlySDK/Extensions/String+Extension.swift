//
//  String+Extension.swift
//  Pods
//
//  Created by Marcos Rivereto on 22/04/25.
//

import Foundation


extension String {

    func base64() -> String {
        
        guard let data = self.data(using: .utf8) else { return "" }

        let base64String = data.base64EncodedString()

        return base64String
    }
}
