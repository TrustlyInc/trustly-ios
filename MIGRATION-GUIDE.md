# Trustly iOS SDK v3 to v4 Migration Guide for Merchant Teams

## Who This Guide Is For

This document is for merchant iOS engineers upgrading an existing Trustly v3 integration to v4.

It is written as an implementation guide, not a codebase analysis.

## What Changes for Your App

### High-impact changes

1. `TrustlyView`-centric integration is replaced by controller-based integration.
2. Flow callbacks move from per-call closures to `TrustlySDKProtocol` delegate methods.
3. Widget and Lightbox are now separate components:
   - `WidgetViewController`
   - `LightBoxViewController`

### What stays mostly the same

1. Import remains `import TrustlySDK`.
2. Core establish required keys remain unchanged.
3. URL scheme callback pattern is still required for URL-scheme deep linking.

---

## Migration at a Glance

### v3 to v4 API mapping

| v3 pattern | v4 pattern |
|---|---|
| `TrustlyView` embedded/instantiated in merchant UI | `WidgetViewController` + `LightBoxViewController` |
| `selectBankWidget(..., onBankSelected: closure)` | Implement `onBankSelected(data:)` in `TrustlySDKProtocol` |
| `establish(..., onReturn:, onCancel:)` | Present `LightBoxViewController` and handle `onReturn(_:)`, `onCancel(_:)` |
| `onChangeListener(closure)` on `TrustlyView` | Implement `onChangeListener(_: _:)` in `TrustlySDKProtocol` |
| App-defined bridge protocol from lightbox screen | SDK protocol (`TrustlySDKProtocol`) used directly |

---

## Step-by-Step Upgrade Plan

## 1. Update SDK dependency to v4

Use your standard dependency flow (CocoaPods/SPM) to pull v4 and run a clean build.

Keep this PR small: dependency update only.

## 2. Replace `TrustlyView` integration entry points

Find and remove v3 usage patterns:

```swift
trustlyView.selectBankWidget(...)
trustlyView.establish(...)
```

Replace with:

1. `WidgetViewController(establishData:)` where the user selects a bank.
2. `LightBoxViewController(establishData:)` when launching checkout.

## 3. Migrate callback handling to `TrustlySDKProtocol`

In your checkout host controller, conform to `TrustlySDKProtocol` and set delegates on both controllers.

Minimum callback handling:

1. `onBankSelected(data:)` -> persist selected bank payload and open lightbox.
2. `onReturn(_:)` -> dismiss lightbox and continue success flow.
3. `onCancel(_:)` -> dismiss lightbox and continue cancel/failure flow.
4. `onChangeListener(_: _:)` -> analytics/telemetry.

## 4. Verify establish data contract

Retain required fields your v3 flow already sends, including:

1. `accessId`
2. `merchantId`
3. `merchantReference`
4. `returnUrl`
5. `cancelUrl`
6. `requestSignature`
7. `customer.address.country`

v4 additions you may adopt (recommended when needed):

1. `metadata.deepLinkUrl`

Deep-link strategy rule (important):

1. `metadata.deepLinkUrl` and `metadata.urlScheme` are mutually exclusive.
2. Send only one of them for a given flow, never both.
3. Universal Links are new in v4 and require enablement/configuration on Trustly's side.
4. If you plan to use Universal Links, contact Trustly Support before rollout.

For local environment, ensure `envHost` is correctly populated.

## 5. Confirm Info.plist and deep link wiring

### Required

1. Keep `CFBundleURLTypes` configured with your scheme.
2. Keep AppDelegate URL open handling for scheme callback.

### Optional (if using universal links)

1. Add Associated Domains entitlement.
2. Implement `application(_:continue:restorationHandler:)` path handling.
3. Confirm Universal Links are enabled for your merchant configuration by Trustly Support.

## 6. Validate runtime behavior with an end-to-end test pass

Run at least one successful and one cancel/failure path test on real devices.

Use the validation matrix near the end of this guide.

---

## Before and After: Main Merchant Integration

### Before (v3 style)

```swift
import UIKit
import TrustlySDK

class CheckoutViewController: UIViewController {
    @IBOutlet weak var trustlyView: TrustlyView!
    var establishData: [AnyHashable: Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        trustlyView.onChangeListener { eventName, details in
            print(eventName, details)
        }

        let _ = trustlyView.selectBankWidget(establishData: establishData) { _, data in
            self.establishData = data
            self.openLightboxV3()
        }
    }

    private func openLightboxV3() {
        let vc = TrustlyLightBoxViewController()
        vc.establishData = establishData
        vc.delegate = self
        present(vc, animated: true)
    }
}
```

### After (v4 style)

```swift
import UIKit
import TrustlySDK

class CheckoutViewController: UIViewController, TrustlySDKProtocol {
    var establishData: [AnyHashable: Any] = [:]
    private var lightboxVC: LightBoxViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        let widgetVC = WidgetViewController(establishData: establishData)
        widgetVC.delegate = self

        addChild(widgetVC)
        view.addSubview(widgetVC.view)
        widgetVC.didMove(toParent: self)
    }

    func onBankSelected(data: [AnyHashable : Any]) {
        establishData = data

        lightboxVC = LightBoxViewController(establishData: establishData)
        lightboxVC?.delegate = self
        present(lightboxVC!, animated: true)
    }

    func onReturn(_ returnParameters: [AnyHashable : Any]) {
        lightboxVC?.dismiss(animated: true)
        // Continue success flow (receipt, order state update, analytics)
    }

    func onCancel(_ returnParameters: [AnyHashable : Any]) {
        lightboxVC?.dismiss(animated: true)
        // Continue cancel/failure flow (retry, fallback payment, telemetry)
    }

    func onChangeListener(_ eventName: String, _ eventDetails: [AnyHashable : Any]) {
        // Track event lifecycle
    }

    func onExternalUrl(onExternalUrl: TrustlyViewCallback?) {
        // Keep implementation for protocol conformance
    }
}
```

