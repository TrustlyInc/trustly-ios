# [iOS SDK] PR Quality Check — Fastlane, Ruby Setup & Slack Notifications

**Ticket:** DEV-305935  
**Branch:** DEV-305935-ios-sdk-refactor  
**Scope size:** Large

---

## Problem Statement

The `ios_quality_check.yml` workflow orchestrates PR quality analysis by directly invoking a legacy shell script (`run-sonar-swift.sh`) and native xcodebuild, bypassing Fastlane. This creates drift between what runs on CI and what developers can reproduce locally with `bundle exec fastlane`. Additionally, the Ruby runtime is not explicitly managed (no `ruby/setup-ruby`), making gem versions non-deterministic, and there are no real-time notifications to the team when a build passes or fails.

## Goals

- [ ] Replace direct invocation of `run-sonar-swift.sh` in the YAML with Fastlane lanes (`lint`, `build_and_run_tests`, `verify_example_integrations`)
- [ ] Configure the Ruby runtime with `ruby/setup-ruby@v1` (Ruby 3.4, `bundler-cache: true`), eliminating manual `gem install` from the YAML
- [ ] Preserve SonarQube analysis with unchanged PR metadata and decoration
- [ ] Notify Slack via `slackapi/slack-github-action@v2` on workflow success (green) and failure (red)
- [ ] Any Fastlane lane failure must halt the job immediately and trigger the failure notification
- [ ] The `sonar-reports/generic-coverage.xml` verification must fail the job if the file is absent

---

## Out of Scope

| Feature | Reason |
|---|---|
| Modifying `ios_quality_check_main_branches.yml` | Ticket specifies only `ios_quality_check.yml` |
| Modifying SonarQube server configuration | Explicitly out of scope in the ticket |
| Configuring or modifying Slack webhooks or channels | Out of scope — webhook is already configured as a secret |
| Major refactoring of Fastfile lanes unrelated to CI execution | Explicitly out of scope in the ticket |
| Removing or replacing `run-sonar-swift.sh` internally | Script remains; it is simply no longer invoked directly from the YAML |
| Modifying `check_tittle.yml` | Not related |
| Changing SonarQube token management | Out of scope |

---

## Assumptions & Open Questions

| # | Assumption / Decision | Chosen Default | Rationale | Confirmed? |
|---|---|---|---|---|
| A-01 | `ruby/setup-ruby@v1` replaces `sudo gem install xcpretty` and gem-related brew installs | Yes — `bundler-cache: true` installs everything from the Gemfile | fastlane, cocoapods and xcpretty are all in the Gemfile; bundler-cache installs them with pinned versions | ✅ confirmed |
| A-02 | The `Get Git Revision` step (required for `sonar.scm.revision`) stays in the YAML | Yes — kept as a YAML step | It is CI context logic, not quality logic; it does not belong in the Fastfile | ✅ confirmed |
| A-03 | `verify_example_integrations` is included in the PR workflow (ticket cites the lane in the AC) | Yes — AC-01 lists it explicitly | AC-01 states: "lint, build_and_run_tests, and verify_example_integrations execute as the authoritative test paths" | ✅ ticket confirms |
| A-04 | SonarQube property injection into `sonar-project.properties` stays as a YAML step | Yes — kept; ticket says "Keep SonarQube property injection" | Ticket explicitly states "Keep SonarQube property injection, scan, and coverage verification" | ✅ ticket confirms |
| A-05 | `run-sonar-swift.sh` is still invoked for SonarQube analysis (scan + sonar-scanner) | Yes — ticket says "Keep … scan, and coverage verification" | Ticket does not request migrating the script; it only requires Fastlane lanes as the "authoritative test path" | ✅ ticket confirms |
| A-06 | `SLACK_WEBHOOK_URL` already exists as a GitHub Secret in the repository | Yes — ticket assumes this (Risks/Assumptions section) | Explicit risk in ticket: "Assumption: The repository already contains a valid secret named secrets.SLACK_WEBHOOK_URL" | ❌ verify secret exists |
| A-07 | Slack notifications use `slackapi/slack-github-action@v2` with `incoming-webhook` | Yes — example YAML is verbatim in the ticket | Ticket provides the exact YAML | ✅ ticket confirms |
| A-08 | `brew install swiftlint` and `brew install sonar-scanner` stay; tailor and lizard are removed | Keep only what is actively used | swiftlint: used by `fastlane lint`; sonar-scanner: used by `run-sonar-swift.sh`; tailor/lizard: never activated | ✅ confirmed |
| A-09 | SHA pins for existing actions (`actions/checkout`, `maxim-lobanov/setup-xcode`) are preserved | Yes — no instruction to change them | Supply-chain security; unrelated to this scope | ✅ safe default |
| A-10 | `ruby/setup-ruby@v1` is added WITHOUT a SHA pin (as shown in the ticket example) | Use tag `@v1` per ticket | Ticket shows `uses: ruby/setup-ruby@v1` without a SHA | ✅ per user decision |

