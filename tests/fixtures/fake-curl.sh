#!/bin/sh
# Fake curl: serve a canned payload for reviewdog download URLs, supporting both
# "curl URL | sh" (payload to stdout) and the hardened "curl -o FILE URL"
# (payload written to FILE). A stdout-only mock breaks the hardened action.
#
# Falls through to the real curl (saved as /usr/bin/curl.real) for other URLs.

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
      cat /tmp/fake-install-reviewdog.sh > "$out"
    else
      cat /tmp/fake-install-reviewdog.sh
    fi
    exit 0
    ;;
esac

# Fall through to real curl for other URLs
# Use curl.real if available (when we've replaced /usr/bin/curl), otherwise /usr/bin/curl
if [ -x /usr/bin/curl.real ]; then
  exec /usr/bin/curl.real "$@"
else
  exec /usr/bin/curl "$@"
fi
