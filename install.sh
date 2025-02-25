#!/bin/sh

set -eu

ARCH=$(uname -m)
case $ARCH in
    aarch64)
        CURL_URL="https://github.com/moparisthebest/static-curl/releases/download/v8.11.0/curl-aarch64"
    ;;
    x86_64)
        CURL_URL="https://github.com/moparisthebest/static-curl/releases/download/v8.11.0/curl-amd64"
    ;;
    *)
        echo "Unsupported arch: $ARCH"
        exit 1
    ;;
esac

mkdir -p "$INSTALL_DIR"

filename="${INSTALL_DIR}/prometheus-command-timer"
wget "${URL}" -qO "$filename"
chmod +x "$filename"
echo "Installed to $filename"

wget "$CURL_URL" -qO "${INSTALL_DIR}/curl"
chmod +x "${INSTALL_DIR}/curl"

"$filename" --help
"${INSTALL_DIR}/curl" --version
