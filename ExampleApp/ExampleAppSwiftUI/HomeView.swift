//
//  HomeView.swift
//  ExampleAppSwiftUI
//

import SwiftUI

struct HomeView: View {

    @Environment(TrustlyViewModel.self) private var viewModel

    @State private var accessId = "<ACCESS_ID>"
    @State private var merchantId = "<MERCHANT_ID>"
    @State private var merchantReference = "<MERCHANT_REFERENCE>"
    @State private var requestSignature = "<REQUEST_SIGNATURE>"
    @State private var amount = "1.00"
    @State private var currency = "USD"
    @State private var paymentType = "Retrieval"
    @State private var env = "<[int, sandbox, local]>"
    @State private var envHost = ""
    @State private var customerName = "John"
    @State private var customerCountry = "US"
    @State private var returnUrl = "/returnUrl"
    @State private var cancelUrl = "/cancelUrl"
    @State private var theme = "dark"
    @State private var urlScheme = "demoappSwiftUI://"
    @State private var deepLinkStrategy = "url-scheme"
    @State private var description = "First Data Mobile Test"

    var body: some View {
        NavigationStack {
            Form {
                Section("Credentials") {
                    LabeledContent("Access ID") {
                        TextField("Access ID", text: $accessId)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Merchant ID") {
                        TextField("Merchant ID", text: $merchantId)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Merchant Reference") {
                        TextField("Merchant Reference", text: $merchantReference)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Request Signature") {
                        TextField("Request Signature", text: $requestSignature)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Payment") {
                    LabeledContent("Amount") {
                        TextField("Amount", text: $amount)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                    LabeledContent("Currency") {
                        TextField("Currency", text: $currency)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Payment Type") {
                        TextField("Payment Type", text: $paymentType)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Description") {
                        TextField("Description", text: $description)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Return URL") {
                        TextField("Return URL", text: $returnUrl)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Cancel URL") {
                        TextField("Cancel URL", text: $cancelUrl)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Customer") {
                    LabeledContent("Name") {
                        TextField("Name", text: $customerName)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Country") {
                        TextField("Country", text: $customerCountry)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Environment") {
                    LabeledContent("Env") {
                        TextField("int / sandbox / local", text: $env)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Env Host") {
                        TextField("https://...", text: $envHost)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    LabeledContent("Theme") {
                        TextField("Theme", text: $theme)
                            .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("URL Scheme") {
                        TextField("URL Scheme", text: $urlScheme)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section {
                    Button("Open Lightbox") {
                        viewModel.establishData = buildEstablishData()
                        viewModel.appState = .lightboxContainer
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    Button("Open Widget") {
                        viewModel.establishData = buildEstablishData()
                        viewModel.appState = .widgetContainer
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Trustly SDK")
        }
    }

    private func buildEstablishData() -> [AnyHashable: Any] {
        var data: [AnyHashable: Any] = [
            "accessId": accessId,
            "merchantId": merchantId,
            "currency": currency,
            "amount": amount,
            "merchantReference": merchantReference,
            "paymentType": paymentType,
            "returnUrl": returnUrl,
            "cancelUrl": cancelUrl,
            "requestSignature": requestSignature,
            "customer.name": customerName,
            "customer.address.country": customerCountry,
            "theme": theme,
            "metadata.theme": theme,
            "metadata.deepLinkStrategy": deepLinkStrategy,
            "metadata.urlScheme": urlScheme,
            "description": description,
            "env": env
        ]
        if !envHost.isEmpty {
            data["envHost"] = envHost
        }
        return data
    }
}

#Preview {
    HomeView()
        .environment(TrustlyViewModel())
}
