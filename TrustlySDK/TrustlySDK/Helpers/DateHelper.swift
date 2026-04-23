//
//  DateHelper.swift
//  Pods-TrustlySDK_Example
//
//  Created by Marcos Rivereto on 05/06/23.
//

import Foundation

extension Date {
    var millisecondsReferenceDate:Int {
        Int(self.timeIntervalSince1970 * 1000.0)
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000.0)
    }
}
