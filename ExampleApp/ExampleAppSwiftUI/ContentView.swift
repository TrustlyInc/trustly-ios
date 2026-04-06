//
//  ContentView.swift
//  ExampleApp
//
//  Created by Luiz Rath Alves on 02/04/26.
//

import SwiftUI

struct ContentView: View {

    @Environment(TrustlyViewModel.self) private var viewModel

    var body: some View {
        switch viewModel.appState {
        case .home:
            HomeView()
        case .lightboxContainer:
            NavigationStack {
                LightboxContainerView()
            }
        case .widgetContainer:
            NavigationStack {
                WidgetContainerView()
            }
        case .success(let email, let transactionId):
            SuccessView(email: email, transactionId: transactionId)
        }
    }
}

#Preview {
    ContentView()
        .environment(TrustlyViewModel())
}
