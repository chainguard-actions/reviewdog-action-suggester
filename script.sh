#!/bin/bash
set -e

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

TMPFILE=$(mktemp)
git diff >"${TMPFILE}"

git stash -u

# Split INPUT_REVIEWDOG_FLAGS into an array using read -ra to safely handle
# multiple flags without unquoted expansion that could allow shell injection.
REVIEWDOG_FLAGS_ARRAY=()
if [ -n "${INPUT_REVIEWDOG_FLAGS}" ]; then
  read -ra REVIEWDOG_FLAGS_ARRAY <<< "${INPUT_REVIEWDOG_FLAGS}"
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
  "${REVIEWDOG_FLAGS_ARRAY[@]+"${REVIEWDOG_FLAGS_ARRAY[@]}"}" <"${TMPFILE}"

EXIT_CODE=$?

if [ "${INPUT_CLEANUP}" = "true" ]; then
  git stash drop || true
else
  git stash pop || true
fi

exit "${EXIT_CODE}"
