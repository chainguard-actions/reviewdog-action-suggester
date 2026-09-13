<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.25.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-suggester/v1.25.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) violation: In script.sh line 24, the shell variable `${INPUT_REVIEWDOG_FLAGS}` is expanded **unquoted** inside the `reviewdog` command invocation. This variable is populated from `inputs.reviewdog_flags` (a workflow-controllable value) via the `env:` block in action.yml. Because the expansion is unquoted, the shell performs word-splitting and glob expansion on the value, allowing an attacker to inject arbitrary shell metacharacters, extra flags, or command separators. The `# shellcheck disable=SC2086` comment confirms the author intentionally suppressed the shellcheck warning, but this does not mitigate the injection risk. The offending line is: `  ${INPUT_REVIEWDOG_FLAGS} <"${TMPFILE}"`

Locations:

- `script.sh:24`
- `action.yml:68`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script.sh line 24: replaced unquoted `${INPUT_REVIEWDOG_FLAGS}` expansion with a safe xargs-based tokenization into a bash array. The `reviewdog_flags` array is populated using `printf '%s' "$INPUT_REVIEWDOG_FLAGS" | xargs printf '%s\0'` with a NUL-delimited read loop (guarded by a non-empty check to avoid xargs running on empty input). The array is then expanded as `"${reviewdog_flags[@]}"` in the reviewdog invocation, preventing word-splitting, glob expansion, and shell metacharacter injection. The script is sourced in bash (action.yml uses `shell: bash`), so bash array syntax is valid despite the `#!/bin/sh` shebang.

