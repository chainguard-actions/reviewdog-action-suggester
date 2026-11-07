<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-suggester/v1.27.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-suggester/v1.27.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

A composite action step in action.yml uses an action by version tag instead of a full 40-character commit SHA: `uses: reviewdog/action-setup@v1.5.0`. Whoever controls that tag can point it at different code. Pin it to a commit SHA.

Locations:

- `action.yml:56`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses

**Notes:**

Pinned reviewdog/action-setup@v1.5.0 to d8a7baabd7f3e8544ee4dbde3ee41d0011c3a93f # v1.5.0 in action.yml.

