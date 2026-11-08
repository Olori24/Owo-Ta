# Engineering foundation

## Purpose

OWO TÀ is a mobile-first, 3D action-adventure prototype intended to evolve into an independently owned commercial game. The project foundation prioritizes reproducibility, clear ownership, and a minimal, testable core so the 3D open-world system can expand without architectural drift.

## Approved stack

- Godot 4.x
- GDScript
- Blender for 3D assets
- GitHub private repository
- GitHub Codespaces
- GitHub Actions
- Android APK/AAB export

## Technical decisions

1. Use the Godot 4.x baseline and keep the project root as the authoritative source for runtime and export configuration.
2. Keep the project mobile-oriented from the first milestone by enabling mobile rendering and portrait viewport defaults.
3. Maintain a small test scene to validate engine startup and project bootability before any world-generation work begins.
4. Keep the Android export configuration in-repo with explicit SDK/environment checks so the build fails clearly rather than silently.
5. Use CI to validate the project at a pinned engine version to avoid hidden environment regressions.

## Repository structure

- `project.godot`: root Godot configuration
- `scenes/TestScene.tscn`: startup scene used for validation
- `scripts/`: GDScript logic and validation helpers
- `docs/`: architecture, contribution rules, inventory, and licensing
- `.github/workflows/`: pinned validation and Android export automation
- `build/`: export output directory, ignored by Git

## Current milestone status

The repository now contains a working Godot foundation with:

- a valid project file,
- a minimal bootable scene,
- a mobile-rendering profile,
- an Android export preset, and
- a CI validation pipeline pinned to Godot 4.3-stable.

## Required next milestone

The next stage is to add a verified 3D scene graph and gameplay bootstrapping as the groundwork for open-world systems, while continuing to validate the project in headless CI.
