<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.24.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-suggester/v1.24.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In script.sh, the variable ${INPUT_REVIEWDOG_FLAGS} is expanded **unquoted** inside the reviewdog command. This env var is populated from `${{ inputs.reviewdog_flags }}` (an attacker-controlled input) via the `env:` block in action.yml. Because the expansion is unquoted, the shell will word-split and interpret any metacharacters (`;`, `|`, `&`, `$(...)`, etc.) in the value, enabling command injection. The comment "INPUT_REVIEWDOG_FLAGS is intentionally split" explains the word-splitting intent but does not mitigate the injection risk. The offending line is:

```sh
  ${INPUT_REVIEWDOG_FLAGS} <"${TMPFILE}"
```

A safe alternative that still allows flag splitting would be to use an array: `read -ra extra_flags <<< "${INPUT_REVIEWDOG_FLAGS}"` and then pass `"${extra_flags[@]}"`.

Locations:

- `script.sh:19`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script-injection in hardened/action/script.sh: replaced the unquoted ${INPUT_REVIEWDOG_FLAGS} expansion with a safe xargs-based tokenization into a bash array. The INPUT_REVIEWDOG_FLAGS value is now tokenized (quote-aware, via xargs) into an 'extra_flags' array, which is then passed to reviewdog as "${extra_flags[@]}". This prevents shell metacharacters from being interpreted as commands while still allowing multiple flags. The xargs pipeline runs separately from the reviewdog invocation, so reviewdog's stdin redirect (< "${TMPFILE}") is unaffected. Bash array syntax is valid here because the script is sourced from a 'shell: bash' step in action.yml.

