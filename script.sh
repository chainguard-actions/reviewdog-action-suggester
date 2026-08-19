#!/bin/bash
set -euo pipefail

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

TMPFILE=$(mktemp)
git diff >"${TMPFILE}"

git stash -u

# Build reviewdog_flags as an array to safely handle multiple flags
# without allowing shell metacharacter injection
reviewdog_flags=()
if [ -n "${INPUT_REVIEWDOG_FLAGS}" ]; then
  while IFS= read -r -d '' flag; do
    reviewdog_flags+=("$flag")
  done < <(xargs printf '%s\0' <<<"${INPUT_REVIEWDOG_FLAGS}")
fi

reviewdog \
  -name="${INPUT_TOOL_NAME:-reviewdog-suggester}" \
  -f=diff \
  -f.diff.strip=1 \
  -reporter="github-pr-review" \
  -filter-mode="${INPUT_FILTER_MODE}" \
  -fail-level="${INPUT_FAIL_LEVEL}" \
  -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
  -level="${INPUT_LEVEL}" \
  "${reviewdog_flags[@]}" <"${TMPFILE}"

EXIT_CODE=$?

if [ "${INPUT_CLEANUP}" = "true" ]; then
  git stash drop || true
else
  git stash pop || true
fi

exit "${EXIT_CODE}"
