<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.26.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-suggester/v1.26.2** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In script.sh, the env var `${INPUT_REVIEWDOG_FLAGS}` — which holds the value of `inputs.reviewdog_flags` (a workflow-controllable input set via `${{ inputs.reviewdog_flags }}` in action.yml) — is expanded **unquoted** on line 25 inside the `reviewdog` command invocation. An unquoted shell expansion allows an attacker to inject shell metacharacters (`;`, `|`, `&`, `$(...)`, glob patterns, whitespace word-splitting) into the command. The `# shellcheck disable=SC2086` comment acknowledges intentional word-splitting but does not mitigate the injection risk. All other `INPUT_*` variables in the same script are correctly double-quoted.

Locations:

- `script.sh:25`
- `action.yml:62`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted ${INPUT_REVIEWDOG_FLAGS} expansion in script.sh line 25. Replaced the unquoted expansion (with shellcheck disable comment) with a safe xargs-based tokenization into a bash array. The INPUT_REVIEWDOG_FLAGS value is now tokenized using 'printf '%s' "${INPUT_REVIEWDOG_FLAGS}" | xargs printf '%s\0'' with a NUL-delimited read loop into a reviewdog_flags array, then expanded as '"${reviewdog_flags[@]}"'. A guard 'if [ -n "${INPUT_REVIEWDOG_FLAGS}" ]' prevents xargs from emitting an empty token on empty input. The stdin redirect '< "${TMPFILE}"' remains on the reviewdog command (not on xargs), avoiding any stdin conflict. Bash constructs are valid since the script is sourced from a 'shell: bash' step in action.yml.

