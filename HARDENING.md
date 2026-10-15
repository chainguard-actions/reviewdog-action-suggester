<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.26.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-suggester/v1.26.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In script.sh, the variable ${INPUT_REVIEWDOG_FLAGS} is expanded unquoted on the reviewdog command line (line 29). INPUT_REVIEWDOG_FLAGS is set from ${{ inputs.reviewdog_flags }} — a caller-controlled input — in action.yml's env: block. The intentional word-splitting (noted by the shellcheck disable comment) allows an attacker to inject arbitrary shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) via the `reviewdog_flags` input, enabling command injection. The variable must be quoted or the flags must be passed via a safe mechanism (e.g., an array or a file).

Locations:

- `script.sh:29`
- `action.yml:62`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script.sh line 29: replaced unquoted ${INPUT_REVIEWDOG_FLAGS} expansion with a bash array tokenized via xargs. The INPUT_REVIEWDOG_FLAGS value is now parsed with quote-aware tokenization (xargs -r printf '%s\0' piped through a while/read loop into a bash array), then expanded as "${reviewdog_flags[@]}". This prevents shell metacharacters (;, |, &, $(...)) from being interpreted as shell commands. The stdin redirection (< "${TMPFILE}") remains on the reviewdog command, not on xargs, so reviewdog still reads its diff data correctly. The if [ -n ... ] guard prevents xargs from emitting an empty token when the input is empty. The shellcheck disable comment was removed as it is no longer needed.

