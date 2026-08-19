#!/bin/bash
set -e

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

TMPFILE=$(mktemp)
git diff >"${TMPFILE}"

git stash -u

# Split INPUT_REVIEWDOG_FLAGS into an array using read -ra to avoid unquoted
# expansion that would allow shell metacharacters (;, |, &, $(...)) to be
# interpreted as shell commands.
reviewdog_flags_args=()
if [ -n "${INPUT_REVIEWDOG_FLAGS}" ]; then
  IFS=' ' read -ra reviewdog_flags_args <<<"${INPUT_REVIEWDOG_FLAGS}"
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
  "${reviewdog_flags_args[@]}" <"${TMPFILE}"

EXIT_CODE=$?

if [ "${INPUT_CLEANUP}" = "true" ]; then
  git stash drop || true
else
  git stash pop || true
fi

exit "${EXIT_CODE}"
