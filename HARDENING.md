<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.23.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-suggester/v1.23.1** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

install.sh downloads a remote install script via curl or wget and pipes it directly to `sh` for execution: `) | sh -s -- -b "${TEMP}/reviewdog/bin" "${VERSION}" 2>&1`. This is the classic 'curl | sh' anti-pattern — if the remote URL or the content served at it is compromised, arbitrary code executes on the runner. The script is sourced directly from action.yml's run: block.

Locations:

- `install.sh:30`
- `action.yml:55`

### script-injection (severity: high)

Rule (b) violation: script.sh uses the unquoted shell expansion `${INPUT_REVIEWDOG_FLAGS}` directly in a shell command. INPUT_REVIEWDOG_FLAGS is populated from `inputs.reviewdog_flags` (an attacker-controllable composite action input) via the env: block in action.yml. Because the variable is unquoted, the shell will perform word-splitting and glob expansion on its value, allowing an attacker to inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) and achieve command injection. The comment `# INPUT_REVIEWDOG_FLAGS is intentionally split` acknowledges the unquoting but does not mitigate the injection risk.

Locations:

- `script.sh:20`
- `action.yml:73`

### missing-permissions (severity: medium)

None of the four workflow files define a top-level `permissions:` key, and no individual job within any of these files defines its own `permissions:` block. Without explicit permissions, workflows run with the repository's default token permissions, which may be overly broad (e.g., write access to contents, pull-requests, etc.). All four files are affected: depup.yml, release.yml, reviewdog.yml, and test.yml.

Locations:

- `.github/workflows/depup.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/reviewdog.yml:1`
- `.github/workflows/test.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection, missing-permissions

**Notes:**

1. install.sh: Fixed curl|sh anti-pattern by downloading the install script to a temp file first (curl -o / wget -O), then executing it with 'sh "${INSTALL_SCRIPT_FILE}"', and cleaning up afterward. 2. script.sh: Fixed unquoted ${INPUT_REVIEWDOG_FLAGS} by changing shebang to bash, building a bash array with 'IFS=" " read -ra reviewdog_flags <<< "${INPUT_REVIEWDOG_FLAGS}"' with 'set -f' to disable glob expansion, and passing '"${reviewdog_flags[@]}"' to reviewdog. 3. Added permissions blocks to all four workflow files: depup.yml (contents: write, pull-requests: write), release.yml (contents: write, pull-requests: write), reviewdog.yml (contents: read, pull-requests: write, checks: write), test.yml (contents: read, pull-requests: write).

