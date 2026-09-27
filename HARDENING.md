<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.24.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-suggester/v1.24.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): In script.sh, the variable `${INPUT_REVIEWDOG_FLAGS}` is expanded unquoted on line 22 of the reviewdog invocation. This variable holds the value of `${{ inputs.reviewdog_flags }}` (a workflow-controllable input set via the env: block in action.yml). An unquoted shell expansion allows an attacker to inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) through the `reviewdog_flags` input, enabling arbitrary command execution. The intentional `# shellcheck disable=SC2086` comment confirms the unquoted expansion is deliberate, but it does not mitigate the injection risk. Offending line: `  ${INPUT_REVIEWDOG_FLAGS} <"${TMPFILE}"`

Locations:

- `script.sh:22`
- `action.yml:62`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script-injection vulnerability in script.sh line 22: replaced the unquoted `${INPUT_REVIEWDOG_FLAGS}` expansion (with shellcheck disable comment) with a safe xargs-based tokenization into a bash array. The fix: (1) changed shebang from #!/bin/sh to #!/bin/bash (safe since the script is sourced via `shell: bash` in action.yml), (2) added a guarded xargs tokenization loop that splits INPUT_REVIEWDOG_FLAGS into a bash array using null-delimited reads (handles quoted arguments correctly), (3) expanded the array as `"${reviewdog_flags[@]}"` to pass each flag as a separate, properly-quoted argument. The reviewdog command reads from a file redirect `< "${TMPFILE}"` rather than stdin, so the xargs pipeline does not interfere with reviewdog's input.

