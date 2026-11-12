<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.27.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-suggester/v1.27.1** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b): script.sh, which the composite run step in action.yml sources, expands the workflow-controlled input INPUT_REVIEWDOG_FLAGS (from `${{ inputs.reviewdog_flags }}`) unquoted, directly as arguments to a command: `  ${INPUT_REVIEWDOG_FLAGS} <"${TMPFILE}"`. The `# shellcheck disable=SC2086` comment sits above the reviewdog command, not above an array assignment of the form NAME=($VAR). So the array-assignment exemption does not apply, and the shell still word-splits and glob-expands the value. Fix: keep the list split but in the hardened form. Add `# shellcheck disable=SC2206` and `reviewdog_flags=(${INPUT_REVIEWDOG_FLAGS})` before the command, then pass `"${reviewdog_flags[@]}"` to reviewdog. The script already runs under bash because the step sources it with shell: bash.

Locations:

- `script.sh:29`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In script.sh, `${INPUT_REVIEWDOG_FLAGS}` was passed to reviewdog unquoted. It now goes into an array first, `reviewdog_flags=(${INPUT_REVIEWDOG_FLAGS})`, with a `# shellcheck disable=SC2206,SC2086` comment above it. That assignment splits on whitespace and expands globs exactly like upstream's unquoted use. reviewdog then gets `${reviewdog_flags[@]+"${reviewdog_flags[@]}"}`. I used this form because the action.yml step runs `set -euo pipefail`, and bash 3.2 on macOS runners reports an empty array as unbound under `set -u`. The script is sourced from a `shell: bash` step, so the arrays run under bash. The `<"${TMPFILE}"` stdin redirect is unchanged, and I did not use xargs.

