# [iOS SDK] PR Quality Check — Fastlane, Ruby Setup & Slack — Tasks

## Execution Protocol (MANDATORY — do not skip)

Implement these tasks with the `tlc-spec-driven` skill. **Activate it by name and follow its Execute flow.**

---

**Design:** `.specs/features/DEV-305935-ios-sdk-pr-quality-fastlane/design.md`  
**Status:** Done ✅

---

## Test Coverage Matrix

> Guidelines found: **none** — strong defaults applied, scoped to the CI-config domain.
>
> **Domain note:** All deliverables are CI configuration files (YAML, Ruby Gemfile). "Tests" = static structural verifications: grep/inspect assertions against the spec ACs. The build gate is `ruby -c` for the Gemfile and YAML parse.

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
|---|---|---|---|---|
| GitHub Actions YAML | static | Every AC verified by grep/inspect; YAML parses without error | `.github/workflows/ios_quality_check.yml` | `ruby -e "require 'yaml'; YAML.safe_load(File.read('<file>'))"` |
| Gemfile (Ruby) | static | `gem 'xcpretty'` present; Ruby syntax valid | `Gemfile` | `ruby -c Gemfile` |

## Gate Check Commands

| Gate Level | When to Use | Command |
|---|---|---|
| Quick | After a single task | `ruby -e "require 'yaml'; YAML.safe_load(File.read('.github/workflows/ios_quality_check.yml'))"` + grep assertions for that task |
| Build | After the last task | Quick + `ruby -c Gemfile` + full grep suite for all PRQC-* requirements |

---

## Execution Plan

```
T01 → T02 → T03 → T04 → T05
```

- **T01** — Add `gem 'xcpretty'` to Gemfile
- **T02** — Add `Set up Ruby` step to workflow
- **T03** — Modify `Install dependencies` step (remove tailor, lizard, gem install)
- **T04** — Add 3 `bundle exec fastlane` steps to workflow (before SonarQube)
- **T05** — Add 2 Slack notification steps to workflow

**Total: 5 tasks — single inline batch, no sub-agents.**

---

## Task Breakdown

### T01: Add `gem 'xcpretty'` to Gemfile ✅

**What:** Add xcpretty to the Gemfile so that `bundler-cache: true` installs it automatically  
**Where:** `Gemfile`  
**Depends on:** None  
**Reuses:** Existing Gemfile pattern  
**Requirement:** PRQC-03  
**Commit:** `b80a5a9`

**Done when:**
- [x] `grep "xcpretty" Gemfile` returns 1 match with `gem "xcpretty"`
- [x] `ruby -c Gemfile` exits 0 (valid syntax)
- [x] `xcpretty` is positioned after `gem 'fastlane'`

**Tests:** static | **Gate:** quick

---

### T02: Add `Set up Ruby` step to `ios_quality_check.yml` ✅

**What:** Insert the `ruby/setup-ruby@v1` step with Ruby 3.4 and bundler-cache after `Setup Xcode`  
**Where:** `.github/workflows/ios_quality_check.yml`  
**Depends on:** T01  
**Reuses:** Verbatim YAML from the ticket  
**Requirement:** PRQC-01, PRQC-02  
**Commit:** `59742eb`

**Done when:**
- [x] YAML parses without error
- [x] `grep "ruby/setup-ruby" .github/workflows/ios_quality_check.yml` returns 1 match
- [x] `grep "ruby-version: '3.4'" ...` returns 1 match
- [x] `grep "bundler-cache: true" ...` returns 1 match
- [x] Step is positioned after `Setup Xcode` and before `Install dependencies`

**Tests:** static | **Gate:** quick

---

### T03: Modify `Install dependencies` step in `ios_quality_check.yml` ✅

**What:** Remove `brew install tailor`, `brew install lizard` and `sudo gem install xcpretty`; keep swiftlint and xcode-select  
**Where:** `.github/workflows/ios_quality_check.yml` (step lines 46-59)  
**Depends on:** T02  
**Reuses:** Existing step content — surgical removal  
**Requirement:** PRQC-03  
**Commit:** `c8801e9`

**Done when:**
- [x] YAML parses without error
- [x] `grep "brew install tailor" ...` returns 0 matches
- [x] `grep "brew install lizard" ...` returns 0 matches
- [x] `grep "gem install.*xcpretty" ...` returns 0 matches
- [x] `grep "brew install swiftlint" ...` returns 1 match (preserved)
- [x] `grep "xcode-select" ...` returns a match (preserved)

