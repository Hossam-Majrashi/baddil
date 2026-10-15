#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"
DIST_DIR="$PROJECT_DIR/dist"
APP_NAME="baddil"
APP_ID="com.h.baddil"

echo "=== Building Linux Distributions for $APP_NAME ($APP_ID) ==="

# Extract version from pubspec.yaml
VERSION=$(grep -m 1 "^version: " "$PROJECT_DIR/pubspec.yaml" | awk '{print $2}' | cut -d'+' -f1)
if [ -z "$VERSION" ]; then
    VERSION="1.0.0"
fi
echo "Target Version: $VERSION"

ARCH="$(uname -m)"
case "$ARCH" in
    x86_64)
        FLUTTER_ARCH="x64"
        PKG_ARCH_DEB="amd64"
        PKG_ARCH_RPM="x86_64"
        PKG_ARCH_ARCH="x86_64"
        ;;
    aarch64|arm64)
        FLUTTER_ARCH="arm64"
        PKG_ARCH_DEB="arm64"
        PKG_ARCH_RPM="aarch64"
        PKG_ARCH_ARCH="aarch64"
        ;;
    *)
        echo "ERROR: Unsupported Linux packaging architecture: $ARCH" >&2
        exit 1
        ;;
esac

mkdir -p "$DIST_DIR"

# Always rebuild from the current sources. An existing bundle may contain an
# older release; flutter run builds a separate debug bundle, not this one.
BUNDLE_DIR="$PROJECT_DIR/build/linux/$FLUTTER_ARCH/release/bundle"
echo "--> Generating localizations and compiling current Flutter Linux release..."
flutter gen-l10n
flutter build linux --release --target-platform="linux-$FLUTTER_ARCH"

# Never package a stale or incomplete bundle after a failed build.
if [ ! -x "$BUNDLE_DIR/$APP_NAME" ] || [ ! -f "$BUNDLE_DIR/lib/libapp.so" ]; then
    echo "ERROR: Flutter release bundle is incomplete: $BUNDLE_DIR" >&2
    exit 1
fi

STAGING_DIR="$PROJECT_DIR/build/staging_linux"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR/usr/lib/$APP_NAME"
mkdir -p "$STAGING_DIR/usr/bin"
mkdir -p "$STAGING_DIR/usr/share/applications"
mkdir -p "$STAGING_DIR/usr/share/pixmaps"
mkdir -p "$STAGING_DIR/usr/share/icons/hicolor"

