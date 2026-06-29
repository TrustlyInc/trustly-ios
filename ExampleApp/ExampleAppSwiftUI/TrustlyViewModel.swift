//
//  TrustlyViewModel.swift
//  ExampleAppSwiftUI
//

import Foundation
import Observation
import TrustlySDK

enum AppState {
    case home
    case lightboxContainer
    case widgetContainer
    case success(email: String?, transactionId: String?)
}

@MainActor
@Observable
final class TrustlyViewModel: TrustlySDKProtocol {

    var appState: AppState = .home
    var isLightboxPresented: Bool = false
    var establishData: [AnyHashable: Any] = [:]

    // MARK: - TrustlySDKProtocol

    func onReturn(_ returnParameters: [AnyHashable: Any]) {
        isLightboxPresented = false
        let email = returnParameters["customer.email"] as? String
        let transactionId = returnParameters["transactionId"] as? String
        appState = .success(email: email, transactionId: transactionId)
    }

    func onCancel(_ returnParameters: [AnyHashable: Any]) {
        isLightboxPresented = false
    }

    func onBankSelected(data: [AnyHashable: Any]) {
        establishData = data
        isLightboxPresented = true
    }

    func onChangeListener(_ eventName: String, _ eventDetails: [AnyHashable: Any]) {
        print("[TrustlySDK] onChangeListener — event: \(eventName), details: \(eventDetails)")
    }

    func onExternalUrl(onExternalUrl: TrustlyViewCallback?) {
        print("[TrustlySDK] onExternalUrl")
    }
}
