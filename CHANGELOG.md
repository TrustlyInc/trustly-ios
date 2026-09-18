# Changelog

All notable changes to TrustlySDK will be documented in this file.

## [4.3.2] - 2026-09-18

### Fixed

- **CocoaPods: PrivacyInfo.xcprivacy collision in apps with own privacy manifest**
  ([DEV-310246](https://trustly.atlassian.net/browse/DEV-310246))

  `TrustlySDK.podspec` previously used `s.resources` to distribute
  `PrivacyInfo.xcprivacy`. When TrustlySDK is integrated as a static library
  via CocoaPods, this caused the manifest to be copied flat into the consuming
  app's bundle root — colliding with any host app that already ships its own
  `PrivacyInfo.xcprivacy` (required for App Store submission since iOS 17.4+).
  The build error was:

  ```
  error: Multiple commands produce '…/ExampleAppUIKit.app/PrivacyInfo.xcprivacy'
  ```

  **Fix:** replaced `s.resources` with `s.resource_bundles` to package the SDK
  privacy manifest into a named bundle:

  ```ruby
  s.resource_bundles = { 'TrustlySDK_Privacy' => ['TrustlySDK/TrustlySDK/PrivacyInfo.xcprivacy'] }
  ```

  The manifest is now embedded as `TrustlySDK_Privacy.bundle/PrivacyInfo.xcprivacy`
  inside the built product, eliminating the flat-copy collision.

  **Affected versions:** 4.3.0, 4.3.1 (introduced by the source restructure in
  4.3.0). Versions 3.3.0 and earlier are not affected.

  **SPM consumers:** not affected — `Package.swift` uses `.copy(...)` scoped to
  the SDK target and is unchanged.

  **No breaking changes.** No Swift source files were modified; no public or
  internal API changes.
