#!/bin/sh
# Fake reviewdog binary - exits 0, handles -h flag, captures args
case "$*" in
  *-h*) echo "fake reviewdog help"; exit 0 ;;
esac
echo "reviewdog_args: $*" > /tmp/reviewdog-args.txt
echo "reviewdog_cwd: $(pwd)" > /tmp/reviewdog-cwd.txt
echo "fake reviewdog called with: $*"
exit 0
