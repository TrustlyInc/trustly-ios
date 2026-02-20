//
//  TrustlyCommonsFunctions.swift
//  Pods
//
//  Created by Marcos Rivereto on 19/02/26.
//


func getTrustlyContext() -> String {
    return LocalStorage.getFrom(key: Constants.repositoryTrustlyContext, defaultValue: "")
}

func getGrp() -> String {
    return LocalStorage.getFrom(key: Constants.repositoryGRP, defaultValue: generateGrp())
}

func generateGrp() -> String {
    var grp:String!
    let grpInt:Int = Int(arc4random_uniform(100))
    grp = String(format:"%d", grpInt)
    return grp
}

func getLastBankUsedFrom(country: String) -> String {
    
    let trustlyContextBase64 = getTrustlyContext()
    
    if !trustlyContextBase64.isEmpty {
        let trustlyContext = trustlyContextBase64.base64ToDictionary()
        
        if let lastUsed = trustlyContext["lastUsed"] as? [String: String] {
            return lastUsed[country] ?? ""
        }
    }
    
    return ""
}
