# OWO TÀ

OWO TÀ is a mobile-first 3D action-adventure prototype built as an independently owned commercial project. The repository is intended to be the permanent source of truth for design, engineering, and platform build workflows.

## Repository ownership and constraints

- Source code remains in the Olori24/owo-ta repository.
- No proprietary game-generation dependencies are introduced.
- No paid external service is required for core development.
- No secrets or private credentials are stored in-repo.
- Only original or properly licensed assets are used.
- Main protection and pull-request workflow remain in place when GitHub branch protections are enabled.

## Stack

- Godot 4.x
- GDScript
- Blender for 3D assets
- GitHub private repository
- GitHub Codespaces
- GitHub Actions
- Android APK/AAB export

## Current milestone

This repository now contains the first Godot project foundation for OWO TÀ:

- Valid Godot project configuration
- Basic test scene that boots in headless mode
- Mobile-oriented rendering settings
- Android export preset scaffold
- CI validation workflow pinned to Godot 4.3-stable
- Documentation for branching, architecture, and licensing

## Quick validation

```bash
./scripts/validate_project.sh
```

## Godot validation

```bash
curl -L -o /tmp/godot.zip https://github.com/godotengine/godot-builds/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip
mkdir -p /tmp/godot
unzip -q /tmp/godot.zip -d /tmp/godot
chmod +x /tmp/godot/Godot_v4.3-stable_linux.x86_64
/tmp/godot/Godot_v4.3-stable_linux.x86_64 --headless --path . --script res://scripts/ProjectValidation.gd
```

## Android export status

The repository includes an Android export preset and build script. A full APK/AAB export requires the Android SDK and Java toolchain to be installed and available through ANDROID_HOME or ANDROID_SDK_ROOT. The repo is configured to fail early with a clear explanation if the environment is incomplete.

## Project documentation

- docs/engineering-foundation.md
- docs/branching-and-contribution.md
- docs/asset-inventory.md
- docs/license-register.md
