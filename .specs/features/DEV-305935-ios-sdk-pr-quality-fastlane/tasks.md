# DEV-305935 PR Quality Check — Tasks

## Execution Protocol (MANDATORY — do not skip)

Implement these tasks with the `tlc-spec-driven` skill: **activate it by name and follow its Execute flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the source of truth for the full flow (per-task cycle, sub-agent delegation, adequacy review, Verifier, discrimination sensor).

**If the skill cannot be activated, STOP and tell the user — do not proceed without it.**

---

**Design:** `.specs/features/DEV-305935-ios-sdk-pr-quality-fastlane/design.md`
**Status:** Approved

---

## Test Coverage Matrix

> Generated from codebase sampling and spec. Guidelines found: none — strong defaults applied.
> This feature modifies **CI configuration** (`Fastfile` in Ruby, `ios_quality_check.yml` in YAML).
> No Swift production code changes. The applicable test layer is **structural assertions** —
> grep/parse checks that verify modified files match spec-defined outcomes, following the same
> pattern as the prior validation report (15 grep assertions, 3/3 mutations killed).
> XCTest (Swift unit tests in `TrustlySDK/TrustlySDKTests/`) is NOT exercised by this feature.

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
|---|---|---|---|---|
| `fastlane/Fastfile` (Ruby lanes) | structural | All spec ACs mapped 1:1; every required keyword/pattern present; every removed element confirmed absent | inline bash assertions (grep/ruby -e parse) | `grep` + `ruby -e` checks inline |
| `.github/workflows/ios_quality_check.yml` (YAML) | structural | Required steps present with correct ordering; removed steps confirmed absent; env var injection verified | inline bash assertions | `grep -n` checks inline |
| `.specs/` (docs/state) | none | Build gate only — file exists and is valid markdown | — | file existence check |

## Gate Check Commands

> Generated from codebase — confirm before Execute.

| Gate Level | When to Use | Command |
|---|---|---|
| Structural | After each task (CI config changes) | `grep` + `ruby -e` assertions listed in each task's `Done when` |
| Build | After T5 (YAML complete) | `bundle exec fastlane build_and_run_tests` (validates Fastfile Ruby syntax + scan runs) |
| Full | After T5 (end-to-end) | Push to a test branch; observe `ios_quality_check.yml` workflow run in GitHub Actions |

---

## Execution Plan

