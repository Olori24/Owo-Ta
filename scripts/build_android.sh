#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"
GODOT_BIN="${GODOT_BIN:-${HOME}/.local/share/godot/Godot_v4.3-stable_linux.x86_64}"
if [ ! -x "$GODOT_BIN" ]; then
  echo "Godot binary not found. Expected at $GODOT_BIN"
  exit 1
fi
if [ -z "${ANDROID_HOME:-}" ] && [ -n "${ANDROID_SDK_ROOT:-}" ]; then
  export ANDROID_HOME="$ANDROID_SDK_ROOT"
fi
if [ -z "${ANDROID_HOME:-}" ]; then
  echo "Android export requires ANDROID_HOME or ANDROID_SDK_ROOT."
  exit 2
fi
mkdir -p build/android
"$GODOT_BIN" --headless --path . --install-android-build-template
"$GODOT_BIN" --headless --path . --export-debug "Android" build/android/owo_ta-debug.apk
echo "Android export completed: build/android/owo_ta-debug.apk"