---

## User Stories

### P1: Configure Ruby runtime with ruby/setup-ruby ⭐ MVP

**User Story:** As an iOS developer, I want CI to configure the Ruby runtime via `ruby/setup-ruby@v1` with bundler cache, so that gems are installed with reproducible versions and setup time is reduced.

**Why P1:** Prerequisite for all other steps — `bundle exec fastlane` requires Ruby and gems to be correctly configured first.

**Acceptance Criteria:**

1. WHEN the `ios_quality_check.yml` workflow is inspected  
   THEN it SHALL contain a `ruby/setup-ruby@v1` step with `ruby-version: '3.4'` and `bundler-cache: true`
2. WHEN the `ruby/setup-ruby` step executes  
   THEN `bundle install` runs automatically and gems are cached
3. WHEN `ruby/setup-ruby` is present  
   THEN the workflow SHALL NOT contain `sudo gem install` for gems that are in the Gemfile

**Independent Test:** `grep "ruby/setup-ruby" .github/workflows/ios_quality_check.yml` returns 1 match with `ruby-version: '3.4'` and `bundler-cache: true`.

---

### P1: Add Fastlane lanes as authoritative test paths ⭐ MVP

**User Story:** As an iOS developer, I want CI to execute `lint`, `build_and_run_tests` and `verify_example_integrations` via `bundle exec fastlane` (as authoritative test paths), so that I can reproduce locally exactly what CI runs.

**Why P1:** Central requirement of the ticket — "Use Fastlane lanes for quality checks" as authoritative test paths.

**Acceptance Criteria:**

1. WHEN the workflow is inspected  
   THEN `ios_quality_check.yml` SHALL contain steps for `bundle exec fastlane lint`, `bundle exec fastlane build_and_run_tests` and `bundle exec fastlane verify_example_integrations`
2. WHEN any Fastlane lane returns a non-zero exit code  
   THEN the job SHALL fail immediately (no step has `continue-on-error: true`)
3. WHEN the Fastlane lanes fail  
   THEN downstream steps (SonarQube analysis) SHALL NOT execute

**Independent Test:** Inspect `ios_quality_check.yml` for the three `bundle exec fastlane` steps with no `continue-on-error`.

---

### P1: Preserve SonarQube analysis with PR metadata ⭐ MVP

**User Story:** As a quality engineer, I want the SonarQube analysis to keep working with PR decoration (`sonar.pullrequest.*`) unchanged after the refactor, so that quality feedback on PRs is not interrupted.

**Why P1:** The ticket explicitly states "Keep SonarQube property injection, scan, and coverage verification" — this is not optional.

**Acceptance Criteria:**

1. WHEN `ios_quality_check.yml` is inspected  
   THEN the SonarQube property injection step (`sonar.pullrequest.key`, `sonar.pullrequest.branch`, `sonar.pullrequest.base`, `sonar.scm.revision`) SHALL be present
2. WHEN the workflow executes and Fastlane lanes pass  
   THEN `run-sonar-swift.sh` (or equivalent) SHALL be invoked for SonarQube analysis
3. WHEN `sonar-reports/generic-coverage.xml` does not exist at the end of analysis  
   THEN the job SHALL fail with a clear error message ("Coverage report not found!")

**Independent Test:** Inspect `ios_quality_check.yml` — SonarQube property injection step present, coverage verification step present.

---

### P1: Slack success and failure notifications ⭐ MVP

**User Story:** As an iOS team member, I want to receive a Slack notification immediately when a PR passes or fails CI, so that mean-time-to-resolution (MTTR) for broken builds is reduced.

**Why P1:** Explicit ticket requirement — "notify Slack of outcomes" is part of the primary user story.

**Acceptance Criteria:**

1. WHEN the workflow completes successfully  
   THEN a `Notify Slack on success` step with `if: success()` SHALL execute and send a green message via `slackapi/slack-github-action@v2` with `webhook: ${{ secrets.SLACK_WEBHOOK_URL }}`
2. WHEN the workflow fails at any step  
   THEN a `Notify Slack on failure` step with `if: failure()` SHALL execute and send a red message via `slackapi/slack-github-action@v2`
