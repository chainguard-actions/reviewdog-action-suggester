<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **reviewdog--action-suggester/v1.24.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In script.sh, the variable `${INPUT_REVIEWDOG_FLAGS}` — sourced from `inputs.reviewdog_flags` (a workflow-controllable input set via the env: block in action.yml) — is expanded unquoted in the reviewdog command invocation. An unquoted expansion allows shell word-splitting and glob expansion on attacker-controlled content, enabling command injection. The comment acknowledges the intentional split, but this does not mitigate the injection risk. The offending line is: `  ${INPUT_REVIEWDOG_FLAGS} <"${TMPFILE}"`. It should use the guarded form `${INPUT_REVIEWDOG_FLAGS:+"$INPUT_REVIEWDOG_FLAGS"}` or be properly sanitized before use.

Locations:

- `script.sh:18`
- `action.yml:62`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script.sh line 18: replaced unquoted `${INPUT_REVIEWDOG_FLAGS}` with the guarded form `${INPUT_REVIEWDOG_FLAGS:+"$INPUT_REVIEWDOG_FLAGS"}`. This prevents shell word-splitting and glob expansion on the attacker-controlled input while preserving the intended behavior — the argument is omitted entirely when empty (default case) and properly quoted when non-empty. Also removed the `# shellcheck disable=SC2086` comment that was suppressing the warning about the unquoted variable, since the fix eliminates the need for that suppression.

