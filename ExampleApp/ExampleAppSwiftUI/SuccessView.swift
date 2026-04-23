//
//  SuccessView.swift
//  ExampleAppSwiftUI
//

import SwiftUI

struct SuccessView: View {

    @Environment(TrustlyViewModel.self) private var viewModel

    let email: String?
    let transactionId: String?

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundStyle(.green)

            VStack(spacing: 8) {
                Text("Payment Successful")
                    .font(.title)
                    .fontWeight(.bold)

                if let email {
                    Text(email)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                if let transactionId {
                    Text("Transaction ID: \(transactionId)")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

            Spacer()

            Button("New Transaction") {
                viewModel.appState = .home
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 40)
        }
        .padding()
    }
}

#Preview {
    SuccessView(email: "john@example.com", transactionId: "TXN123456")
        .environment(TrustlyViewModel())
}
