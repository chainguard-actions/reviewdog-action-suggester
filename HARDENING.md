<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.26.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-suggester/v1.26.1** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In script.sh, the variable `${INPUT_REVIEWDOG_FLAGS}` — which holds the caller-controlled `inputs.reviewdog_flags` value (set via `INPUT_REVIEWDOG_FLAGS: ${{ inputs.reviewdog_flags }}` in action.yml) — is expanded **unquoted** inside the `reviewdog` shell command. The `# shellcheck disable=SC2086` comment explicitly acknowledges this unquoted expansion. An attacker can supply shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, etc.) in the `reviewdog_flags` input to inject arbitrary shell commands. The offending line is: `  ${INPUT_REVIEWDOG_FLAGS} <"${TMPFILE}"`

Locations:

- `script.sh:28`
- `action.yml:62`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed shell injection vulnerability in script.sh at line 28. The unquoted `${INPUT_REVIEWDOG_FLAGS}` expansion (with `# shellcheck disable=SC2086`) was replaced with a safe xargs-based tokenization pattern that splits the flags input into a bash array. The array is then expanded as `"${reviewdog_flags[@]}"` to pass each flag as a separate, properly-quoted argument to reviewdog. This prevents shell metacharacters in the `reviewdog_flags` input from being interpreted as shell commands. The fix uses the guarded xargs pattern required for list-style inputs.

