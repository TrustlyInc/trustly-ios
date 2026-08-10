# DEV-305935 PR Quality Check — Fastlane, Ruby Setup & Slack — Context

**Gathered:** 2026-08-10  
**Spec:** `.specs/features/DEV-305935-ios-sdk-pr-quality-fastlane/spec.md`  
**Status:** Ready for design

---

## Feature Boundary

Modify **only** `.github/workflows/ios_quality_check.yml` and `Gemfile` to:
1. Add `ruby/setup-ruby@v1` (Ruby 3.4, bundler-cache)
2. Add `bundle exec fastlane lint/build_and_run_tests/verify_example_integrations` as authoritative test paths
3. Keep SonarQube analysis (property injection + run-sonar-swift.sh + coverage verification) unchanged
4. Add Slack notifications (success + failure) via `slackapi/slack-github-action@v2`

---

## Implementation Decisions

### Ruby runtime (A-01) ✅

- Use **`ruby/setup-ruby@v1`** with `ruby-version: '3.4'` and `bundler-cache: true` — replaces manual gem management.
- **Add `gem 'xcpretty'` to `Gemfile`** — xcpretty is not currently in the Gemfile; with `bundler-cache: true` it must be declared there to be installed automatically. This eliminates the `sudo gem install -n /usr/local/bin xcpretty` line from the `Install dependencies` step.

### SHA pin for ruby/setup-ruby (A-10) ✅

- Use **tag `@v1`** (no SHA pin), as shown in the ticket example.
- Note: inconsistent with the project pattern (other actions use SHA pins). Documented — future cleanup if desired.

### brew installs that remain (A-08) ✅

The `Install dependencies` step is **trimmed** — only tools that cannot come from the Gemfile:

| Tool | Decision | Reason |
|---|---|---|
| `brew install swiftlint` | **Keep** | Used by the `lint` Fastlane lane |
| `brew install sonar-scanner` | **Keep** | Used by `run-sonar-swift.sh` |
| `brew install tailor` | **Remove** | Never activated in the workflows (`-tailor` flag is off by default) |
| `brew install lizard` | **Remove** | Never activated in the workflows (`-lizard` flag is off by default) |
| `sudo gem install xcpretty` | **Remove from YAML** | Migrated to Gemfile (see above) |
| `sudo xcode-select -switch` | **Keep** | Required Xcode setup for xcodebuild |
| `sudo xcodebuild -license accept` | **Keep** | Accepts the Xcode license |

### Secret SLACK_WEBHOOK_URL (A-06) ✅

- Status: **not verified** — treat as a deploy prerequisite.
- Document in the PR description: "The `SLACK_WEBHOOK_URL` secret must be configured in GitHub → Settings → Secrets before merging."
- The workflow will fail clearly (not silently) if the secret is absent — `slackapi/slack-github-action@v2` with `webhook-type: incoming-webhook` returns an error for an invalid or empty URL.

### SonarQube analysis (A-04, A-05) ✅ — confirmed by ticket

- The property injection step (`echo "sonar.pullrequest.key=..." >> sonar-project.properties`) **stays as a YAML step** — the ticket explicitly says "Keep SonarQube property injection".
- `run-sonar-swift.sh -v` **continues to be invoked** — the ticket says "Keep … scan, and coverage verification".
- The `Verify Coverage Report` step (check for `sonar-reports/generic-coverage.xml`) **stays**.

### Step ordering (A-02) ✅

The `Get Git Revision` step stays in the YAML — required for `sonar.scm.revision`; it is CI context logic.

### Fastlane lane position in workflow ✅

Lanes must run **before** SonarQube (fast-fail: if lint or tests fail, sonar does not run). Final step order:

```
checkout →
Get Git Revision →
Setup Xcode →
Set up Ruby (ruby/setup-ruby) →
Install dependencies (brew: swiftlint, sonar-scanner, xcode-select) →
Install sonar-scanner →
Reset SonarScanner cache →
Update sonar properties →
Run Fastlane Lint →
Run Fastlane Tests →
Run Fastlane Verify Example Integrations →
Run Sonar-Swift Script →
Verify Coverage Report →
Notify Slack on success (if: success()) →
Notify Slack on failure (if: failure())
```

---

## Agent's Discretion

- Visual organization of YAML steps (names, comments)
- Whether to consolidate `brew install swiftlint` and `brew install sonar-scanner` into a single step or keep them separate
- YAML indentation and style consistent with the existing file

---

## Specific References

- Ticket provides the exact YAML for Slack notification steps — use verbatim.
- Ticket provides the exact YAML for `ruby/setup-ruby` — use verbatim.
- Ticket specifies: "Fastlane lanes for lint, build_and_run_tests, and verify_example_integrations execute as the authoritative test paths".

---

## Deferred Ideas

- SHA pin for `ruby/setup-ruby@v1` (consistency with other actions in the project) — decided not to do now per user instruction.
- Migration of `run-sonar-swift.sh` to Fastlane lanes (`sonar_analysis` via `sonar` action) — out of scope for this ticket.
- Unification of both workflows (`ios_quality_check.yml` and `ios_quality_check_main_branches.yml`) — out of scope.
