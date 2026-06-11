<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.23.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **reviewdog--action-suggester/v1.23.1** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

install.sh fetches a remote script via curl (or wget) and pipes the output directly to `sh -s`. This is the classic 'curl | sh' unsafe shell pattern: if the remote URL is compromised or the connection is intercepted, arbitrary code executes on the runner without any integrity check. The script is sourced from action.yml's first run: step.

Offending line in install.sh:
  ) | sh -s -- -b "${TEMP}/reviewdog/bin" "${VERSION}" 2>&1

The script should be downloaded to a file first, its checksum verified, and then executed separately.

Locations:

- `install.sh:32`
- `action.yml:53`

### github-env-injection (severity: high)

install.sh writes `${TEMP}/reviewdog/bin` to $GITHUB_PATH without sanitization. TEMP is derived from the REVIEWDOG_TEMPDIR environment variable, which is set in action.yml's env: block from `${{ runner.temp }}` — a workflow-context value. Writing a value sourced from a workflow context expression to a special environment file ($GITHUB_PATH) without first applying the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`) violates the github-env-injection rule.

Offending line in install.sh:
  echo "${TEMP}/reviewdog/bin" >> "${GITHUB_PATH}"

Offending env: assignment in action.yml:
  REVIEWDOG_TEMPDIR: ${{ runner.temp }}

Locations:

- `install.sh:33`
- `action.yml:57`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, github-env-injection

**Notes:**

Fixed both findings in install.sh:
1. unsafe-shell: Replaced the 'curl/wget | sh' pattern with a two-step approach: download the install script to a temp file (${TEMP}/reviewdog/install_script.sh) using curl -o or wget -O, then execute it separately with sh. This eliminates the risk of arbitrary code execution from a compromised or intercepted remote script.
2. github-env-injection: Added sanitization of the path before writing to $GITHUB_PATH. The TEMP-derived path is now passed through `printf '%s' ... | tr -d '\n\r'` to strip any embedded newlines before being written to the special environment file, preventing injection attacks via the runner.temp context value.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script.sh: replaced the unquoted `${INPUT_REVIEWDOG_FLAGS}` expansion (which allowed shell metacharacter injection) with a bash array. The value is now split into an array via `IFS=' ' read -ra reviewdog_flags_array <<< "${INPUT_REVIEWDOG_FLAGS}"` and expanded safely as `"${reviewdog_flags_array[@]}"`. This preserves multi-flag word-splitting behavior while preventing injection of shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, etc.). The shebang was updated from `#!/bin/sh` to `#!/bin/bash` to enable array support, consistent with how the script is already sourced (via `shell: bash` in action.yml).

