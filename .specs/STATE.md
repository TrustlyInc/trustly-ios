# Project State

---

## Decisions

| ID | Decision | Status | Feature | Date |
|---|---|---|---|---|
| AD-001 | **Fastlane as authoritative test path** — lanes `lint`, `build_and_run_tests`, `verify_example_integrations` are invoked directly in the PR workflow before SonarQube. YAMLs should call `bundle exec fastlane <lane>` instead of raw shellscript or direct xcodebuild. | superseded by AD-004 | DEV-305935-ios-sdk-pr-quality-fastlane | 2026-08-10 |
| AD-004 | **All quality execution through Fastlane** — lint, test, coverage generation, SonarQube analysis, and Slack notifications all run inside Fastlane lanes. The YAML is a bootstrap layer only (checkout, Xcode setup, Ruby setup, brew installs, env vars). A single `ci_quality` lane orchestrates everything. `run-sonar-swift.sh` is retired. No quality logic lives in the YAML. | active | DEV-305935-ios-sdk-pr-quality-fastlane | 2026-08-18 |
| AD-002 | **Ruby managed via `ruby/setup-ruby`** — Ruby gems (including xcpretty) are managed via Gemfile + bundler-cache. No manual `gem install` in YAMLs. | active | DEV-305935-ios-sdk-pr-quality-fastlane | 2026-08-10 |
| AD-003 | **fi-connectors is not integrated with this project** — `trustly-ios` has no fi-connectors dependency. The `/delivery` command must push only to `trustly-ios` and must NOT create branches or push to `TrustlyInc/fi-connectors`. Any fi-connectors step in the delivery process is skipped entirely for this repository. | active | — | 2026-08-10 |

---

## Handoff

_No active handoff — no feature currently paused._
