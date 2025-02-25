#!/bin/sh

set -eu

parent_dir="$(dirname "${INSTALL_PATH}")"
mkdir -p "$parent_dir"

wget "${URL}" -qO "${INSTALL_PATH}"

chmod +x "${INSTALL_PATH}"

echo "Installed to ${INSTALL_PATH}"

"${INSTALL_PATH}" --help
