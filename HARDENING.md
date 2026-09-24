<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.25.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-suggester/v1.25.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In script.sh, the shell variable ${INPUT_REVIEWDOG_FLAGS} is expanded **unquoted** inside the `reviewdog` command invocation. This variable is populated from `${{ inputs.reviewdog_flags }}` (a caller-controlled input) via the `env:` block in action.yml. An unquoted expansion allows the shell to parse metacharacters (`;`, `|`, `&`, `$(...)`, backticks, glob chars, whitespace) out of the value, enabling command injection. The offending line is:

  `${INPUT_REVIEWDOG_FLAGS} <"${TMPFILE}"  # INPUT_REVIEWDOG_FLAGS is intentionally split...`

Even though the comment notes intentional word-splitting for flag passing, this pattern allows an attacker supplying a crafted `reviewdog_flags` input to execute arbitrary shell commands. The fix is to use an array or a safer quoting strategy, e.g. using `read -ra` to split the flags safely.

Locations:

- `script.sh:16`
- `action.yml:64`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted ${INPUT_REVIEWDOG_FLAGS} expansion in script.sh (line 16). Changed shebang from #!/bin/sh to #!/bin/bash (safe: the script is sourced from a 'shell: bash' step in action.yml). Replaced the unquoted expansion with xargs-based quote-aware tokenization into a bash array: the guard 'if [ -n "${INPUT_REVIEWDOG_FLAGS}" ]' prevents empty-input issues, 'printf "%s" | xargs printf "%s\0"' tokenizes the flags respecting quotes without evaluating shell metacharacters, and the null-delimited read loop populates the array. The reviewdog command then uses '"${reviewdog_flags[@]}"' for safe array expansion. The stdin redirection '< "${TMPFILE}"' is preserved on the reviewdog command itself (not on xargs), so reviewdog's stdin is not stolen.

