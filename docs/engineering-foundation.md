# Engineering foundation

## Purpose

OWO TÀ is a mobile-first, 3D action-adventure prototype intended to evolve into an independently owned commercial game. The project foundation prioritizes reproducibility, clear ownership, and a minimal, testable core so gameplay can expand without architectural drift.

## Approved stack

- Godot 4.x and GDScript
- Blender for 3D asset creation
- GitHub, private-repository workflow, Codespaces, and GitHub Actions
- Android APK/AAB export

## Technical decisions

1. Keep the Godot project root as the source of truth for runtime, renderer, input, and export configuration.
2. Target mobile rendering and portrait viewport defaults from the foundation stage.
3. Treat `application/run/main_scene` as the configured startup contract. `scripts/ProjectValidation.gd` instantiates that scene and fails if the world, player, collision, camera, environment, lighting, or touch overlay is missing.
4. Keep locomotion and collision on a `CharacterBody3D` root. Movement uses the camera's horizontal basis; only the visible body mesh rotates toward movement so facing cannot feed back into camera heading.
5. Route joystick, camera-look, and jump touches through the mobile overlay. Jump taps are buffered until a physics tick; touch actions and pending jumps are cleared on release, app pause/focus loss, or control removal.
6. Run a headless behavior suite against the configured main scene. It covers touch routing/release, camera-relative movement, visible-body turning, camera-heading stability, gravity, and jumping.
7. Pin CI to Godot 4.3 stable and a fixed Ubuntu LTS runner. Keep Android SDK platform/build-tools versions explicit; verify the APK is nonempty and passes archive-integrity validation before upload.
8. Do not add proprietary generation dependencies, unlicensed assets, secrets, or external paid-service requirements to the project.

## Repository structure

- `project.godot`: root Godot configuration and configured main scene
- `scenes/world/first_district.tscn`: current greybox 3D startup world
- `scenes/characters/player.tscn`: collision, visible body mesh, and third-person camera rig
- `scenes/TestScene.tscn`: minimal test fixture; not the configured startup scene
- `scripts/player/` and `scripts/ui/`: gameplay controller and mobile controls
- `scripts/ProjectValidation.gd` and `scripts/tests/`: structural validation and behavior tests
- `docs/`: architecture, contribution rules, asset inventory, and licensing register
- `.github/workflows/`: pinned validation and Android debug export automation
- `build/`: local/export output, ignored by Git

## Current milestone status

The Phase 002 foundation includes a greybox first-district scene; a `CharacterBody3D` player with collision, camera-relative locomotion, gravity, and buffered jump; a third-person camera and visible-body rotation; multi-touch joystick/look/jump controls with release cleanup; structural validation of the configured main scene; automated behavior tests; Android APK/AAB export presets; and pinned Godot 4.3 CI. The debug APK pipeline now exports and verifies a real APK artifact before upload. No Android device test is implied by headless validation.

## Required next milestone

Complete and verify the GitHub Actions debug APK export, install it on a physical Android device, and record input/camera/frame-rate issues across target screen sizes. After that, define a small 3D gameplay vertical slice and asset criteria. Do not expand into the full open world, vehicles, or production character assets until the 3D foundation and device behavior are validated.
