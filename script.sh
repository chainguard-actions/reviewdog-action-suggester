#!/bin/bash
set -e

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

TMPFILE=$(mktemp)
git diff >"${TMPFILE}"

git stash -u

# Safely split INPUT_REVIEWDOG_FLAGS into an array to avoid shell metacharacter
# injection from user-controlled input. Using a bash array prevents the shell
# from interpreting metacharacters (;, |, &, $(...), etc.) in the flag values.
REVIEWDOG_FLAGS=()
if [ -n "${INPUT_REVIEWDOG_FLAGS}" ]; then
  IFS=' ' read -r -a REVIEWDOG_FLAGS <<< "${INPUT_REVIEWDOG_FLAGS}"
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
  "${REVIEWDOG_FLAGS[@]+"${REVIEWDOG_FLAGS[@]}"}" \
  <"${TMPFILE}"

EXIT_CODE=$?

if [ "${INPUT_CLEANUP}" = "true" ]; then
  git stash drop || true
else
  git stash pop || true
fi

exit "${EXIT_CODE}"
