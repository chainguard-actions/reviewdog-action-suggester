#!/bin/sh

set -eu

VERSION="${REVIEWDOG_VERSION:-latest}"

TEMP="${REVIEWDOG_TEMPDIR}"
if [ -z "${TEMP}" ]; then
  if [ -n "${RUNNER_TEMP}" ]; then
    TEMP="${RUNNER_TEMP}"
  else
    TEMP="$(mktemp -d)"
  fi
fi

INSTALL_SCRIPT='https://raw.githubusercontent.com/reviewdog/reviewdog/df70ed74df59de7ebfd9276afabd62ea2de4d7dd/install.sh'
if [ "${VERSION}" = 'nightly' ]; then
  INSTALL_SCRIPT='https://raw.githubusercontent.com/reviewdog/nightly/a41f181a20068bf2c0499054e4c19bdebc71b362/install.sh'
  VERSION='latest'
fi

mkdir -p "${TEMP}/reviewdog/bin"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
INSTALL_SCRIPT_FILE="$(mktemp)"
if command -v curl 2>&1 >/dev/null; then
  curl -sfL "${INSTALL_SCRIPT}" -o "${INSTALL_SCRIPT_FILE}"
elif command -v wget 2>&1 >/dev/null; then
  wget -O "${INSTALL_SCRIPT_FILE}" "${INSTALL_SCRIPT}"
else
  echo "curl or wget is required" >&2
  exit 1
fi
sh "${INSTALL_SCRIPT_FILE}" -b "${TEMP}/reviewdog/bin" "${VERSION}" 2>&1
rm -f "${INSTALL_SCRIPT_FILE}"
echo '::endgroup::'

echo "${TEMP}/reviewdog/bin" >>"${GITHUB_PATH}"
