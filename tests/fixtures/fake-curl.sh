#!/bin/sh
# Fake curl: intercepts reviewdog install script URL
# Supports both pipe form (stdout) and -o FILE form
out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -o|--output) out="$arg" ;;
  esac
  prev="$arg"
done
case "$*" in
  *reviewdog*)
    if [ -n "$out" ]; then
      cat "$GITHUB_WORKSPACE/tests/fixtures/fake-install-reviewdog.sh" > "$out"
    else
      cat "$GITHUB_WORKSPACE/tests/fixtures/fake-install-reviewdog.sh"
    fi
    exit 0
    ;;
esac
exec /usr/bin/curl "$@"
