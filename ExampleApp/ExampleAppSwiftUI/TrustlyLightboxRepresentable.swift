//
//  TrustlyLightboxRepresentable.swift
//  ExampleAppSwiftUI
//

import SwiftUI
import TrustlySDK

struct TrustlyLightboxRepresentable: UIViewControllerRepresentable {

    let establishData: [AnyHashable: Any]
    weak var delegate: TrustlySDKProtocol?

    func makeUIViewController(context: Context) -> LightBoxViewController {
        let viewController = LightBoxViewController(establishData: establishData)
        viewController.delegate = delegate
        return viewController
    }

    func updateUIViewController(_ uiViewController: LightBoxViewController, context: Context) {}
}
