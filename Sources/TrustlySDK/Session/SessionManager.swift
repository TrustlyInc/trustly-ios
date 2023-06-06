//
//  SessionManager.swift
//  TrustlySDK
//
//  Created by Marcos Rivereto on 01/06/23.
//

import Foundation


struct SessionCid: Codable {
    static let EXPIRATION_TIME_LIMIT: Int = 1
    let sessionId: String
    let expirationTime: Date
    
    func isValid(expirationTimeLimit: Int) -> Bool {
        let dateNow = Date()
        
        let diffs = Calendar.current.dateComponents([.hour], from: expirationTime, to: dateNow)
        
        if let hours = diffs.hour {
            return hours < expirationTimeLimit
        }
        
        return false
    }
}

//MARK: - Main functions

/** @abstract Navigates to the requested file URL on the filesystem.
 @result A new cid.
 */
func generateCid() -> String? {
    
    guard let uuid = getFingerPrint() else { return nil }
    guard let random = getRandomKey() else { return nil }
    guard let timestampBase36 = getTimestampBase36()  else { return nil }
    
    return "\(uuid)-\(random)-\(timestampBase36)"
}


/** @abstract We will check if we have a valid sessionCid, if yes, we will return it, but, if not, we will save the cid as a sessionCid.
 @param _ cid: String
 @result the sessionCid.
 */
func getOrCreateSessionCid(_ cid: String) -> String {
    
    let savedSessionCid: SessionCid? = readDataFrom(keyStorage: .session_cid)
    
    if let sessionCid = savedSessionCid, sessionCid.isValid(expirationTimeLimit: SessionCid.EXPIRATION_TIME_LIMIT) {
        return sessionCid.sessionId
    }
    
    let newSessionCid = SessionCid(sessionId: cid, expirationTime: Date())
    saveData(newSessionCid, keyStorage: .session_cid)
    
    return cid
}


// MARK: - Private functions to help to generate CID

private func getFingerPrint() -> String? {
    guard let deviceUUID = getDeviceUUID() else { return nil }
    
    return String(deviceUUID.split(separator: "-")[1])
}

private func getRandomKey() -> String? {
    let randomUUID = UUID().uuidString
    
    return String(randomUUID.split(separator: "-")[1])
}

private func getTimestampBase36() -> String? {
    
    let timestampBase36 = Date().millisecondsSince1970

    return String(timestampBase36, radix: 36, uppercase: true)
}
