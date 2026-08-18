# DEV-305935 PR Quality Check — Fastlane, Ruby Setup & Slack — Context

**Gathered:** 2026-08-18 (revised — discuss session)
**Spec:** `.specs/features/DEV-305935-ios-sdk-pr-quality-fastlane/spec.md`
**Status:** Ready for design (revised scope — see decisions below)

---

## Feature Boundary

Modify `ios_quality_check.yml`, `Gemfile`, and `fastlane/Fastfile` to:

1. Add `ruby/setup-ruby@v1` (Ruby 3.4, bundler-cache) — already implemented ✅
2. Route ALL quality execution through Fastlane — a new `ci_quality` lane orchestrates lint → build_and_run_tests → verify_example_integrations → sonar_analysis
3. Move SonarQube configuration and analysis into a Fastlane lane (`sonar_analysis`) using the native `sonar()` action; `run-sonar-swift.sh` is retired
4. Coverage XML (`sonar-reports/generic-coverage.xml`) continues to be produced by `xccov-to-sonarqube-generic.sh`, called via `sh()` from inside the Fastlane lane
5. Add Slack notifications (success + failure) via Fastlane's native `slack()` action inside `ci_quality` — NOT via `slackapi/slack-github-action@v2` in the YAML
6. Maximize Fastlane coverage: only steps that genuinely cannot run inside Fastlane stay in the YAML

**Scope delta from original ticket:** The ticket said "keep run-sonar-swift.sh" — the user has decided to migrate the same sonar configuration into Fastlane's `sonar()` action instead. This supersedes that constraint. Slack moves from the YAML (`slackapi/slack-github-action@v2`) into the Fastfile (`slack()` action).

---

## Implementation Decisions

### Slack notifications — move to Fastlane (replaces YAML approach) ✅

- **Remove** the commented-out `slackapi/slack-github-action@v2` steps from the YAML entirely.
- **Add** Fastlane's native `slack()` action inside the Fastfile:
  - `after_all` block (or explicit call at the end of `ci_quality`) → success notification (`success: true`)
  - `error do |lane, exception|` block → failure notification (`success: false`)
- **Env var bridge:** The YAML step that calls `bundle exec fastlane ci_quality` passes GitHub context as env vars:
  ```yaml
  env:
    SLACK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
    GITHUB_REPOSITORY: ${{ github.repository }}
    GITHUB_ACTOR: ${{ github.actor }}
    GITHUB_RUN_ID: ${{ github.run_id }}
    GITHUB_SERVER_URL: ${{ github.server_url }}
  ```
  The Fastfile reads them via `ENV["..."]` to build the message payload.
- **Message content:** Same richness as the ticket's YAML — repo name, actor, run link — formatted via Fastlane's `payload:` parameter. Green (`success: true`) for pass, red (`success: false`) for failure.
- **Secret handling:** `SLACK_URL` env var is the Fastlane `slack()` action's required input. If it is absent/empty, the action fails with a clear error. Document as deploy prerequisite.

### New ci_quality lane ✅

- Introduce a **`ci_quality`** lane in the Fastfile that orchestrates the full CI run in order:
  ```
  lint → build_and_run_tests → verify_example_integrations → sonar_analysis
  ```
- The YAML runs one step: `bundle exec fastlane ci_quality`
- The `after_all` and `error` blocks at platform level (`:ios do`) handle Slack success/failure for this lane.
- Existing lanes (`lint`, `build_and_run_tests`, `verify_example_integrations`) are unchanged.

### SonarQube — migrate to Fastlane sonar() action ✅

- Retire `run-sonar-swift.sh` invocation from the YAML.
- Add a **`sonar_analysis`** lane in the Fastfile that:
  1. Runs `xccov-to-sonarqube-generic.sh` via `sh()` to produce `sonar-reports/generic-coverage.xml` from the `.xcresult` bundle
  2. Verifies `sonar-reports/generic-coverage.xml` exists and is non-empty — `UI.user_error!` if absent
  3. Calls Fastlane's `sonar()` action with the same parameters the YAML previously injected into `sonar-project.properties`:
     - `project_key`, `project_name`, `sonar_token`, `sonar_url`
     - PR decoration: `pull_request_key`, `pull_request_branch`, `pull_request_base` (via env vars from YAML)
     - `scm_revision` (via `GIT_REVISION` env var from YAML)
