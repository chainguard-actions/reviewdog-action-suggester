#!/bin/sh
# Fake reviewdog binary for testing
# Accepts all flags, reads stdin, exits 0
# This simulates reviewdog running successfully without a real PR context
while [ $# -gt 0 ]; do
  shift
done
# Read and discard stdin
cat > /dev/null
echo "fake-reviewdog: ran successfully (no real PR context needed)"
exit 0
