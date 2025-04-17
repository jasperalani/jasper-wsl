#!/usr/bin/env bash
# ===============================================
# uninstall-golang.sh
#
# This script safely uninstalls a Go installation from your system.
#
# What this script does:
#  • Parses optional flags:
#    • -l, --location: Specify custom Go installation directory (default: /usr/local/go)
#    • -v, --verbose: Enable verbose output
#  • Checks if Go is installed at the specified location
#    • Prints Go version and lists binaries if verbose
#  • Prompts the user for confirmation to uninstall Go
#    • If confirmed:
#      • Deletes the Go installation directory (with sudo)
#      • Removes symlinks to Go binaries from /usr/local/bin
#    • If declined: Skips uninstallation
#  • Reloads ~/.bashrc (with --skipGoInstall flag)
#  • Prints completion message (and timing if verbose)
# ===============================================
set -e

GO_INSTALLED_LOC="/usr/local/go"
PROFILE_FILE="$HOME/.profile"
VERBOSE=0

# Parse flags
while [[ $# -gt 0 ]]; do
    case $1 in
    -l | --location)
        GO_INSTALLED_LOC="$2"
        shift 2
        ;;
    -v | --verbose)
        VERBOSE=1
        shift
        ;;
    *)
        echo "Usage: $0 [-l go_install_location] [-v|--verbose]"
        exit 1
        ;;
    esac
done

if [[ $VERBOSE -eq 1 ]]; then
    echo "[VERBOSE] GO_INSTALLED_LOC: $GO_INSTALLED_LOC"
    echo "[VERBOSE] PROFILE_FILE: $PROFILE_FILE"
    echo "[VERBOSE] Script started at: $(date)"
fi

# Check if Go is installed at GO_INSTALLED_LOC
if [ -x "$GO_INSTALLED_LOC/bin/go" ]; then
    GO_VERSION=$($GO_INSTALLED_LOC/bin/go version)
    if [[ $VERBOSE -eq 1 ]]; then
        echo "Found Go installation $GO_VERSION at $GO_INSTALLED_LOC"
        echo "[VERBOSE] Listing Go binaries in $GO_INSTALLED_LOC/bin:"
        ls -l "$GO_INSTALLED_LOC/bin"
    else
        echo "Found Go installation $GO_VERSION"
    fi
else
    echo -e "No Go installation found at $GO_INSTALLED_LOC.\nSpecify a different location with the -l flag."
    if [[ $VERBOSE -eq 1 ]]; then
        echo "[VERBOSE] Directory contents of /usr/local:"
        ls -l /usr/local
    fi
    exit 0
fi

read -p "Uninstall $GO_VERSION [y/N] " yn
case $yn in
[Yy]*)
    # Delete Go installation
    echo "Deleting $GO_INSTALLED_LOC"
    if [[ $VERBOSE -eq 1 ]]; then
        echo "[VERBOSE] Removing $GO_INSTALLED_LOC and all its contents."
    fi
    sudo rm -rf "$GO_INSTALLED_LOC"

    # Remove Go symlinks in /usr/local/bin
    for exe in "/usr/local/go/bin"/*; do
        if [ -f "$exe" ] && [ -x "$exe" ]; then
            SYMLINK="/usr/local/bin/$(basename "$exe")"
            if [ -L "$SYMLINK" ] && [ "$(readlink -f "$SYMLINK")" = "$exe" ]; then
                echo "Removing symlink $SYMLINK"
                if [[ $VERBOSE -eq 1 ]]; then
                    echo "[VERBOSE] Symlink $SYMLINK points to $exe, removing."
                fi
                sudo rm -f "$SYMLINK"
            elif [[ $VERBOSE -eq 1 ]]; then
                echo "[VERBOSE] $SYMLINK is not a symlink to $exe, skipping."
            fi
        elif [[ $VERBOSE -eq 1 ]]; then
            echo "[VERBOSE] $exe is not a file or not executable, skipping."
        fi
    done

    ;;
*)
    echo "Skipping Go uninstallation."
    if [[ $VERBOSE -eq 1 ]]; then
        echo "[VERBOSE] No changes made."
    fi
    ;;
esac

# Reload bashrc/profile
if [[ $VERBOSE -eq 1 ]]; then
    echo "[VERBOSE] Reloading ~/.bashrc with --skipGoInstall flag."
fi
source ~/.bashrc --skipGoInstall

echo "Go uninstalled"
if [[ $VERBOSE -eq 1 ]]; then
    echo "[VERBOSE] Script finished at: $(date)"
fi
