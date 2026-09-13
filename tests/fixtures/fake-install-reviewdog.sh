#!/bin/sh
# Fake reviewdog install script
# Usage: sh fake-install-reviewdog.sh -b <bindir> [version]
# Installs a fake reviewdog binary to the specified directory

BINDIR="/usr/local/bin"
while [ $# -gt 0 ]; do
  case "$1" in
    -b)
      BINDIR="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

mkdir -p "$BINDIR"
cat > "$BINDIR/reviewdog" << 'FAKE_REVIEWDOG'
#!/bin/sh
# Fake reviewdog binary
while [ $# -gt 0 ]; do
  shift
done
cat > /dev/null
echo "fake-reviewdog: ran successfully"
exit 0
FAKE_REVIEWDOG
chmod +x "$BINDIR/reviewdog"
echo "Installed fake reviewdog to $BINDIR/reviewdog"
