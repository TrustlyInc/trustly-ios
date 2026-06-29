//
//  ExampleAppApp.swift
//  ExampleApp
//
//  Created by Luiz Rath Alves on 02/04/26.
//

import SwiftUI
import TrustlySDK

@main
struct ExampleAppApp: App {

    @State private var viewModel = TrustlyViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
            guard url.scheme == "demoappSwiftUI://" else { return }
            NotificationCenter.default.post(name: .trustlyCloseWebview, object: nil)
        }
}