3. WHEN the success notification is sent  
   THEN the payload SHALL contain: green indicator (`"color": "good"`), repository name, actor, and run link
4. WHEN the failure notification is sent  
   THEN the payload SHALL contain: red indicator (`"color": "danger"`), repository name, actor, and run link
5. WHEN `secrets.SLACK_WEBHOOK_URL` is not configured  
   THEN the step SHALL fail clearly without exposing tokens or environment variables in logs

**Independent Test:** `grep "slackapi/slack-github-action" .github/workflows/ios_quality_check.yml` returns 2 matches (success + failure), both with the correct `if:` condition.

---

## Edge Cases

- WHEN `sonar-reports/generic-coverage.xml` is absent when the verification step runs  
  THEN the `Verify Coverage Report` step SHALL `exit 1` with "Coverage report not found!"  
  AND the `Notify Slack on failure` step SHALL be triggered (`if: failure()`)

- WHEN `bundle exec fastlane lint` fails (SwiftLint violations)  
  THEN the job SHALL stop immediately (downstream steps do not execute)  
  AND `Notify Slack on failure` SHALL be triggered

- WHEN `bundle exec fastlane build_and_run_tests` fails (unit test failures)  
  THEN the job SHALL stop before `verify_example_integrations` and SonarQube  
  AND `Notify Slack on failure` SHALL be triggered

- WHEN `bundle exec fastlane verify_example_integrations` fails  
  THEN the job SHALL stop before SonarQube  
  AND `Notify Slack on failure` SHALL be triggered

---

## Requirement Traceability

| Requirement ID | Story | Phase | Status |
|---|---|---|---|
| PRQC-01 | P1: Ruby setup — ruby/setup-ruby@v1 step present | Design | ✅ Verified |
| PRQC-02 | P1: Ruby setup — ruby-version: '3.4' + bundler-cache: true | Design | ✅ Verified |
| PRQC-03 | P1: Ruby setup — no `sudo gem install` for Gemfile gems | Design | ✅ Verified |
| PRQC-04 | P1: Fastlane lanes — `bundle exec fastlane lint` in YAML | Design | ✅ Verified |
| PRQC-05 | P1: Fastlane lanes — `bundle exec fastlane build_and_run_tests` in YAML | Design | ✅ Verified |
| PRQC-06 | P1: Fastlane lanes — `bundle exec fastlane verify_example_integrations` in YAML | Design | ✅ Verified |
| PRQC-07 | P1: Fastlane lanes — no lane has `continue-on-error: true` | Design | ✅ Verified |
| PRQC-08 | P1: SonarQube — PR property injection preserved | Design | ✅ Verified |
| PRQC-09 | P1: SonarQube — run-sonar-swift.sh (or equivalent) still invoked | Design | ✅ Verified |
| PRQC-10 | P1: SonarQube — generic-coverage.xml verification fails the job if absent | Design | ✅ Verified |
| PRQC-11 | P1: Slack — `Notify Slack on success` step with `if: success()` | Design | ✅ Verified |
| PRQC-12 | P1: Slack — `Notify Slack on failure` step with `if: failure()` | Design | ✅ Verified |
| PRQC-13 | P1: Slack — success payload with color "good", repo, actor, run link | Design | ✅ Verified |
| PRQC-14 | P1: Slack — failure payload with color "danger", repo, actor, run link | Design | ✅ Verified |
| PRQC-15 | P1: Slack — clear failure when SLACK_WEBHOOK_URL is absent | Design | ✅ Verified |

**Coverage:** 15 requirements, 15 verified ✅

---

## Success Criteria

- [ ] `grep "ruby/setup-ruby" .github/workflows/ios_quality_check.yml` returns 1 match with `ruby-version: '3.4'` and `bundler-cache: true`
- [ ] `grep "bundle exec fastlane" .github/workflows/ios_quality_check.yml` returns 3 matches (lint, build_and_run_tests, verify_example_integrations)
- [ ] `grep "slackapi/slack-github-action" .github/workflows/ios_quality_check.yml` returns 2 matches
- [ ] `grep "if: success()" .github/workflows/ios_quality_check.yml` and `grep "if: failure()"` each return 1 match
- [ ] `grep "sonar.pullrequest.key" .github/workflows/ios_quality_check.yml` returns 1 match (SonarQube PR decoration preserved)
- [ ] CI passes on a test PR with a Slack success message delivered
- [ ] CI fails on a simulated failure run with a Slack failure message delivered
