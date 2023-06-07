//
//  DateHelper.swift
//  Pods-TrustlySDK_Example
//
//  Created by Marcos Rivereto on 05/06/23.
//

import Foundation

extension Date {
    var millisecondsReferenceDate:Int64 {
        Int64(self.timeIntervalSinceReferenceDate * 1000.0)
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSinceReferenceDate: TimeInterval(milliseconds) / 1000.0)
    }
}
