#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"
GODOT_BIN="${GODOT_BIN:-${HOME}/.local/share/godot/Godot_v4.3-stable_linux.x86_64}"
if [ ! -x "$GODOT_BIN" ]; then
  echo "Godot 4.3 binary not found. Set GODOT_BIN or install it at $GODOT_BIN."
  exit 1
fi
if ! GODOT_VERSION="$("$GODOT_BIN" --version 2>/dev/null)"; then
  echo "Unable to execute the configured Godot binary: $GODOT_BIN"
  exit 1
fi
if [[ "$GODOT_VERSION" != 4.3.stable* ]]; then
  echo "Expected Godot 4.3 stable, got: $GODOT_VERSION"
  exit 1
fi
if ! command -v java >/dev/null 2>&1; then
  echo "Android export requires Java 17 or newer on PATH."
  exit 2
fi
JAVA_VERSION_OUTPUT="$(java -version 2>&1)"
JAVA_MAJOR="$(printf '%s\n' "$JAVA_VERSION_OUTPUT" | sed -nE '1s/.*version "([0-9]+).*/\1/p')"
if [ -z "$JAVA_MAJOR" ] || [ "$JAVA_MAJOR" -lt 17 ]; then
  echo "Android export requires Java 17 or newer; detected: ${JAVA_VERSION_OUTPUT%%$'\n'*}"
  exit 2
fi
if [ -z "${ANDROID_HOME:-}" ] && [ -n "${ANDROID_SDK_ROOT:-}" ]; then
  export ANDROID_HOME="$ANDROID_SDK_ROOT"
fi
if [ -z "${ANDROID_HOME:-}" ]; then
  echo "Android export requires ANDROID_HOME or ANDROID_SDK_ROOT."
  exit 2
fi
if [ ! -f "$ANDROID_HOME/platforms/android-34/android.jar" ]; then
  echo "Android SDK platform 34 is missing from $ANDROID_HOME/platforms/android-34."
  exit 2
fi
for tool in zipalign apksigner; do
  if [ ! -x "$ANDROID_HOME/build-tools/34.0.0/$tool" ]; then
    echo "Android SDK build-tools 34.0.0 component $tool is missing from $ANDROID_HOME/build-tools/34.0.0."
    exit 2
  fi
done
if ! command -v unzip >/dev/null 2>&1; then
  echo "APK integrity verification requires unzip on PATH."
  exit 2
fi
mkdir -p build/android
"$GODOT_BIN" --headless --path . --export-debug "Android Debug APK" build/android/owo_ta-debug.apk
test -s build/android/owo_ta-debug.apk
unzip -t build/android/owo_ta-debug.apk
"$ANDROID_HOME/build-tools/34.0.0/apksigner" verify --verbose --print-certs build/android/owo_ta-debug.apk
echo "Android debug APK export completed and verified: build/android/owo_ta-debug.apk"
