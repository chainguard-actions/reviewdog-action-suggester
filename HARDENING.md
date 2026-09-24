<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.26.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-suggester/v1.26.1** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: The shell variable `${INPUT_REVIEWDOG_FLAGS}` is expanded **unquoted** inside the `reviewdog` command in `script.sh` (line 22). This variable is populated from `inputs.reviewdog_flags` via the `env:` block in `action.yml`, making it fully attacker-controlled. An unquoted expansion allows the shell to parse metacharacters (`;`, `|`, `&`, `$(...)`, etc.) out of the value, enabling command injection. The `# shellcheck disable=SC2086` comment acknowledges the unquoted expansion but does not mitigate the security risk. Offending line: `  ${INPUT_REVIEWDOG_FLAGS} <"${TMPFILE}"`

Locations:

- `script.sh:22`
- `action.yml:57`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted ${INPUT_REVIEWDOG_FLAGS} expansion in script.sh (line 22). Changed shebang from #!/bin/sh to #!/bin/bash (the script is already sourced by bash per action.yml's shell: bash). Replaced the unquoted expansion with a guarded xargs-based tokenization into a bash array (reviewdog_flags), using the pattern: while IFS= read -r -d '' t; do reviewdog_flags+=("$t"); done < <(printf '%s' "${INPUT_REVIEWDOG_FLAGS}" | xargs printf '%s\0'). The reviewdog command now uses "${reviewdog_flags[@]}" to safely expand each flag as a separate quoted argument. Removed the # shellcheck disable=SC2086 comment that acknowledged but did not mitigate the injection risk.

