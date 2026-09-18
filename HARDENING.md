<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.26.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-suggester/v1.26.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in script.sh: the shell variable `${INPUT_REVIEWDOG_FLAGS}` — which holds the value of `inputs.reviewdog_flags` (a workflow-controllable input passed via the env: block in action.yml) — is expanded **unquoted** inside the `reviewdog` command invocation. An attacker-controlled value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, whitespace, glob chars) will be parsed by the shell before being passed to the command, enabling command injection. The offending line is:

```sh
  ${INPUT_REVIEWDOG_FLAGS} <"${TMPFILE}"
```

Even though the comment says word-splitting is intentional for passing multiple flags, the value must still be treated as untrusted. A safe alternative is to use an array: `read -ra flags <<< "${INPUT_REVIEWDOG_FLAGS}"` and then `"${flags[@]}"`; or require callers to pass flags via a structured input.

Locations:

- `script.sh:22`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script-injection in hardened/action/script.sh: replaced the unquoted `${INPUT_REVIEWDOG_FLAGS}` expansion with a safe xargs-based tokenization into a bash array. The `reviewdog_flags` array is built using `printf '%s' "${INPUT_REVIEWDOG_FLAGS}" | xargs printf '%s\0'` with a NUL-delimited read loop, guarded by `if [ -n "${INPUT_REVIEWDOG_FLAGS}" ]` to prevent empty-token issues. The array is then expanded as `"${reviewdog_flags[@]}"` in the reviewdog invocation. Bash array syntax is valid here because the script is sourced by the `shell: bash` step in action.yml.

