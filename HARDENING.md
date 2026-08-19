<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.24.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-suggester/v1.24.3** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### missing-permissions (severity: medium)

Workflow file has no top-level `permissions:` key and no job-level `permissions:` key on any job. Without explicit permissions, the GITHUB_TOKEN is granted its default (often broad) permissions, which violates least-privilege principles.

Locations:

- `.github/workflows/depup.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/reviewdog.yml:1`
- `.github/workflows/test.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** missing-permissions

**Notes:**

Added top-level `permissions:` blocks to all four workflow files with minimal required permissions:
- depup.yml: `contents: write, pull-requests: write` (depup action creates PRs for dependency updates)
- release.yml: `contents: write, pull-requests: write` (creates GitHub releases, manages semver tags, posts bumpr status comments)
- reviewdog.yml: `contents: read, checks: write, pull-requests: write` (posts check annotations and PR review comments via reviewdog actions)
- test.yml: `contents: read, pull-requests: write` (action-suggester posts PR review suggestions)

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script-injection vulnerability in hardened/action/script.sh line 24. Changed shebang from #!/bin/sh to #!/bin/bash to enable array support. Replaced the unquoted ${INPUT_REVIEWDOG_FLAGS} expansion (which allowed shell metacharacter injection via semicolons, pipes, backticks, etc.) with a bash array: `read -ra REVIEWDOG_FLAGS_ARRAY <<< "${INPUT_REVIEWDOG_FLAGS}"` followed by `"${REVIEWDOG_FLAGS_ARRAY[@]+"${REVIEWDOG_FLAGS_ARRAY[@]}"}"`. This splits flags on whitespace only (not shell metacharacters), preserving the multi-flag functionality while preventing injection. The array expansion form drops out entirely when the input is empty, avoiding an empty-argument issue.

