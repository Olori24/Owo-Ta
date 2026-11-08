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
3. `scripts/ProjectValidation.gd` loads and instantiates the scene configured by `application/run/main_scene`, then validates that same instance. The configured startup scene itself must contain the player, collision, current camera, world environment, lighting, mobile controls, ground, and matching blockout building colliders; a separate fallback district cannot make validation pass.
4. Keep locomotion and collision on a `CharacterBody3D` root. Movement uses the camera's horizontal basis; only the visible body mesh rotates toward movement so facing cannot feed back into camera heading.
5. Route joystick, camera-look, and jump touches through the mobile overlay. A jump request survives ordinary finger release until the next physics tick consumes it. Focus loss, application pause, or removal of the touch overlay clears held virtual actions and cancels any pending jump request.
6. Run a headless behavior suite against the configured main scene. It covers touch hit testing and release, focus/pause/removal cleanup, camera-relative movement, visible-body turning, camera-heading stability, gravity, jumping, and collision with a district building.
7. `BuildingA`, `BuildingB`, and `BuildingC` each have a corresponding `StaticBody3D` at the visible mesh position and a `CollisionShape3D` using the shared `BoxShape3D` sized to the `BoxMesh`. Structural validation checks the body and shape presence, compares box sizes, and checks that each body's global position is within 0.01 units of its mesh's global position. It does not check body rotation or the `CollisionShape3D`'s own transform. The automated physical collision test exercises `BuildingA` only; `BuildingB` and `BuildingC` are structurally checked but not individually tested by player movement.
8. Pin CI to Godot 4.3 stable and a fixed Ubuntu LTS runner. Keep Android SDK platform/build-tools versions explicit; verify the APK is nonempty and passes archive-integrity validation before upload.
9. Do not add proprietary generation dependencies, unlicensed assets, secrets, or external paid-service requirements to the project.

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

The Phase 002 foundation includes a greybox first-district scene; a `CharacterBody3D` player with collision, camera-relative locomotion, gravity, and buffered jump; a third-person camera and visible-body rotation; multi-touch joystick/look/jump controls with release cleanup; same-instance validation of the configured main scene; box collisions on the three blockout buildings; automated behavior tests; Android APK/AAB export presets; and pinned Godot 4.3 CI. The debug APK pipeline exports and verifies a real APK artifact before upload. No Android device test is implied by headless validation.

## Required next milestone

Complete and verify the GitHub Actions debug APK export, install it on a physical Android device, and record input/camera/frame-rate issues across target screen sizes. After that, define a small 3D gameplay vertical slice and asset criteria. Do not expand into the full open world, vehicles, or production character assets until the 3D foundation and device behavior are validated.
