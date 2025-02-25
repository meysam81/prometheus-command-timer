#!/bin/sh





set -e

INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
VERSION="latest"
GITHUB_REPO="prometheus-command-timer"
GITHUB_USER="meysam81"  # Change this to your GitHub username
BINARY_NAME="prometheus-command-timer"
FORCE=0


usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Downloads the correct binary architecture for prometheus-command-timer.

Options:
  -d, --directory DIR    Installation directory (default: /usr/local/bin)
  -v, --version VERSION  Version to install (default: latest)
  -u, --user USERNAME    GitHub username (default: meysam81)
  -r, --repo REPO        GitHub repository name (default: prometheus-command-timer)
  -f, --force            Force overwrite if binary already exists
  -h, --help             Show this help message

Examples:
  $(basename "$0") --version v1.0.0
  $(basename "$0") --directory /opt/bin --force
EOF
}


while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
        ;;
        -d|--directory)
            INSTALL_DIR="$2"
            shift 2
        ;;
        -v|--version)
            VERSION="$2"
            shift 2
        ;;
        -u|--user)
            GITHUB_USER="$2"
            shift 2
        ;;
        -r|--repo)
            GITHUB_REPO="$2"
            shift 2
        ;;
        -f|--force)
            FORCE=1
            shift
        ;;
        *)
            echo "Error: Unknown option $1" >&2
            usage >&2
            exit 1
        ;;
    esac
done

if [ ! -d "$INSTALL_DIR" ]; then
    echo "Creating installation directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR" || { echo "Error: Failed to create directory $INSTALL_DIR"; exit 1; }
fi

if [ ! -w "$INSTALL_DIR" ]; then
    echo "Error: No write permission to $INSTALL_DIR" >&2
    echo "Try running with sudo or specify a different directory with --directory" >&2
    exit 1
fi

detect_arch() {
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64|amd64)
            ARCH="amd64"
        ;;
        i386|i686)
            ARCH="386"
        ;;
        armv7l|armv7)
            ARCH="arm"
        ;;
        armv6l|armv6)
            ARCH="arm"
        ;;
        aarch64|arm64)
            ARCH="arm64"
        ;;
        *)
            echo "Error: Unsupported architecture: $ARCH" >&2
            exit 1
        ;;
    esac

    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    case "$OS" in
        linux)
            OS="linux"
        ;;
        darwin)
            OS="darwin"
        ;;
        freebsd)
            OS="freebsd"
        ;;
        *)
            echo "Error: Unsupported operating system: $OS" >&2
            exit 1
        ;;
    esac

    echo "Detected system: $OS $ARCH"
}


get_latest_version() {
    if [ "$VERSION" = "latest" ]; then
        echo "Fetching latest release version..."

        VERSION=$(wget -qO- "https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/releases/latest" |
            grep '"tag_name":' |
        sed -E 's/.*"([^"]+)".*/\1/')

        if [ -z "$VERSION" ]; then
            echo "Error: Failed to fetch latest version" >&2
            exit 1
        fi
        echo "Latest version is $VERSION"
    fi
}


download_binary() {
    BINARY_PATH="$INSTALL_DIR/$BINARY_NAME"


    if [ -f "$BINARY_PATH" ] && [ "$FORCE" -ne 1 ]; then
        echo "Error: Binary already exists at $BINARY_PATH" >&2
        echo "Use --force to overwrite" >&2
        exit 1
    fi

    #DL_VERSION="${VERSION#v}"

    DOWNLOAD_URL="https://github.com/$GITHUB_USER/$GITHUB_REPO/releases/download/$VERSION/${BINARY_NAME}_${OS}_${ARCH}.tar.gz"

    echo "Downloading from: $DOWNLOAD_URL"


    TMP_DIR=$(mktemp -d)
    if [ ! -d "$TMP_DIR" ]; then
        echo "Error: Failed to create temporary directory" >&2
        exit 1
    fi


    ARCHIVE="$TMP_DIR/archive.tar.gz"
    if ! wget -q "$DOWNLOAD_URL" -O "$ARCHIVE"; then
        echo "Error: Failed to download binary" >&2
        rm -rf "$TMP_DIR"
        exit 1
    fi


    if ! tar -xzf "$ARCHIVE" -C "$TMP_DIR"; then
        echo "Error: Failed to extract archive" >&2
        rm -rf "$TMP_DIR"
        exit 1
    fi


    find "$TMP_DIR" -type f -name "$BINARY_NAME" | while read -r file; do
        if cp "$file" "$BINARY_PATH"; then
            chmod +x "$BINARY_PATH"
            echo "Successfully installed $BINARY_NAME to $BINARY_PATH"
            break
        else
            echo "Error: Failed to install binary" >&2
            rm -rf "$TMP_DIR"
            exit 1
        fi
    done


    rm -rf "$TMP_DIR"


    if [ -x "$BINARY_PATH" ]; then
        echo "Installation completed successfully"
        echo "You can now use $BINARY_PATH"
    else
        echo "Error: Installation failed" >&2
        exit 1
    fi
}

verify_installation() {
    if command -v "$BINARY_NAME" >/dev/null; then
        echo "Installation verified: $BINARY_NAME"
        "$BINARY_NAME" --version
    else
        echo "Error: $BINARY_NAME is not in PATH" >&2
        exit 1
    fi
}


detect_arch
get_latest_version
download_binary
verify_installation

exit 0
