#!/bin/sh
# Fake reviewdog install script
# Accepts: sh fake-install-reviewdog.sh -b BINDIR VERSION
BINDIR=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -b) BINDIR="$arg" ;;
  esac
  prev="$arg"
done
if [ -z "$BINDIR" ]; then BINDIR="/usr/local/bin"; fi
mkdir -p "$BINDIR"
cp "$GITHUB_WORKSPACE/tests/fixtures/fake-reviewdog.sh" "$BINDIR/reviewdog"
chmod +x "$BINDIR/reviewdog"
echo "Fake reviewdog installed to $BINDIR/reviewdog"