---

## Merchant Team Implementation Checklist

## Code migration

1. Remove `TrustlyView` outlets/properties from checkout screens.
2. Add `WidgetViewController` creation and embedding.
3. Add `LightBoxViewController` presentation logic.
4. Implement `TrustlySDKProtocol` in host controller.
5. Move closure logic into delegate methods.

## App configuration

1. Verify `CFBundleURLTypes` for your scheme.
2. Verify `application(_:open:options:)` behavior.
3. If applicable, configure Associated Domains and universal link handler.

## Establish payload

1. Keep required keys.
2. Validate `env` and `envHost` values per environment.
3. Validate deep-link keys and enforce mutual exclusivity: send either `metadata.urlScheme` or `metadata.deepLinkUrl`, not both.
4. If using `metadata.deepLinkUrl`, verify Trustly-side enablement with Support before production rollout.

## QA and release

1. Test happy path end-to-end.
2. Test user cancel path.
3. Test network interruption/retry behavior.
4. Test foreground/background transitions during checkout.
5. Test deep-link return on physical devices.

---

## Callback Handling Guidance for Merchant Apps

Use this callback ownership model:

1. `onBankSelected(data:)`
   - Save selected bank payload.
   - Add/refresh amount or dynamic fields.
   - Start lightbox.

2. `onReturn(_:)`
   - Close Trustly UI.
   - Mark checkout as completed in your app.
   - Trigger success analytics and server reconciliation.

3. `onCancel(_:)`
   - Close Trustly UI.
   - Preserve cart/session state.
   - Offer retry or alternative payment methods.

4. `onChangeListener(_: _:)`
   - Use for diagnostics and funnel metrics.

---

## Regression Test Matrix (Recommended)

| Scenario | Expected Result |
|---|---|
| Widget loads | Banks visible and selectable |
| Bank selected | `onBankSelected` called once with provider info |
| Lightbox success | `onReturn` called and checkout success flow runs |
| User cancel | `onCancel` called and fallback UX appears |
| URL-scheme return | App returns to foreground and flow continues |
| Universal link return | App receives user activity and flow continues |
| Background during OAuth | Flow resumes correctly without dead-end state |

---

## Rollout Strategy for Merchant Teams

1. Ship migration behind a feature flag when possible.
2. Enable in internal builds first.
3. Roll out to a small production cohort.
4. Monitor cancel rate, return success rate, and checkout conversion.
5. Expand rollout after stability and conversion are validated.

---

## Reference Files in This Workspace

### v3 integration examples

- [trustly-ios-v3/Example/TrustlySDK/ViewController.swift](trustly-ios-v3/Example/TrustlySDK/ViewController.swift)
- [trustly-ios-v3/Example/TrustlySDK/TrustlyLightBoxViewController.swift](trustly-ios-v3/Example/TrustlySDK/TrustlyLightBoxViewController.swift)
- [trustly-ios-v3/Example/TrustlySDK/AppDelegate.swift](trustly-ios-v3/Example/TrustlySDK/AppDelegate.swift)
- [trustly-ios-v3/Example/TrustlySDK/Info.plist](trustly-ios-v3/Example/TrustlySDK/Info.plist)

### v4 integration examples

- [trustly-ios-v4/Example/TrustlySDK/MerchantWidgetViewController.swift](trustly-ios-v4/Example/TrustlySDK/MerchantWidgetViewController.swift)
- [trustly-ios-v4/Example/TrustlySDK/MerchantLightBoxViewController.swift](trustly-ios-v4/Example/TrustlySDK/MerchantLightBoxViewController.swift)
- [trustly-ios-v4/Example/TrustlySDK/AppDelegate.swift](trustly-ios-v4/Example/TrustlySDK/AppDelegate.swift)
- [trustly-ios-v4/Example/TrustlySDK/Info.plist](trustly-ios-v4/Example/TrustlySDK/Info.plist)
- [trustly-ios-v4/Example/TrustlySDK_ExampleDebug.entitlements](trustly-ios-v4/Example/TrustlySDK_ExampleDebug.entitlements)

### SDK public API references

- [trustly-ios-v4/Sources/TrustlySDK/TrustlySDKProtocol.swift](trustly-ios-v4/Sources/TrustlySDK/TrustlySDKProtocol.swift)
- [trustly-ios-v4/Sources/TrustlySDK/Controller/WidgetViewController.swift](trustly-ios-v4/Sources/TrustlySDK/Controller/WidgetViewController.swift)
- [trustly-ios-v4/Sources/TrustlySDK/Controller/LightBoxViewController.swift](trustly-ios-v4/Sources/TrustlySDK/Controller/LightBoxViewController.swift)
