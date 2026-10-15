#!/usr/bin/env bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$PROJECT_DIR/dist"
FLATPAK_DIR="$PROJECT_DIR/flatpak"
APP_ID="com.h.baddil"

echo "=== Building Flatpak for $APP_ID ==="

mkdir -p "$DIST_DIR"

if ! command -v flatpak-builder &> /dev/null; then
    echo "ERROR: 'flatpak-builder' command not found."
    echo "Please install flatpak-builder (e.g. sudo apt install flatpak-builder) to create .flatpak packages."
    exit 1
fi

if [ ! -d "$PROJECT_DIR/build/linux/x64/release/bundle" ]; then
    echo "Building Flutter Linux release bundle first..."
    flutter build linux --release
fi

BUILD_DIR="$PROJECT_DIR/build/flatpak_build"
REPO_DIR="$PROJECT_DIR/build/flatpak_repo"
mkdir -p "$BUILD_DIR" "$REPO_DIR"

cd "$FLATPAK_DIR"
flatpak-builder --force-clean --repo="$REPO_DIR" "$BUILD_DIR" "$APP_ID.json"
flatpak build-bundle "$REPO_DIR" "$DIST_DIR/$APP_ID.flatpak" "$APP_ID"

echo "=== Flatpak bundle generated at $DIST_DIR/$APP_ID.flatpak ==="
