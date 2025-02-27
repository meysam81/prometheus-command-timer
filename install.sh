#!/bin/sh

set -eu

DEFAULT_VERSION="${DEFAULT_VERSION:-latest}"
DEFAULT_DIRECTORY="."

usage() {
    echo "Usage: $0 [-d|--directory <directory>] [-v|--version <version>]"
    echo
    echo "Options:"
    echo "  -d, --directory    Directory to download the binary to (default: $DEFAULT_DIRECTORY)"
    echo "  -v, --version      Version to download (default: $DEFAULT_VERSION)"
    echo "  -h, --help         Display this help message"
    exit 1
}

DIRECTORY=$DEFAULT_DIRECTORY
VERSION=$DEFAULT_VERSION

while [ $# -gt 0 ]; do
    case $1 in
        -d|--directory)
            DIRECTORY="$2"
            shift 2
        ;;
        -v|--version)
            VERSION="$2"
            shift 2
        ;;
        -h|--help)
            usage
        ;;
        *)
            echo "Unknown option: $1"
            usage
        ;;
    esac
done


mkdir -p "$DIRECTORY"


OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)


case $ARCH in
    x86_64)
        ARCH="x86_64"
    ;;
    amd64)
        ARCH="x86_64"
    ;;
    arm64)
        ARCH="arm64"
    ;;
    aarch64)
        ARCH="arm64"
    ;;
    i386|i686)
        ARCH="i386"
    ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
    ;;
esac


case $OS in
    mingw*|msys*|cygwin*)
        OS="windows"
        FILE_EXT="zip"
    ;;
    darwin)
        OS="darwin"
        FILE_EXT="tar.gz"
    ;;
    linux)
        OS="linux"
        FILE_EXT="tar.gz"
    ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
    ;;
esac

ASSET_NAME="prometheus-command-timer_${OS}_${ARCH}.${FILE_EXT}"


if [ "$VERSION" = "latest" ]; then
    DOWNLOAD_URL="https://github.com/meysam81/prometheus-command-timer/releases/latest/download/$ASSET_NAME"
else
    DOWNLOAD_URL="https://github.com/meysam81/prometheus-command-timer/releases/download/$VERSION/$ASSET_NAME"
fi

echo "Downloading prometheus-command-timer binary..."
echo "OS: $OS"
echo "Architecture: $ARCH"
echo "Version: $VERSION"
echo "Download URL: $DOWNLOAD_URL"
echo "Destination directory: $DIRECTORY"

DIRECTORY=${DIRECTORY%/}

if ! wget -q -O "$DIRECTORY/$ASSET_NAME" "$DOWNLOAD_URL"; then
    echo "Download failed!"
    exit 1
fi

echo "Extracting file..."
cd "$DIRECTORY" || exit 1

if [ "$FILE_EXT" = "zip" ]; then
    if ! command -v unzip >/dev/null 2>&1; then
        echo "unzip is not installed. Please install it to extract zip files."
        exit 1
    fi
    unzip -o "$ASSET_NAME"
else
    tar -xzf "$ASSET_NAME"
fi


rm "$ASSET_NAME"

"$DIRECTORY/prometheus-command-timer" -version

echo "Installation complete! Executable binary is available in $DIRECTORY/prometheus-command-timer"
