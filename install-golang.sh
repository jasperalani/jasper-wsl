#!/usr/bin/env bash
# ===============================================
# install-golang.sh
#
# This script safely installs the latest Go version for Linux amd64.
#
# What this script does:
#  • Parses optional flags:
#    • -v, --verbose: Enable verbose output
#  • Determines the latest Go tarball URL for Linux amd64
#    • Downloads the tarball to /tmp if not already present
#  • Removes any previous Go installation at /usr/local/go
#  • Extracts the new Go distribution to /usr/local
#  • Adds symlinks for Go executables to /usr/local/bin
#  • Reloads ~/.bashrc (with --skipGoInstall flag)
#  • Prints Go version and completion message (and timing if verbose)
# ===============================================
set -e

# Variables
GO_DL_URL="https://go.dev/dl/"
INSTALL_DIR="/usr/local"
PROFILE_FILE="$HOME/.profile"
GO_USER_BIN="/usr/local/go/bin"
VERBOSE=0

# Parse flags
while [[ $# -gt 0 ]]; do
    case $1 in
    -v | --verbose)
        VERBOSE=1
        shift
        ;;
    *)
        break
        ;;
    esac
done

if [[ $VERBOSE -eq 1 ]]; then
    echo "[VERBOSE] Starting Go installation script at: $(date)"
    echo "[VERBOSE] GO_DL_URL: $GO_DL_URL"
    echo "[VERBOSE] INSTALL_DIR: $INSTALL_DIR"
    echo "[VERBOSE] PROFILE_FILE: $PROFILE_FILE"
    echo "[VERBOSE] GO_USER_BIN: $GO_USER_BIN"
fi

# Get latest Go tarball URL for Linux amd64
TARBALL_URL=$(curl -s "$GO_DL_URL" | grep -Eo 'href="\/dl\/go[0-9\.]+\.linux-amd64\.tar\.gz"' | head -n1 | cut -d'"' -f2)
if [ -z "$TARBALL_URL" ]; then
    echo "Could not find the latest Go tarball for Linux amd64."
    exit 1
fi

FULL_URL="https://go.dev$TARBALL_URL"
TARBALL_NAME=$(basename "$TARBALL_URL")
PROJECT_TMP_DIR="/tmp/jwsl"
TARBALL_PATH="$PROJECT_TMP_DIR/$TARBALL_NAME"

if [[ $VERBOSE -eq 1 ]]; then
    echo "[VERBOSE] Go tarball URL: $FULL_URL"
    echo "[VERBOSE] Tarball name: $TARBALL_NAME"
    echo "[VERBOSE] Project temp directory: $PROJECT_TMP_DIR"
    echo "[VERBOSE] Tarball path: $TARBALL_PATH"
fi

# Download tarball to /tmp if not already present
if [ ! -d "$PROJECT_TMP_DIR" ]; then
    if [[ $VERBOSE -eq 1 ]]; then
        echo "[VERBOSE] Creating temp directory $PROJECT_TMP_DIR"
    fi
    mkdir -p "$PROJECT_TMP_DIR"
fi

if [ -f "$TARBALL_PATH" ]; then
    echo "$TARBALL_PATH already exists, using cached file."
    if [[ $VERBOSE -eq 1 ]]; then
        ls -lh "$TARBALL_PATH"
    fi
else
    echo "Downloading $FULL_URL to $TARBALL_PATH ..."
    curl -Lo "$TARBALL_PATH" "$FULL_URL"
fi

# Remove any previous Go installation
if [[ $VERBOSE -eq 1 ]]; then
    echo "[VERBOSE] Removing any previous Go installation at $INSTALL_DIR/go"
fi
sudo rm -rf "$INSTALL_DIR/go"

# Extract to /usr/local
if [[ $VERBOSE -eq 1 ]]; then
    echo "[VERBOSE] Extracting $TARBALL_PATH to $INSTALL_DIR"
fi
sudo tar -C "$INSTALL_DIR" -xzf "$TARBALL_PATH"

# Add symlink of Go executables to /usr/local/bin
if [[ $VERBOSE -eq 1 ]]; then
    echo "[VERBOSE] Creating symlinks for Go executables in $GO_USER_BIN to /usr/local/bin"
fi
for exe in "$GO_USER_BIN"/*; do
    if [ -f "$exe" ] && [ -x "$exe" ]; then
        if [[ $VERBOSE -eq 1 ]]; then
            echo "[VERBOSE] Symlinking $exe -> /usr/local/bin/$(basename "$exe")"
        fi
        sudo ln -sf "$exe" "/usr/local/bin/$(basename "$exe")"
    fi
done

# Reload bashrc/profile
if [[ $VERBOSE -eq 1 ]]; then
    echo "[VERBOSE] Reloading ~/.bashrc with --skipGoInstall flag."
fi
source ~/.bashrc --skipGoInstall

echo "Go installation complete, check the version is printed below. "
go version
if [[ $VERBOSE -eq 1 ]]; then
    echo "[VERBOSE] Script finished at: $(date)"
fi