Phases are ordered and run sequentially. Each phase completes before the next begins.

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5
```

```
Phase 1:  T1 (enhance build_and_run_tests lane)
Phase 2:  T2 (new sonar_analysis lane)
Phase 3:  T3 → T4 (ci_quality lane + Slack blocks)
Phase 4:  T5 (YAML collapse)
Phase 5:  T6 (commit spec/docs/STATE.md)
```

---

## Task Breakdown

---

### T1: Enhance `build_and_run_tests` lane to produce `.xcresult`

**What:** Add `result_bundle: true`, `result_bundle_path: "sonar-reports/TestResults.xcresult"`, `derived_data_path: "sonar-reports/"`, and `code_coverage: true` to the `scan` call in `build_and_run_tests`. This makes the lane produce the `.xcresult` bundle that `sonar_analysis` (T2) will consume, eliminating the duplicate `xcodebuild` run that was inside `run-sonar-swift.sh`.

**Where:** `fastlane/Fastfile` — `build_and_run_tests` lane (lines 14–21)

**Depends on:** None

**Reuses:** Existing `build_and_run_tests` lane; `scan` action (fastlane built-in)

**Requirement:** PRQC-04, PRQC-05 (Fastlane as authoritative test path); design component 2

**Tools:**
- MCP: none
- Skill: `tlc-spec-driven`

**Done when:**
- [ ] `scan` call in `build_and_run_tests` includes `result_bundle: true`
- [ ] `scan` call includes `result_bundle_path: "sonar-reports/TestResults.xcresult"`
- [ ] `scan` call includes `derived_data_path: "sonar-reports/"`
- [ ] `scan` call includes `code_coverage: true`
- [ ] Structural check: `grep -c "result_bundle_path" fastlane/Fastfile` returns 1
- [ ] Structural check: `grep -c "code_coverage" fastlane/Fastfile` returns 1
- [ ] Ruby syntax valid: `ruby -e "require 'rubygems'" fastlane/Fastfile 2>/dev/null || bundle exec ruby -c fastlane/Fastfile`
- [ ] No other lanes modified

**Tests:** structural
**Gate:** structural

**Commit:** `ci(fastfile): produce xcresult bundle in build_and_run_tests for coverage (DEV-305935)`

---

### T2: Add `sonar_analysis` lane

**What:** Add a new `sonar_analysis` lane to `fastlane/Fastfile` that: (1) calls `xccov-to-sonarqube-generic.sh` via `sh()` to generate `sonar-reports/generic-coverage.xml` from `sonar-reports/TestResults.xcresult`; (2) verifies the file exists and is non-empty via `UI.user_error!`; (3) calls the `sonar()` action with project params and PR decoration via `sonar_runner_args`. `run-sonar-swift.sh` is NOT called from this lane.

**Where:** `fastlane/Fastfile` — new lane added inside `platform :ios do`

**Depends on:** T1 (depends on `sonar-reports/TestResults.xcresult` being produced by the enhanced `build_and_run_tests`)

**Reuses:** `xccov-to-sonarqube-generic.sh` (repo root, called via `sh()`); `sonar()` action (fastlane built-in); `sonar-project.properties` (read as base config by `sonar()`)

**Requirement:** PRQC-08, PRQC-09, PRQC-10 (SonarQube preserved); design component 3

**Tools:**
- MCP: none
- Skill: `tlc-spec-driven`

**Done when:**
- [ ] `sonar_analysis` lane present in `fastlane/Fastfile`
- [ ] Lane calls `sh("bash xccov-to-sonarqube-generic.sh sonar-reports/TestResults.xcresult > sonar-reports/generic-coverage.xml")`
- [ ] Lane calls `UI.user_error!("Coverage report not found!")` if `sonar-reports/generic-coverage.xml` does not exist
- [ ] Lane calls `UI.user_error!("Coverage report is empty!")` if file is zero-size
- [ ] Lane calls `sonar()` with `project_key`, `project_name`, `sonar_url`, `sonar_token` reading from `ENV`
- [ ] `sonar_runner_args` includes `-Dsonar.pullrequest.key`, `-Dsonar.pullrequest.branch`, `-Dsonar.pullrequest.base`, `-Dsonar.scm.revision`, `-Dsonar.coverageReportPaths=sonar-reports/generic-coverage.xml`
- [ ] Structural check: `grep -c "sonar_analysis" fastlane/Fastfile` returns ≥ 1 (lane definition)
- [ ] Structural check: `grep -c "xccov-to-sonarqube-generic.sh" fastlane/Fastfile` returns 1
- [ ] Structural check: `grep -c "sonar_runner_args" fastlane/Fastfile` returns 1
- [ ] Structural check: `grep -c "UI.user_error" fastlane/Fastfile` returns 2 (absent + empty checks)
- [ ] Ruby syntax valid

**Tests:** structural
**Gate:** structural

**Commit:** `ci(fastfile): add sonar_analysis lane replacing run-sonar-swift.sh (DEV-305935)`

---

### T3: Add `ci_quality` orchestration lane

**What:** Add a new `ci_quality` lane to `fastlane/Fastfile` that calls `lint`, `build_and_run_tests`, `verify_example_integrations`, and `sonar_analysis` in that order. This is the single entry point the YAML will call.

**Where:** `fastlane/Fastfile` — new lane added inside `platform :ios do`

**Depends on:** T2 (all four called lanes must exist before the orchestrator can reference them)

**Reuses:** `lint`, `build_and_run_tests`, `verify_example_integrations`, `sonar_analysis` lanes

**Requirement:** PRQC-04, PRQC-05, PRQC-06, PRQC-07 (all lanes present, no `continue-on-error`); AD-004

**Tools:**
- MCP: none
- Skill: `tlc-spec-driven`

**Done when:**
- [ ] `ci_quality` lane present in `fastlane/Fastfile`
- [ ] Lane body calls exactly: `lint`, `build_and_run_tests`, `verify_example_integrations`, `sonar_analysis` in that order
- [ ] No `continue-on-error` or `rescue` anywhere in the lane
- [ ] Structural check: `grep -c "lane :ci_quality" fastlane/Fastfile` returns 1
- [ ] Structural check: lane body contains all four lane calls in order (grep line numbers confirm ordering)
- [ ] Ruby syntax valid

**Tests:** structural
**Gate:** structural

**Commit:** `ci(fastfile): add ci_quality orchestration lane (DEV-305935)`

---

### T4: Add `after_all` and `error` blocks with `slack()` notifications

**What:** Add platform-level `after_all` and `error do |lane, exception|` blocks inside `platform :ios do` in `fastlane/Fastfile`. Each block has a `next unless lane == :ci_quality` scope guard. `after_all` sends `slack(success: true, ...)` with repo/actor/run-link payload; `error` sends `slack(success: false, ...)`. Both read `SLACK_URL` env var automatically (fastlane `slack()` default) and `GITHUB_*` env vars for payload content.

**Where:** `fastlane/Fastfile` — inside `platform :ios do`, after all lane definitions

**Depends on:** T3 (`ci_quality` lane must exist for the scope guard to make sense; blocks are semantically coupled to the orchestration lane)

**Reuses:** Fastlane `slack()` action (built-in, reads `SLACK_URL` env var automatically)

**Requirement:** PRQC-11, PRQC-12, PRQC-13, PRQC-14, PRQC-15 (Slack notifications)

**Tools:**
- MCP: none
- Skill: `tlc-spec-driven`

**Done when:**
- [ ] `after_all do |lane|` block present with `next unless lane == :ci_quality` guard
- [ ] `after_all` block calls `slack(message: ..., success: true, default_payloads: [], payload: { "Repo" => ..., "Actor" => ..., "Run" => ... })`
- [ ] `error do |lane, exception|` block present with `next unless lane == :ci_quality` guard
- [ ] `error` block calls `slack(message: ..., success: false, default_payloads: [], payload: { "Repo" => ..., "Actor" => ..., "Run" => ... })`
- [ ] Both blocks read `ENV["GITHUB_REPOSITORY"]`, `ENV["GITHUB_ACTOR"]`, `ENV["GITHUB_RUN_ID"]`, `ENV["GITHUB_SERVER_URL"]`
- [ ] Structural check: `grep -c "after_all" fastlane/Fastfile` returns 1
- [ ] Structural check: `grep -c "error do" fastlane/Fastfile` returns 1
- [ ] Structural check: `grep -c "next unless lane == :ci_quality" fastlane/Fastfile` returns 2
- [ ] Structural check: `grep -c "success: true" fastlane/Fastfile` returns 1, `grep -c "success: false"` returns 1
- [ ] Ruby syntax valid

**Tests:** structural
**Gate:** structural

**Commit:** `ci(fastfile): add Slack after_all/error blocks for ci_quality lane (DEV-305935)`

---

### T5: Collapse `ios_quality_check.yml` to single Fastlane step

**What:** Modify `.github/workflows/ios_quality_check.yml` to: (1) remove the `Update sonar properties` step; (2) remove the `Run Sonar-Swift Script` step; (3) remove the `Verify Coverage Report` step; (4) remove the two commented-out `slackapi/slack-github-action@v2` steps; (5) add a single `Run CI Quality` step that calls `bundle exec fastlane ci_quality` with all required env vars (`SONAR_PROJECT_KEY`, `SONAR_PROJECT_NAME`, `SONAR_HOST_URL`, `SONAR_TOKEN`, `PR_NUMBER`, `BRANCH_ORIGIN`, `BASE_BRANCH`, `GIT_REVISION`, `SLACK_URL`, `GITHUB_REPOSITORY`, `GITHUB_ACTOR`, `GITHUB_RUN_ID`, `GITHUB_SERVER_URL`, `SONAR_USER_HOME`). Keep all other steps unchanged.

**Where:** `.github/workflows/ios_quality_check.yml`

**Depends on:** T4 (all Fastfile lanes and blocks must exist before the YAML references `ci_quality`)

**Reuses:** Existing YAML env block variables (`PR_NUMBER`, `BRANCH_ORIGIN`, `BASE_BRANCH`, `SONAR_TOKEN`, etc.); existing step infrastructure (checkout, xcode setup, ruby setup, brew installs)

**Requirement:** PRQC-01–15 (all requirements — this is the final integration step); AD-004

**Tools:**
- MCP: none
- Skill: `tlc-spec-driven`

**Done when:**
- [ ] `Update sonar properties` step removed from YAML
- [ ] `Run Sonar-Swift Script` step removed from YAML
- [ ] `Verify Coverage Report` step removed from YAML
- [ ] Both `slackapi/slack-github-action@v2` commented blocks removed from YAML
- [ ] `Run CI Quality` step added: `run: bundle exec fastlane ci_quality`
- [ ] `Run CI Quality` step has `env:` block with all 13 required env vars (see design component 7)
- [ ] `SONAR_USER_HOME: ${{ runner.temp }}/.sonar` included in the step's `env:` (not just the job env) to match what `sonar()` action expects
- [ ] Structural check: `grep -c "run-sonar-swift" .github/workflows/ios_quality_check.yml` returns 0
- [ ] Structural check: `grep -c "slackapi" .github/workflows/ios_quality_check.yml` returns 0
- [ ] Structural check: `grep -c "sonar.pullrequest" .github/workflows/ios_quality_check.yml` returns 0 (injection moved to Fastfile)
- [ ] Structural check: `grep -c "Verify Coverage" .github/workflows/ios_quality_check.yml` returns 0
- [ ] Structural check: `grep -c "bundle exec fastlane ci_quality" .github/workflows/ios_quality_check.yml` returns 1
- [ ] Structural check: `grep -c "SLACK_URL" .github/workflows/ios_quality_check.yml` returns 1 (only in the new step env)
- [ ] YAML syntax valid: `ruby -ryaml -e "YAML.load_file('.github/workflows/ios_quality_check.yml')"` exits 0
- [ ] Build gate: `bundle exec fastlane build_and_run_tests` passes (Fastfile syntax + scan runs)

**Tests:** structural + build
**Gate:** build

**Commit:** `ci(workflow): collapse ios_quality_check to single fastlane ci_quality step (DEV-305935)`

---

### T6: Commit spec docs and STATE.md update

**What:** Commit the uncommitted working tree changes to `.specs/STATE.md` (AD-001 superseded → AD-004 added), `.specs/features/DEV-305935-ios-sdk-pr-quality-fastlane/design.md` (new design from this session), and `.specs/features/DEV-305935-ios-sdk-pr-quality-fastlane/context.md` (updated from discuss session). These are already written; this task is the commit.

**Where:**
- `.specs/STATE.md`
- `.specs/features/DEV-305935-ios-sdk-pr-quality-fastlane/design.md`
- `.specs/features/DEV-305935-ios-sdk-pr-quality-fastlane/context.md`

**Depends on:** T5 (all implementation complete; docs committed last)

**Reuses:** Already-written content from `/tlc-design` and `/tlc-discuss` sessions

**Requirement:** AD-004 (project memory); traceability

**Tools:**
- MCP: none
- Skill: `tlc-spec-driven`

**Done when:**
- [ ] `git diff --name-only HEAD` no longer lists `.specs/STATE.md`, `design.md`, `context.md`
- [ ] `grep "AD-004" .specs/STATE.md` returns a match
- [ ] `grep "superseded by AD-004" .specs/STATE.md` returns a match

**Tests:** none
**Gate:** structural (file existence + content check)

**Commit:** `docs: update spec context/design and record AD-004 all-fastlane decision (DEV-305935)`

---

## Phase Execution Map

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5

Phase 1:  T1
Phase 2:  T2
Phase 3:  T3 → T4
Phase 4:  T5
Phase 5:  T6
```