- **SonarQube configuration is preserved** — same project, same token, same PR decoration parameters. Only the delivery mechanism changes (Fastfile `sonar()` action instead of shell script + inline YAML injection).
- `sonar-project.properties` remains in the repo as a base config file; the `sonar()` action reads it and the lane overrides/appends PR-specific params programmatically.

### Coverage XML source — keep xccov-to-sonarqube-generic.sh ✅

- `xccov-to-sonarqube-generic.sh` is called via `sh()` inside the `sonar_analysis` lane.
- The `.xcresult` path must be discoverable by the lane (passed as env var or derived from the `scan` output path).
- Coverage XML format (`sonar-reports/generic-coverage.xml`) and SonarQube's `sonar.coverageReportPaths` config are unchanged.

### Steps remaining in the YAML (minimum necessary) ✅

| Step | Stays in YAML? | Reason |
|---|---|---|
| `actions/checkout` | ✅ Yes | Must be first; no Fastlane equivalent |
| `Get Git Revision` | ✅ Yes | Produces `GIT_REVISION` for `sonar.scm.revision`; YAML env var passed to Fastlane |
| `maxim-lobanov/setup-xcode` | ✅ Yes | GitHub Action; no Fastlane equivalent |
| `ruby/setup-ruby@v1` | ✅ Yes | GitHub Action; must run before Fastlane itself |
| `brew install swiftlint` | Move to Fastlane `sh()` if possible, else keep in YAML | Needed by `lint` lane |
| `brew install sonar-scanner` | Move to Fastlane `sh()` if possible, else keep in YAML | Needed by `sonar()` action |
| `Reset SonarScanner cache` | Move to Fastlane `sh()` inside `sonar_analysis` lane | Shell commands → `sh()` |
| `Update sonar properties` | Replaced by `sonar()` action parameters in the lane | No longer needed as YAML step |
| `Install Xcode dependencies` (`xcode-select`, `runFirstLaunch`) | Move to Fastlane `sh()` | Shell commands → `sh()` |
| `run-sonar-swift.sh` | ❌ Retired | Replaced by `sonar_analysis` lane |
| `Verify Coverage Report` | Moved into `sonar_analysis` lane | `UI.user_error!` if file absent |
| Slack notification steps (commented out) | ❌ Remove entirely | Replaced by `slack()` in Fastfile |
| `bundle exec fastlane ci_quality` | ✅ Single Fastlane step | Orchestrates everything |

**Design note:** For the brew installs, the YAML approach is acceptable if moving them to `sh()` adds friction. The decision of whether to put them inside a setup lane or keep them as pre-ci YAML steps is left to Design.

### SHA pin for ruby/setup-ruby (carried forward from original context) ✅

- Use tag `@v1` per ticket example (no SHA pin). Documented inconsistency with other actions — deferred cleanup.

---

## Agent's Discretion

- Whether `brew install swiftlint` and `brew install sonar-scanner` move into a Fastlane setup lane or remain as YAML steps
- Lane naming: `ci_quality` for the orchestration lane, `sonar_analysis` for SonarQube — unless Design proposes better names
- Visual organization of YAML steps (names, comments)
- YAML indentation and style consistent with the existing file
- Whether `after_all` / `error` blocks are platform-level or lane-level in the Fastfile

---

## Specific References

- Fastlane `slack()` action: reads `SLACK_URL` env var; supports `message:`, `success:`, `payload:`, `default_payloads:` — use `payload:` for repo/actor/run-link
- Fastlane `sonar()` action: wraps sonar-scanner binary; accepts `project_key`, `project_name`, `sonar_token`, `sonar_url`, and arbitrary `sonar_runner_args` for PR decoration params
- `error do |lane, exception|` block: platform-level error handler in Fastfile — fires for any unhandled exception in any lane
- `xccov-to-sonarqube-generic.sh` is already in the repo root and must remain; it is invoked via `sh()` inside `sonar_analysis`
- Context7 fastlane/docs confirms `slack()` action is production-ready and the pattern for CI success/failure notifications

---

## Deferred Ideas

- SHA pin for `ruby/setup-ruby@v1` (consistency with other actions) — not in this ticket
- Migration to Fastlane `slather` or `xcov` for coverage (user chose to keep `xccov-to-sonarqube-generic.sh`)
- Unification of `ios_quality_check.yml` and `ios_quality_check_main_branches.yml` — out of scope
- Replacing `xccov-to-sonarqube-generic.sh` with a native coverage tool — deferred
