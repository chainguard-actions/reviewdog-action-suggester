<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-suggester/v1.24.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In script.sh (sourced by action.yml's composite run step), the variable `${INPUT_REVIEWDOG_FLAGS}` is expanded unquoted in the shell command. This variable is set from `inputs.reviewdog_flags` (a workflow-controllable value via the `env:` block in action.yml). An attacker-controlled value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) will be parsed by the shell, enabling command injection. The comment acknowledges intentional word-splitting, but this does not mitigate the injection risk.

Locations:

- `script.sh:19`
- `action.yml:57`

### missing-permissions (severity: medium)

None of the workflow files define a top-level `permissions:` key, and no job within them defines job-level `permissions:` either. Without explicit permissions, workflows run with the default (potentially broad) token permissions, violating the principle of least privilege.

Locations:

- `.github/workflows/depup.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/reviewdog.yml:1`
- `.github/workflows/test.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, missing-permissions

**Notes:**

1. script-injection (script.sh line 19): Replaced the unquoted `${INPUT_REVIEWDOG_FLAGS}` expansion with a bash array. The flags string is split safely using `xargs printf '%s\0'` into null-delimited tokens collected into a `reviewdog_flags` array, then expanded as `"${reviewdog_flags[@]}"`. This prevents shell metacharacter injection while still supporting multiple space-separated flags. Updated shebang from `#!/bin/sh` to `#!/bin/bash` since bash arrays and process substitution are used. 2. missing-permissions: Added top-level `permissions:` blocks to all four workflow files — depup.yml (contents:write, pull-requests:write), release.yml (contents:write, pull-requests:write), reviewdog.yml (contents:read, checks:write, pull-requests:write), and test.yml (contents:read, pull-requests:write) — granting only the minimum permissions each workflow requires.