---

## Task Granularity Check

| Task | Scope | Status |
|---|---|---|
| T1: Enhance build_and_run_tests | 1 lane modified, 1 file | ✅ Granular |
| T2: Add sonar_analysis lane | 1 new lane, 1 file | ✅ Granular |
| T3: Add ci_quality lane | 1 new lane, 1 file | ✅ Granular |
| T4: Add after_all/error Slack blocks | 2 cohesive blocks, 1 file | ✅ Granular (inseparable pair) |
| T5: Collapse YAML | 1 file, removes 4 sections + adds 1 step | ✅ Granular |
| T6: Commit docs | 3 already-written files | ✅ Granular |

---

## Diagram-Definition Cross-Check

| Task | Depends On (task body) | Diagram Shows | Status |
|---|---|---|---|
| T1 | None | T1 starts Phase 1 (no incoming arrow) | ✅ Match |
| T2 | T1 | Phase 1 → Phase 2 (T1 → T2) | ✅ Match |
| T3 | T2 | T2 → T3 (within Phase 3) | ✅ Match |
| T4 | T3 | T3 → T4 (within Phase 3) | ✅ Match |
| T5 | T4 | Phase 3 → Phase 4 (T4 → T5) | ✅ Match |
| T6 | T5 | Phase 4 → Phase 5 (T5 → T6) | ✅ Match |

All dependencies point backward. No forward dependencies. ✅

---

## Test Co-location Validation

| Task | Code Layer Created/Modified | Matrix Requires | Task Says | Status |
|---|---|---|---|---|
| T1: Enhance build_and_run_tests | `fastlane/Fastfile` (CI config) | structural | structural | ✅ OK |
| T2: Add sonar_analysis lane | `fastlane/Fastfile` (CI config) | structural | structural | ✅ OK |
| T3: Add ci_quality lane | `fastlane/Fastfile` (CI config) | structural | structural | ✅ OK |
| T4: Add after_all/error blocks | `fastlane/Fastfile` (CI config) | structural | structural | ✅ OK |
| T5: Collapse YAML | `.github/workflows/ios_quality_check.yml` (CI config) | structural + build | structural + build | ✅ OK |
| T6: Commit docs | `.specs/` (docs) | none | none | ✅ OK |

No violations. ✅
