# Phase 003 — Original character asset and selection pipeline

## Scope and status

This milestone adds one original stylized character, Kemi Adebayo, and a standalone Godot 3D inspection/selection scene. It is a working first character vertical slice, not final production character art and not evidence that the whole game is complete. The active project main scene remains the Phase 002 district; this work does not replace the player controller, district, or mobile gameplay controls.

Kemi is one fictional Lagos-raised vehicle electrical/audio technician. The character is not intended as a universal representation of Nigerian or Lagosian people.

## Source-of-truth and handoff

`tools/blender/build_kemi_character.py` procedurally builds the original mesh components, joined character mesh, UV layout, vertex-colour regions, four PBR materials, humanoid armature with an A-pose rest skeleton, and eight keyed animation actions. The editable Blender 4.0.2 file lives at `assets/characters/kemi_adebayo/source/kemi_adebayo.blend`; the source directory contains `.gdignore` so Godot does not treat the authoring file as a runtime asset. The same build script emits the glTF Binary (`.glb`), its four base-colour PNGs, and a render preview. The game needs only the GLB handoff; its four authored PNGs remain in `textures/` as editable source maps. Godot's tracked `kemi_adebayo.glb.import` sets `gltf/embedded_image_handling=2` (embed as Basis Universal), so the imported scene does not rely on duplicate extracted PNGs beside the GLB. Blender, Draco, an asset-generation API, and paid services are not runtime dependencies.

Use the lowercase stable slug `kemi_adebayo` for the character directory, resource filename, and `CharacterDefinition.character_id`. Blender uses `RIG_` for the armature, `MESH_` for geometry objects, and `MAT_PBR_` for exported material names. Source maps use `mat_pbr_<category>_basecolor.png`; exported clip names match `asset_budget.json`. The runtime GLB embeds its four PNGs and exports standard glTF metallic-roughness PBR materials with authored base-colour and vertex-colour data.

To regenerate locally with the recorded authoring version:

```bash
blender --version
blender --background --python tools/blender/build_kemi_character.py
```

The export uses ordinary glTF 2.0 and does not require Draco compression. Blender may log that its optional Draco library is unavailable; the standard GLB export still completes and is validated without a Draco extension. Keep generated `.blend1` backup files out of Git.

## Godot architecture

- `scripts/characters/character_definition.gd` is a reusable data resource containing stable character ID, display name, biography, role, preview accent, visual `PackedScene`, and named animation clips. It owns no player movement or district behavior.
- `assets/characters/kemi_adebayo/kemi_adebayo.tres` provides Kemi's definition and points at the imported visual scene.
- `scripts/characters/character_selection.gd` is a standalone controller for roster wrapping, animation preview, a selection signal, mouse/touch orbit, scroll/pinch zoom, and camera pitch/distance clamps.
- `scenes/characters/character_selection.tscn` owns the inspection camera, lights, environment and visible selection UI. It does not become the configured game startup scene until an explicit later integration decision.
- Existing `scripts/player/`, `scripts/ui/`, `scenes/world/first_district.tscn`, and Phase 002 startup validation remain unchanged by the character pipeline.

The UI is intentionally limited to character inspection and selection: it displays the current definition, lets the user step through a reusable typed roster, previews the `idle` clip when it exists, and emits `character_selected(definition)` when selected. A future game-start flow can consume that signal without embedding roster logic in the controller.

## Current asset measurements and guardrails

`asset_budget.json` records project planning estimates; none of its numbers is an Android, Godot, glTF, or device hard limit. Godot 4.3's headless GLTF importer and the `CharacterPipelineValidation.gd` test inspect the committed handoff. The validator checks binary GLB structure and actual generated scene data, including positions, normals, UVs, skinning attributes, vertex colours, triangle count, PBR textures, skeleton, weight normalization/influence count, animation clips and live bone motion. It also exercises the data-driven selection controller, orbit clamp, pinch zoom, touch release, and selection signal.

The test separately loads the actual `character_selection.tscn` through Godot's normal resource importer when editor import metadata is present. GitHub Actions sets `OWO_REQUIRE_IMPORTED_CHARACTER_SCENE=1`, making that scene load and imported model check mandatory in CI; a direct local headless run without an editor cache reports the `.tscn` check as skipped while still importing the GLB through `GLTFDocument` directly.

The asset budget currently includes:

- GLB package target: 10 MiB maximum (project estimate).
- Hero mesh target: 30,000 triangles maximum (project estimate).
- Up to five material/surface slots; four base-colour maps at up to 2,048 pixels per side; and 2 MiB total encoded texture data (project estimates).
- Up to 65 deforming bones and four vertex influences (project interoperability targets).
- Eight to twelve named animation clips, with the eight required Kemi clips listed in the manifest.

Measured from the current Blender 4.0.2 output: `kemi_adebayo.glb` is 1,493,040 bytes with 14,666 exported position vertices across four surfaces, 15,040 triangles, four materials, four 256×256 base-colour maps (244,800 encoded bytes total), 22 skin joints, and eight clips. The editable `.blend` is 3,500,872 bytes. Two consecutive A-pose builds produced the same GLB SHA-256: `c95a99a9fe1df9f46c650a12b3907fbd24ec93a9ed4d39ceacf776e62dd9ab63`. These are measurements for this build, not device performance claims.

These thresholds are initial guardrails, not a substitute for measuring imported memory, rendering performance, thermal behavior, or visual quality on representative Android hardware. Do not expand the roster or claim shipping readiness before those checks.

## Test commands

Use the project-pinned Godot 4.3 binary. After the normal editor import has run, GitHub Actions executes the configured-scene validator, existing Phase 002 behavior suite, and this Phase 003 asset/selection suite:

```bash
./.tools/godot --headless --editor --path . --quit
./.tools/godot --headless --path . --script res://scripts/ProjectValidation.gd
./.tools/godot --headless --path . --script res://scripts/tests/GameplayFoundationTests.gd
OWO_REQUIRE_IMPORTED_CHARACTER_SCENE=1 \
  ./.tools/godot --headless --path . --script res://scripts/tests/CharacterPipelineValidation.gd
```

No Android export or physical-device test is implied by the Blender render, static asset budgets, or headless Godot test. The next milestone is human art/animation review and an actual imported-scene smoke test on an Android device, followed by an explicit decision about where the selection scene belongs in the game flow.
