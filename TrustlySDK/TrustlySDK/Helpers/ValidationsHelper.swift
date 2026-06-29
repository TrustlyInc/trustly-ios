//
//  ValidationsHelper.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 05/07/24.
//

import Foundation
import WebKit


class ValidationHelper {
    
    static let HTTP_400_STATUS_CODE = 4
    static let HTTP_500_STATUS_CODE = 5
    
    static func isErrorCodePage(matches: [NSTextCheckingResult], content: String) -> Bool {
        for match in matches {

            let value = (Int(content[Range(match.range,in: content)!]) ?? 0) / 100

            if value == HTTP_400_STATUS_CODE || value == HTTP_500_STATUS_CODE {
                return true
            }
        }
        
        return false
    }

    static func findMatchesForErrorCode(content: String) -> [NSTextCheckingResult] {
        guard let regex = try? NSRegularExpression(pattern: "[0-9]+", options:NSRegularExpression.Options.caseInsensitive) else { return []}
        
        let matches = regex.matches(in: content, options:[], range: NSMakeRange(0, content.count))
        
        return matches
    }
    
}
