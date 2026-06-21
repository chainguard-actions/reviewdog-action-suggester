<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.24.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **reviewdog--action-suggester/v1.24.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In script.sh, the variable `${INPUT_REVIEWDOG_FLAGS}` is intentionally unquoted to allow word-splitting for multiple flags, but this variable is sourced from `inputs.reviewdog_flags` (a workflow-controllable input, mapped via the `env:` block in action.yml as `INPUT_REVIEWDOG_FLAGS: ${{ inputs.reviewdog_flags }}`). An attacker controlling this input can inject shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, etc.) since the expansion is unquoted. The offending line is: `  ${INPUT_REVIEWDOG_FLAGS} <"${TMPFILE}"`. The value should be sanitized or the expansion should be quoted to prevent command injection.

Locations:

- `script.sh:18`
- `action.yml:62`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in script.sh at line 18. The unquoted `${INPUT_REVIEWDOG_FLAGS}` expansion (which allowed shell metacharacter injection via the `inputs.reviewdog_flags` workflow input) was replaced with a bash array approach: `IFS=' ' read -ra REVIEWDOG_FLAGS_ARRAY <<< "${INPUT_REVIEWDOG_FLAGS}"` followed by `"${REVIEWDOG_FLAGS_ARRAY[@]}"`. This splits flags by whitespace into an array and expands each element as a separate quoted argument, preserving the multi-flag functionality while preventing injection of `;`, `|`, `&`, `$(...)`, backticks, etc. The shebang was updated from `#!/bin/sh` to `#!/bin/bash` since bash arrays are bash-specific; the action.yml already uses `shell: bash` for the sourcing step. The `# shellcheck disable=SC2086` comment was also removed since it's no longer needed.

