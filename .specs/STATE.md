# Project State

---

## Decisions

| ID | Decision | Status | Feature | Date |
|---|---|---|---|---|
| AD-001 | **Fastlane as authoritative test path** — lanes `lint`, `build_and_run_tests`, `verify_example_integrations` are invoked directly in the PR workflow before SonarQube. YAMLs should call `bundle exec fastlane <lane>` instead of raw shellscript or direct xcodebuild. | active | DEV-305935-ios-sdk-pr-quality-fastlane | 2026-08-10 |
| AD-002 | **Ruby managed via `ruby/setup-ruby`** — Ruby gems (including xcpretty) are managed via Gemfile + bundler-cache. No manual `gem install` in YAMLs. | active | DEV-305935-ios-sdk-pr-quality-fastlane | 2026-08-10 |

---

## Handoff

_No active handoff — no feature currently paused._
