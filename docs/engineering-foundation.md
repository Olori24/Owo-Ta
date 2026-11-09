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
10. Keep original character metadata (`CharacterDefinition`) separate from movement logic. The Phase 003 `CharacterSelection` scene is standalone and is not the configured startup scene; it emits a selection signal for a future explicit game-flow integration.
11. Keep each original character's editable Blender source, local build script, runtime GLB, authored texture maps, preview, provenance record, and machine-readable project budgets in the same repository. Godot ignores the editable `.blend` source folder and imports the standard glTF 2.0 handoff.
12. Run pinned Godot 4.3 checks on the exported mesh data and generated character scene: geometry attributes, PBR texture/material counts, triangles, skin weights/influences, humanoid bone structure, required animation clips/live pose change, selection, orbit, pinch zoom, and touch release. Project budgets are planning guardrails, not device hard limits.

## Repository structure

- `project.godot`: root Godot configuration and configured main scene
- `scenes/world/first_district.tscn`: current greybox 3D startup world
- `scenes/characters/player.tscn`: collision, visible body mesh, and third-person camera rig
- `scenes/TestScene.tscn`: minimal test fixture; not the configured startup scene
- `scenes/characters/character_selection.tscn`: standalone Phase 003 character inspection/selection scene
- `scripts/player/` and `scripts/ui/`: gameplay controller and mobile controls
- `scripts/characters/` and `assets/characters/`: data-driven original character and authored source/runtime handoff
- `tools/blender/`: local original-asset build pipeline; Blender is not a runtime service or dependency
- `scripts/ProjectValidation.gd` and `scripts/tests/`: structural validation and behavior tests
- `docs/`: architecture, contribution rules, asset inventory, and licensing register
- `docs/character-asset-pipeline.md`: Phase 003 character architecture, asset guardrails, and test commands
- `.github/workflows/`: pinned validation and Android debug export automation
- `build/`: local/export output, ignored by Git

## Current milestone status

The Phase 002 foundation includes a greybox first-district scene; a `CharacterBody3D` player with collision, camera-relative locomotion, gravity, and buffered jump; a third-person camera and visible-body rotation; multi-touch joystick/look/jump controls with release cleanup; same-instance validation of the configured main scene; box collisions on the three blockout buildings; automated behavior tests; Android APK/AAB export presets; and pinned Godot 4.3 CI. The debug APK pipeline exports and verifies a real APK artifact before upload. No Android device test is implied by headless validation.

The Phase 003 first character slice adds one original stylized fictional character (editable Blender source plus a rigged, four-material/four-texture GLB), eight named animation clips, a data resource, an independent 3D selection/inspection scene, local asset guardrails, and a Godot headless asset/selection test. Its direct GLTFDocument test covers the runtime GLB; the GitHub validation job requires the normal editor import and actual `.tscn` load. Character-device testing, final art review, and game-flow integration remain open. It is not final production art and does not represent game completion.

## Required next milestone

Complete the imported character-selection scene's required CI check, review the asset's form/animation on an Android device, and then decide how the selection signal connects to a small playable 3D vertical slice. Do not expand the roster, begin vehicles, or start new districts before that review.
