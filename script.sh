#!/bin/bash
set -e

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

TMPFILE=$(mktemp)
git diff >"${TMPFILE}"

git stash -u

# Build reviewdog_flags as a bash array to safely handle multiple flags.
# IFS word-splitting is intentional here to split space-separated flags,
# but glob expansion is disabled with 'set -f' to prevent injection.
reviewdog_flags=()
if [ -n "${INPUT_REVIEWDOG_FLAGS}" ]; then
  set -f  # disable glob expansion
  # shellcheck disable=SC2206
  IFS=' ' read -ra reviewdog_flags <<< "${INPUT_REVIEWDOG_FLAGS}"
  set +f  # re-enable glob expansion
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
