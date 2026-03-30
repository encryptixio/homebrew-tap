#!/bin/sh
# Encryptix CLI installer
# Usage: curl -sSfL https://raw.githubusercontent.com/encryptixio/homebrew-tap/main/install.sh | sh
set -e

REPO="encryptixio/homebrew-tap"
BINARY="enx"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

# Detect OS and architecture
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$OS" in
  linux)  OS="linux" ;;
  darwin) OS="darwin" ;;
  *)
    echo "Error: unsupported OS: $OS" >&2
    exit 1
    ;;
esac

case "$ARCH" in
  x86_64|amd64)   ARCH="amd64" ;;
  aarch64|arm64)   ARCH="arm64" ;;
  *)
    echo "Error: unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

ARTIFACT="${BINARY}-${OS}-${ARCH}"

# Get latest release tag
if [ -z "$VERSION" ]; then
  VERSION="$(curl -sSf "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep '"tag_name"' \
    | head -1 \
    | sed 's/.*"tag_name": *"enx-v\([^"]*\)".*/\1/')"
fi

if [ -z "$VERSION" ]; then
  echo "Error: could not determine latest version" >&2
  exit 1
fi

URL="https://github.com/${REPO}/releases/download/enx-v${VERSION}/${ARTIFACT}.tar.gz"

echo "Installing enx v${VERSION} (${OS}/${ARCH})..."

# Download and extract
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

curl -sSfL "$URL" -o "${TMPDIR}/${ARTIFACT}.tar.gz"
tar xzf "${TMPDIR}/${ARTIFACT}.tar.gz" -C "$TMPDIR"
chmod +x "${TMPDIR}/${ARTIFACT}"

# Install
if [ -w "$INSTALL_DIR" ]; then
  mv "${TMPDIR}/${ARTIFACT}" "${INSTALL_DIR}/${BINARY}"
else
  echo "Installing to ${INSTALL_DIR} (requires sudo)..."
  sudo mv "${TMPDIR}/${ARTIFACT}" "${INSTALL_DIR}/${BINARY}"
fi

echo "Installed enx v${VERSION} to ${INSTALL_DIR}/${BINARY}"
echo ""
echo "Get started:"
echo "  enx login"
echo "  enx ssh root@<device-name>"
echo "  enx --help"
