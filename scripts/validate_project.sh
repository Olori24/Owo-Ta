#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"
for required in project.godot icon.svg scenes/TestScene.tscn; do
  if [ ! -f "$required" ]; then
    echo "Missing required project file: $required"
    exit 1
  fi
done
grep -Eq '^[[:space:]]*run/main_scene="res://scenes/TestScene.tscn"[[:space:]]*$' project.godot || {
  echo "Missing active application main scene configuration."
  exit 1
}
echo "OWO TÀ foundation validation passed."
