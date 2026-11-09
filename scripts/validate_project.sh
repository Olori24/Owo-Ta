#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"
for required in project.godot icon.svg scenes/world/first_district.tscn scenes/characters/player.tscn scripts/player/player_controller.gd; do
  if [ ! -f "$required" ]; then
    echo "Missing required gameplay file: $required"
    exit 1
  fi
done
grep -Eq '^[[:space:]]*run/main_scene="res://scenes/world/first_district.tscn"[[:space:]]*$' project.godot || {
  echo "Missing active 3D district main scene configuration."
  exit 1
}
echo "OWO TÀ 3D gameplay files and main scene configuration passed."