# Copy bundle
cp -r "$BUNDLE_DIR"/* "$STAGING_DIR/usr/lib/$APP_NAME/"

# Create /usr/bin launcher
cat <<EOF > "$STAGING_DIR/usr/bin/$APP_NAME"
#!/usr/bin/env bash
exec /usr/lib/$APP_NAME/$APP_NAME "\$@"
EOF
chmod +x "$STAGING_DIR/usr/bin/$APP_NAME"

# Copy desktop and icon assets
cp "$PROJECT_DIR/flatpak/com.h.baddil.desktop" "$STAGING_DIR/usr/share/applications/$APP_ID.desktop"
cp "$PROJECT_DIR/flatpak/com.h.baddil.desktop" "$STAGING_DIR/usr/share/applications/$APP_NAME.desktop"

# Copy full hicolor icons hierarchy
cp -r "$PROJECT_DIR/linux/icons/hicolor"/* "$STAGING_DIR/usr/share/icons/hicolor/"

# Copy pixmaps for instant system-wide launcher fallback
cp -r "$PROJECT_DIR/linux/icons/pixmaps"/* "$STAGING_DIR/usr/share/pixmaps/"

# ==========================================
# 1. Build .tar.gz (Universal Archive)
# ==========================================
echo "--> Generating .tar.gz archive..."
TAR_OUT="$DIST_DIR/${APP_NAME}-${VERSION}-${PKG_ARCH_RPM}.tar.gz"
tar -czf "$TAR_OUT" -C "$STAGING_DIR" usr
echo "Generated: $TAR_OUT"

# ==========================================
# 2. Build .deb
# ==========================================
echo "--> Generating .deb package..."
DEB_DIR="$PROJECT_DIR/build/deb_pkg"
rm -rf "$DEB_DIR"
mkdir -p "$DEB_DIR/DEBIAN"
cp -r "$STAGING_DIR/usr" "$DEB_DIR/"

cat <<EOF > "$DEB_DIR/DEBIAN/control"
Package: $APP_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: $PKG_ARCH_DEB
Maintainer: Hossam Majrashi <Hossam.Majrashi@gmail.com>
Description: Local file fingerprint modifier with zero quality loss (بدّل)
 Baddil alters file fingerprints (hash and metadata) 100% locally with zero cloud upload.
EOF

if command -v dpkg-deb &> /dev/null; then
    dpkg-deb --build --root-owner-group "$DEB_DIR" "$DIST_DIR/${APP_NAME}_${VERSION}_${PKG_ARCH_DEB}.deb"
    echo "Generated: $DIST_DIR/${APP_NAME}_${VERSION}_${PKG_ARCH_DEB}.deb"
elif command -v fpm &> /dev/null; then
    fpm --force -s dir -t deb -n "$APP_NAME" -v "$VERSION" -a "$PKG_ARCH_DEB" \
        -p "$DIST_DIR/${APP_NAME}_${VERSION}_${PKG_ARCH_DEB}.deb" \
        -C "$STAGING_DIR" usr
    echo "Generated: $DIST_DIR/${APP_NAME}_${VERSION}_${PKG_ARCH_DEB}.deb"
else
    echo "WARNING: Neither dpkg-deb nor fpm found. Skipping .deb packaging."
fi

# ==========================================
# 3. Build .rpm
# ==========================================
echo "--> Generating .rpm package..."
if command -v fpm &> /dev/null; then
    fpm --force -s dir -t rpm -n "$APP_NAME" -v "$VERSION" -a "$PKG_ARCH_RPM" \
        --description "Local file fingerprint modifier with zero quality loss" \
        --license "Proprietary" \
        --url "https://hossam-majrashi.github.io/Works/" \
        --maintainer "Hossam Majrashi <Hossam.Majrashi@gmail.com>" \
        -p "$DIST_DIR/${APP_NAME}-${VERSION}-${PKG_ARCH_RPM}.rpm" \
        -C "$STAGING_DIR" usr
    echo "Generated: $DIST_DIR/${APP_NAME}-${VERSION}-${PKG_ARCH_RPM}.rpm"
elif command -v rpmbuild &> /dev/null; then
    RPM_TOP="$PROJECT_DIR/build/rpmbuild"
    rm -rf "$RPM_TOP"
    mkdir -p "$RPM_TOP"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
    cat <<EOF > "$RPM_TOP/SPECS/$APP_NAME.spec"
Name:           $APP_NAME
Version:        $VERSION
Release:        1%{?dist}
Summary:        Local file fingerprint modifier with zero quality loss
License:        Proprietary
BuildArch:      $PKG_ARCH_RPM

%description
Baddil alters file fingerprints (hash and metadata) 100% locally with zero cloud upload.

%install
mkdir -p "%{buildroot}"
cp -r "$STAGING_DIR/usr" "%{buildroot}/"

%files
/usr/bin/$APP_NAME
/usr/lib/$APP_NAME/*
/usr/share/applications/*
/usr/share/pixmaps/*
/usr/share/icons/hicolor/*/apps/*
EOF
    rpmbuild --define "_topdir $RPM_TOP" -bb "$RPM_TOP/SPECS/$APP_NAME.spec"
    cp "$RPM_TOP/RPMS/$PKG_ARCH_RPM"/*.rpm "$DIST_DIR/"
    echo "Generated: $DIST_DIR/*.rpm"
else
    echo "WARNING: Neither fpm nor rpmbuild found. Skipping .rpm packaging."
fi

# ==========================================
# 4. Build .pkg.tar.zst (Arch Linux)
# ==========================================
echo "--> Generating .pkg.tar.zst package..."
ARCH_PKG_DIR="$PROJECT_DIR/build/arch_pkg"
rm -rf "$ARCH_PKG_DIR"
mkdir -p "$ARCH_PKG_DIR"
cp -r "$STAGING_DIR/usr" "$ARCH_PKG_DIR/"

cat <<EOF > "$ARCH_PKG_DIR/.PKGINFO"
pkgname = $APP_NAME
pkgver = $VERSION-1
pkgdesc = Local file fingerprint modifier with zero quality loss
url = https://hossam-majrashi.github.io/Works/
builddate = $(date +%s)
packager = Hossam Majrashi <Hossam.Majrashi@gmail.com>
size = $(du -sb "$STAGING_DIR" | cut -f1)
arch = $PKG_ARCH_ARCH
license = custom
EOF

if command -v zstd &> /dev/null; then
    tar -C "$ARCH_PKG_DIR" -cf - .PKGINFO usr | zstd -f -T0 -19 -o "$DIST_DIR/${APP_NAME}-${VERSION}-1-${PKG_ARCH_ARCH}.pkg.tar.zst"
    echo "Generated: $DIST_DIR/${APP_NAME}-${VERSION}-1-${PKG_ARCH_ARCH}.pkg.tar.zst"
else
    echo "WARNING: zstd command not found. Skipping .pkg.tar.zst packaging."
fi

# ==========================================
# 5. Build AppImage
# ==========================================
echo "--> Generating AppImage..."
APPDIR="$PROJECT_DIR/build/AppDir"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr"
cp -r "$STAGING_DIR/usr"/* "$APPDIR/usr/"

# AppRun script
cat <<'EOF' > "$APPDIR/AppRun"
#!/bin/sh
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib/baddil/lib:${LD_LIBRARY_PATH}"
exec "${HERE}/usr/lib/baddil/baddil" "$@"
EOF
chmod +x "$APPDIR/AppRun"

cp "$PROJECT_DIR/flatpak/com.h.baddil.desktop" "$APPDIR/$APP_ID.desktop"
cp "$PROJECT_DIR/assets/icon/icon.png" "$APPDIR/$APP_ID.png"
cp "$PROJECT_DIR/assets/icon/icon.png" "$APPDIR/$APP_NAME.png"
cp "$PROJECT_DIR/assets/icon/icon.png" "$APPDIR/.DirIcon"
ln -sf "$APP_ID.desktop" "$APPDIR/baddil.desktop"

if command -v appimagetool &> /dev/null; then
    ARCH="$PKG_ARCH_RPM" appimagetool "$APPDIR" "$DIST_DIR/${APP_NAME}-${VERSION}-${PKG_ARCH_RPM}.AppImage"
    echo "Generated: $DIST_DIR/${APP_NAME}-${VERSION}-${PKG_ARCH_RPM}.AppImage"
else
    echo "WARNING: appimagetool not found. Please install appimagetool to generate .AppImage."
fi

echo "=== Linux Distribution Build Finished ==="
ls -lh "$DIST_DIR"