**Tests:** static | **Gate:** quick

---

### T04: Add 3 `bundle exec fastlane` steps to `ios_quality_check.yml` ✅

**What:** Insert steps for `fastlane lint`, `fastlane build_and_run_tests` and `fastlane verify_example_integrations` after `Update sonar properties` and before `Run Sonar-Swift Script`  
**Where:** `.github/workflows/ios_quality_check.yml`  
**Depends on:** T03  
**Reuses:** `bundle exec fastlane` pattern from `ios_quality_check_main_branches.yml`  
**Requirement:** PRQC-04, PRQC-05, PRQC-06, PRQC-07  
**Commit:** `08e20d3`

**Done when:**
- [x] YAML parses without error
- [x] `grep "bundle exec fastlane lint" ...` returns 1 match
- [x] `grep "bundle exec fastlane build_and_run_tests" ...` returns 1 match
- [x] `grep "bundle exec fastlane verify_example_integrations" ...` returns 1 match
- [x] `grep "continue-on-error" ...` returns 0 matches
- [x] The 3 steps are positioned AFTER `Update sonar properties` and BEFORE `Run Sonar-Swift Script` (verified by line numbers)

**Tests:** static | **Gate:** full

---

### T05: Add 2 Slack notification steps to `ios_quality_check.yml` ✅

**What:** Insert `Notify Slack on success` and `Notify Slack on failure` steps at the end of the job (after `Verify Coverage Report`), with verbatim payloads from the ticket  
**Where:** `.github/workflows/ios_quality_check.yml`  
**Depends on:** T04  
**Reuses:** Verbatim YAML from ticket DEV-305935  
**Requirement:** PRQC-11, PRQC-12, PRQC-13, PRQC-14, PRQC-15  
**Commit:** `8c08d79`

**Done when:**
- [x] YAML parses without error
- [x] `grep "slackapi/slack-github-action@v2" ...` returns 2 matches
- [x] `grep "if: success()" ...` returns 1 match
- [x] `grep "if: failure()" ...` returns 1 match
- [x] `grep '"color": "good"' ...` returns 1 match (success payload)
- [x] `grep '"color": "danger"' ...` returns 1 match (failure payload)
- [x] `grep "SLACK_WEBHOOK_URL" ...` returns 2 matches
- [x] `github.repository`, `github.actor`, `github.run_id` are present in context
- [x] Steps are positioned AFTER `Verify Coverage Report` (last step of the job)

**Tests:** static | **Gate:** build

---

## Phase Execution Map

```
T01 → T02 → T03 → T04 → T05
(Gemfile)  (ruby/setup-ruby)  (remove brew)  (fastlane lanes)  (slack)
```

Linear sequential execution — each task depends on the previous one (all in the same files).  
**5 tasks — single inline batch, no sub-agents.**

---

## Task Granularity Check

| Task | Scope | File | Status |
|---|---|---|---|
| T01: Add xcpretty to Gemfile | 1 line added | `Gemfile` | ✅ Granular |
| T02: Add ruby/setup-ruby step | 1 new YAML step | `ios_quality_check.yml` | ✅ Granular |
| T03: Modify Install dependencies | Surgical removal of 3 lines | `ios_quality_check.yml` | ✅ Granular |
| T04: Add 3 fastlane steps | 3 new YAML steps | `ios_quality_check.yml` | ✅ Granular |
| T05: Add 2 Slack steps | 2 new YAML steps | `ios_quality_check.yml` | ✅ Granular |

---

## Diagram-Definition Cross-Check

| Task | Depends On (task body) | Diagram | Status |
|---|---|---|---|
| T01 | None | Start of chain | ✅ Match |
| T02 | T01 | T01 → T02 | ✅ Match |
| T03 | T02 | T02 → T03 | ✅ Match |
| T04 | T03 | T03 → T04 | ✅ Match |
| T05 | T04 | T04 → T05 | ✅ Match |

---

## Test Co-location Validation

| Task | Layer | Matrix Requires | Task Says | Status |
|---|---|---|---|---|
| T01: Gemfile | Ruby config | static | static | ✅ OK |
| T02: ruby/setup-ruby step | YAML | static | static | ✅ OK |
| T03: Modify Install deps | YAML | static | static | ✅ OK |
| T04: Fastlane steps | YAML | static | static | ✅ OK |
| T05: Slack steps | YAML | static | static | ✅ OK |
