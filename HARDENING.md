<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.22.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **reviewdog--action-suggester/v1.22.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

install.sh pipes the output of a remote URL directly to `sh` without first saving it to a file for inspection. Both the curl and wget branches feed into `| sh -s -- ...` on line 30. Even though the URL is pinned to a specific commit SHA in the path, this pattern is inherently unsafe: if the remote server is compromised or the URL is redirected, arbitrary code executes on the runner. The script should download the installer to a temporary file, verify its integrity (e.g. checksum), and then execute it separately.

Locations:

- `install.sh:30`

### script-injection (severity: high)

Rule (b) violation in script.sh line 24: the shell variable `${INPUT_REVIEWDOG_FLAGS}` is expanded **unquoted** inside the `reviewdog` command invocation. `INPUT_REVIEWDOG_FLAGS` is set from `${{ inputs.reviewdog_flags }}` (a user-controlled action input) in action.yml's `env:` block. An unquoted expansion allows the shell to parse metacharacters (`;`, `|`, `&`, `$(...)`, glob chars, whitespace) out of the value, enabling command injection. The offending line is: `  ${INPUT_REVIEWDOG_FLAGS} <"${TMPFILE}"`. While the `# shellcheck disable=SC2086` comment indicates intentional word-splitting, this does not mitigate the injection risk from attacker-supplied input.

Locations:

- `script.sh:24`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed two high-severity findings:

1. unsafe-shell (install.sh): Replaced the `(curl|wget) | sh -s -- ...` pipe-to-shell pattern with a download-then-execute approach. The installer is now saved to a temp file via `curl -sfL ... -o INSTALLER_TMP` or `wget -O INSTALLER_TMP ...`, then executed separately with `sh "${INSTALLER_TMP}"`, and the temp file is cleaned up afterward.

2. script-injection (script.sh): Replaced the unquoted `${INPUT_REVIEWDOG_FLAGS}` expansion (which allowed shell metacharacter injection from user-controlled input) with a bash array. Uses `IFS=' ' read -r -a REVIEWDOG_FLAGS <<< "${INPUT_REVIEWDOG_FLAGS}"` to safely split flags, then passes `"${REVIEWDOG_FLAGS[@]+"${REVIEWDOG_FLAGS[@]}"}"` to reviewdog. The empty-array guard (`${var[@]+...}`) ensures no spurious empty argument is passed when the input is empty. Updated shebang to `#!/bin/bash` since action.yml already runs the script under bash.

