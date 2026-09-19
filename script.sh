#!/bin/sh
set -e

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

if [ -n "${INPUT_PATH}" ]; then
  cd "${INPUT_PATH}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

TMPFILE=$(mktemp)
git diff >"${TMPFILE}"

git stash -u

# Safely tokenize INPUT_REVIEWDOG_FLAGS into an array to prevent shell injection.
# xargs handles quoted strings and whitespace correctly, matching how the shell
# would split an unquoted expansion, but without evaluating metacharacters.
reviewdog_flags=()
if [ -n "${INPUT_REVIEWDOG_FLAGS}" ]; then
  while IFS= read -r -d '' t; do reviewdog_flags+=("$t"); done \
    < <(printf '%s' "${INPUT_REVIEWDOG_FLAGS}" | xargs printf '%s\0')
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
