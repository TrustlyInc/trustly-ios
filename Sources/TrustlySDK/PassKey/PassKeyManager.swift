//
//  PassKeyManager.swift
//  Pods-TrustlySDK_Example
//
//  Created by Marcos Rivereto on 27/04/23.
//

import AuthenticationServices
import Foundation
import os


public class PassKeyManager: NSObject, ASAuthorizationControllerDelegate {
    
    public let LOGIN_SUCCESS = "com.user.login.success"
    public let REGISTRATION_SUCCESS = "com.user.registration.success"
//    var presentationAnchor: ASPresentationAnchor?
//    var isPerformingModalReqest = false
    
//    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return presentationAnchor!
//    }
    
    public func login(preferImmediatelyAvailableCredentials: Bool) async {
//        self.presentationAnchor = presentationAnchor
        
        do {
            let response = try await APIRequest.doRequest(address: APIRequest.CHALLENGE_ADDRESS, httpMethod: "GET")
            
            guard let result = response else {
                print("Login attempt failed")
                return
            }
            
            let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: result.domain ?? "")

            let challenge = Data(result.challenge!.utf8)

            let assertionRequest = publicKeyCredentialProvider.createCredentialAssertionRequest(challenge: challenge)

            let passwordCredentialProvider = ASAuthorizationPasswordProvider()
            let passwordRequest = passwordCredentialProvider.createRequest()

            let authController = ASAuthorizationController(authorizationRequests: [ assertionRequest, passwordRequest ] )
            authController.delegate = self
//            authController.presentationContextProvider = self
//            authController.performRequests()

            if preferImmediatelyAvailableCredentials {
                // If credentials are available, presents a modal sign-in sheet.
                // If there are no locally saved credentials, no UI appears and
                // the system passes ASAuthorizationError.Code.canceled to call
                // `PassKeyManager.authorizationController(controller:didCompleteWithError:)`.
                authController.performRequests(options: .preferImmediatelyAvailableCredentials)
            } else {
                // If credentials are available, presents a modal sign-in sheet.
                // If there are no locally saved credentials, the system presents a QR code to allow signing in with a
                // passkey from a nearby device.
                authController.performRequests()
            }

//            isPerformingModalReqest = true
            
//            let challenge = Data(result.challenge!.utf8)
//
//            let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: result.rp!.name!)
//            let assertionRequest = platformProvider.createCredentialAssertionRequest(challenge: challenge)
//            let authController = ASAuthorizationController(authorizationRequests: [assertionRequest])
//            authController.delegate = self
//            authController.presentationContextProvider = self
//            authController.performRequests()
            
        } catch {
            print("Request failed with error: \(error)")
        }
        

    }

    public func register(username: String, transactionId: String) async -> PassKeyResult? {
//        self.presentationAnchor = presentationAnchor
        let payload = APIPayload(username: username, transactionId: transactionId)
        
        
        do {
            let response = try await APIRequest.doRequest(address: APIRequest.REGISTER_ADDRESS, httpMethod: "POST", bodyData: payload)
            
            guard let result = response else {
               print("Register attempt failed")
               return nil
            }
                    
            let challenge = Data(result.challenge!.utf8)
            let username = result.user!.username!
            let userId = Data(String(result.user!.id!).utf8)
                    
            let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: result.domain ?? "")
                    
            let platformKeyRequest = platformProvider.createCredentialRegistrationRequest(challenge: challenge, name: username, userID: userId)
            let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
            authController.delegate = self
//            authController.presentationContextProvider = self
            authController.performRequests()
            
            return result
            
        } catch {
            print("Request failed with error: \(error)")
        }
        
        return nil
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
       print("Error AuthManager: \(error)")
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credentialRegistration as ASAuthorizationPlatformPublicKeyCredentialRegistration:
            Task {
                await finishRegistration(credentials: credentialRegistration)
            }
        case let assertionResponse as ASAuthorizationPlatformPublicKeyCredentialAssertion:
            Task {
                await finishLogin(credentials: assertionResponse)
            }
        default:
            print("Unknown authorization type received in callback")
        }
    }

    public func finishRegistration(credentials: ASAuthorizationPlatformPublicKeyCredentialRegistration) async {
        let attestationObject = credentials.rawAttestationObject!
        let clientDataJSON = credentials.rawClientDataJSON
        let credentialID = credentials.credentialID

        do {
            let payload = APIPayload(attestationObject: attestationObject.base64EncodedString(), clientDataJSON: clientDataJSON.base64EncodedString(), credentialID: credentialID.base64EncodedString())
            
            let response = try await APIRequest.doRequest(address: APIRequest.FINISH_ADDRESS, httpMethod: "POST", bodyData: payload)
            
            if let result = response {
                self.turnOnPasskey()

                NotificationCenter.default
                    .post(name: NSNotification.Name(REGISTRATION_SUCCESS),
                          object: result)
            }

        } catch {
            print("Error in finishRegistration")
        }
    }

    public func finishLogin(credentials: ASAuthorizationPlatformPublicKeyCredentialAssertion) async {
        let clientDataJSON = credentials.rawClientDataJSON
        let authenticatorData = credentials.rawAuthenticatorData!
        let credentialID = credentials.credentialID
        let signature = credentials.signature!
        let userID = String(data: credentials.userID!, encoding: String.Encoding.utf8)!


        do {
            let payload = APIPayload(
                clientDataJSON: clientDataJSON.base64EncodedString(),
                credentialID: credentialID.base64EncodedString(),
                authenticatorData: authenticatorData.base64EncodedString(),
                signature: signature.base64EncodedString(),
                userID: userID
            )
            
            let response = try await APIRequest.doRequest(address: APIRequest.FINISH_ADDRESS, httpMethod: "POST", bodyData: payload)
            
            if let result = response {
                self.turnOnPasskey()
                
                NotificationCenter.default
                    .post(name: NSNotification.Name(LOGIN_SUCCESS),
                          object: result)
            }

        } catch {
            print("Error in finishLogin")
        }
    }
    
    //MARK: User defaults
    let defaults = UserDefaults.standard
    let PASSKEY_FLAG = "PasskeyFlag"
    
    func turnOnPasskey() {
        defaults.set(true, forKey: PASSKEY_FLAG)
    }
    
    public func isPasskeyOn() -> Bool {
        defaults.bool(forKey: PASSKEY_FLAG)
    }
}
