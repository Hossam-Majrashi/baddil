#!/usr/bin/env bash
# Packaging regression checks using a mock Flutter compiler and packaging tools.
# Run with: bash test/build_linux_script_test.sh
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT
FIXTURE="$TEST_DIR/project with spaces بدّل"
MOCK_BIN="$TEST_DIR/bin"
mkdir -p "$FIXTURE/flatpak" "$FIXTURE/assets/icon" "$MOCK_BIN"
mkdir -p "$FIXTURE/linux/icons/hicolor/32x32/apps" "$FIXTURE/linux/icons/pixmaps"
cp "$PROJECT_DIR/build_linux.sh" "$FIXTURE/"
printf 'version: 1.0.0+1\n' > "$FIXTURE/pubspec.yaml"
printf '[Desktop Entry]\nName=Baddil\n' > "$FIXTURE/flatpak/com.h.baddil.desktop"
for icon in assets/icon/icon.png linux/icons/hicolor/32x32/apps/baddil.png linux/icons/pixmaps/baddil.png; do
    printf 'fixture icon\n' > "$FIXTURE/$icon"
done

cat > "$MOCK_BIN/flutter" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s|%s\n' "$PWD" "$*" >> "$MOCK_LOG"
case "$1" in
    gen-l10n) exit "${MOCK_L10N_EXIT:-0}" ;;
    build)
        if [ "${MOCK_BUILD_EXIT:-0}" != 0 ]; then exit "$MOCK_BUILD_EXIT"; fi
        if [ "${MOCK_INCOMPLETE:-0}" = 1 ]; then exit 0; fi
        arch=x64
        for arg in "$@"; do
            case "$arg" in --target-platform=linux-*) arch="${arg#--target-platform=linux-}" ;; esac
        done
        bundle="build/linux/$arch/release/bundle"
        mkdir -p "$bundle/lib"
        printf '#!/bin/sh\nexit 0\n' > "$bundle/baddil"
        chmod +x "$bundle/baddil"
        cp source-version.txt "$bundle/lib/libapp.so"
        ;;
    *) exit 1 ;;
esac
EOF
cat > "$MOCK_BIN/uname" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "${MOCK_ARCH:-x86_64}"
EOF
cat > "$MOCK_BIN/fpm" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
while [ "$#" -gt 0 ]; do
    if [ "$1" = -p ]; then touch "$2"; exit 0; fi
    shift
done
exit 1
EOF
cat > "$MOCK_BIN/dpkg-deb" <<'EOF'
#!/usr/bin/env bash
touch "${@: -1}"
EOF
cat > "$MOCK_BIN/appimagetool" <<'EOF'
#!/usr/bin/env bash
touch "$2"
EOF
chmod +x "$MOCK_BIN"/*
export PATH="$MOCK_BIN:$PATH"
export MOCK_LOG="$TEST_DIR/flutter.log"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
assert_archive() {
    local arch="$1" expected="$2"
    local contents
    contents="$(tar -xOf "$FIXTURE/dist/baddil-1.0.0-$arch.tar.gz" usr/lib/baddil/lib/libapp.so)"
    [ "$contents" = "$expected" ] || fail "Packaged stale bundle for $arch"
}

# Start with an old release and invoke the script from outside the project.
mkdir -p "$FIXTURE/build/linux/x64/release/bundle/lib"
printf 'old release\n' > "$FIXTURE/build/linux/x64/release/bundle/lib/libapp.so"
printf 'new release\n' > "$FIXTURE/source-version.txt"
cd "$TEST_DIR"
bash "$FIXTURE/build_linux.sh" > "$TEST_DIR/output.log" 2>&1
assert_archive x86_64 'new release'
grep -Fq "$FIXTURE|gen-l10n" "$MOCK_LOG" || fail 'Localizations not generated in project directory'
grep -Fq "$FIXTURE|build linux --release --target-platform=linux-x64" "$MOCK_LOG" || fail 'Release not rebuilt in project directory'

# Subsequent builds must rebuild too, even when a complete release exists.
printf 'second release\n' > "$FIXTURE/source-version.txt"
bash "$FIXTURE/build_linux.sh" > "$TEST_DIR/output.log" 2>&1
assert_archive x86_64 'second release'
[ "$(grep -c '|build linux' "$MOCK_LOG")" = 2 ] || fail 'Cached bundle skipped rebuilding'

# Build errors must stop before packaging and preserve the previous archive.
if MOCK_BUILD_EXIT=42 bash "$FIXTURE/build_linux.sh" > "$TEST_DIR/output.log" 2>&1; then
    fail 'Flutter build error was ignored'
fi
if grep -q 'Generating .tar.gz' "$TEST_DIR/output.log"; then fail 'Packaged after a failed build'; fi
assert_archive x86_64 'second release'

# Generation errors must stop before compilation/packaging.
: > "$MOCK_LOG"
if MOCK_L10N_EXIT=43 bash "$FIXTURE/build_linux.sh" > "$TEST_DIR/output.log" 2>&1; then
    fail 'Localization generation error was ignored'
fi
if grep -q '|build linux' "$MOCK_LOG"; then fail 'Built after failed localization generation'; fi

# Arm64 must use its own output instead of an old x64 bundle.
printf 'arm64 release\n' > "$FIXTURE/source-version.txt"
MOCK_ARCH=aarch64 bash "$FIXTURE/build_linux.sh" > "$TEST_DIR/output.log" 2>&1
assert_archive aarch64 'arm64 release'
grep -q -- '--target-platform=linux-arm64' "$MOCK_LOG" || fail 'Incorrect Arm64 target'

# A successful command with missing artifacts is still a failed release.
rm -rf "$FIXTURE/build/linux/arm64/release/bundle"
if MOCK_ARCH=aarch64 MOCK_INCOMPLETE=1 bash "$FIXTURE/build_linux.sh" > "$TEST_DIR/output.log" 2>&1; then
    fail 'Incomplete release bundle was packaged'
fi
if grep -q 'Generating .tar.gz' "$TEST_DIR/output.log"; then fail 'Packaged an incomplete bundle'; fi

if MOCK_ARCH=i686 bash "$FIXTURE/build_linux.sh" > "$TEST_DIR/output.log" 2>&1; then
    fail 'Unsupported architecture was accepted'
fi
printf 'All Linux build script regression checks passed.\n'
