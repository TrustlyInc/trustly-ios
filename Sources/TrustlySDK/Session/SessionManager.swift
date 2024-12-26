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
    
    guard let uuid = getFingerPrint(deviceUUID: getDeviceUUID()) else { return nil }
    guard let random = getRandomKey(randomUUID: UUID().uuidString) else { return nil }
    guard let timestampBase36 = getTimestampBase36(timeInMilliseconds: Date().millisecondsReferenceDate)  else { return nil }
    
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

func getFingerPrint(deviceUUID: String?) -> String? {
    guard let deviceUUID = deviceUUID else { return nil }
    
    return String(deviceUUID.split(separator: "-")[1])
}

func getRandomKey(randomUUID: String) -> String? {    
    return String(randomUUID.split(separator: "-")[2])
}

func getTimestampBase36(timeInMilliseconds: Int) -> String? {
    return String(timeInMilliseconds, radix: 36, uppercase: true)
}
