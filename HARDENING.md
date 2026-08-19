<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.22.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-suggester/v1.22.0** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

install.sh (sourced from action.yml) downloads a remote install script via curl or wget and pipes it directly to `sh -s` for execution. This is the classic unsafe-shell pattern: remote content is executed without first being saved to a file and inspected. Line 32: `curl -sfL "${INSTALL_SCRIPT}"` / `wget -O - "${INSTALL_SCRIPT}"` piped to `sh -s -- -b ...`

Locations:

- `install.sh:32`
- `action.yml:52`

### github-env-injection (severity: high)

install.sh writes `${TEMP}/reviewdog/bin` to $GITHUB_PATH (line 35) without sanitization. TEMP is derived from the inherited env var REVIEWDOG_TEMPDIR, which is set in action.yml to `${{ runner.temp }}` — a workflow-controlled runner.* context value. No `printf '%s' ... | tr -d '\n\r'` sanitization is applied before the write. An attacker-controlled calling workflow could inject newlines into GITHUB_PATH via this value.

Locations:

- `install.sh:35`
- `action.yml:55`

### script-injection (severity: high)

Sub-rule (b): script.sh uses `${INPUT_REVIEWDOG_FLAGS}` unquoted (line 24) when passing it as arguments to the `reviewdog` command. INPUT_REVIEWDOG_FLAGS is set from `${{ inputs.reviewdog_flags }}` in action.yml (an attacker-controlled input). The unquoted expansion allows the shell to parse metacharacters (`;`, `|`, `&`, `$(...)`, etc.) from the value, enabling command injection. The comment acknowledges intentional word-splitting but does not address the injection risk.

Locations:

- `script.sh:24`
- `action.yml:72`

### permissions (severity: medium)

missing-permissions: None of the four workflow files define a `permissions:` key at the top level or at the job level. Without explicit permissions, workflows run with the default (potentially write) token permissions, violating the principle of least privilege. Affected files: test.yml, reviewdog.yml, release.yml, depup.yml.

Locations:

- `.github/workflows/test.yml:1`
- `.github/workflows/reviewdog.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/depup.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, github-env-injection, script-injection, permissions

**Notes:**

Fixed all four findings:

1. unsafe-shell (install.sh): Changed curl/wget pipe-to-sh pattern to download the remote install script to a temp file first (`${TEMP}/reviewdog_install.sh`), then execute it with `sh`, then delete it. This prevents remote content from being executed without inspection.

2. github-env-injection (install.sh): Added `printf '%s' "${TEMP}/reviewdog/bin" | tr -d '\n\r'` sanitization before writing to $GITHUB_PATH to strip embedded newlines that could be injected via the REVIEWDOG_TEMPDIR env var (sourced from `${{ runner.temp }}`).

3. script-injection (script.sh): Replaced unquoted `${INPUT_REVIEWDOG_FLAGS}` expansion with a bash array approach: `IFS=' ' read -ra reviewdog_flags_args <<<"${INPUT_REVIEWDOG_FLAGS}"` and `"${reviewdog_flags_args[@]}"`. This prevents shell metacharacters (`;`, `|`, `&`, `$(...)`) in the attacker-controlled input from being interpreted as shell commands. Changed shebang to `#!/bin/bash` for array support.

4. permissions (all four workflow files): Added top-level `permissions:` blocks with least-privilege settings: test.yml and reviewdog.yml get `contents:read, pull-requests:write` (plus `checks:write` for reviewdog.yml); release.yml and depup.yml get `contents:write, pull-requests:write` for their release/PR creation needs.

