# OWO TÀ — Phase 1 Visual Benchmark Production Brief

**Status:** Production specification for owner review  
**Parent standard:** `docs/premium-visual-bible.md`  
**Target engine:** Godot 4.3, Forward Mobile  
**First physical target:** Samsung Galaxy A16  
**Scope:** One character benchmark and one compact Lagos street-corner benchmark. This is a production brief, not a claim that the assets or tests already exist.

## 1. Objective

Establish a repeatable visual quality bar before expanding the character roster or replacing large areas of the greybox district. The benchmark must prove that OWO TÀ can deliver expressive characters, convincing Nigerian urban environments, readable gameplay and stable Android rendering together.

The benchmark is deliberately small:
- One selected character from the existing roster as the first art-direction candidate.
- One representative street-corner environment.
- One in-engine presentation scene that shows the character in context.
- One exported Android build used for visual and performance acceptance.

Do not create three new character variants or a full district during this phase. First inspect the existing Kemi, Tunde and Amara assets and recommend the strongest candidate based on evidence. Kemi remains the known playable/device-verified baseline; that does not automatically make her the final visual benchmark.

## 2. Workstream A — Character benchmark audit

### A1. Inspect current assets

Review the existing source and runtime assets for:
- Kemi Adebayo.
- Tunde Balogun.
- Amara Okonkwo.

For each, record:
- Source file and generator path.
- Blender version and reproducible command.
- GLB file size and SHA-256.
- Triangle count, mesh/surface count, joint count and material count.
- Texture dimensions, formats, compression/import settings and estimated runtime memory.
- Available animation clips and actual start/end frame ranges.
- Provenance and licence status.
- Current Godot import warnings/errors.
- Known visual, rigging, deformation or animation defects.
- Whether the character has been rendered and physically inspected on the Galaxy A16.

Do not infer visual quality from triangle count, file size or a Blender viewport screenshot alone.

### A2. Required presentation views

For the selected candidate, produce consistent, unaltered evidence views:
1. Front orthographic, neutral pose.
2. Three-quarter front, neutral pose.
3. Side orthographic.
4. Rear orthographic.
5. Gameplay camera distance, idle.
6. Gameplay camera distance, walk contact pose.
7. Gameplay camera distance, run pose.
8. Gameplay camera distance, jump and landing.
9. Close facial/material inspection.
10. In-engine view against both a bright and a dark environment background.

Use the same camera, framing, lighting and output dimensions when comparing roster candidates. Label every render with character name, source commit and asset hash. Do not retouch defects out of evidence renders.

### A3. Character acceptance criteria

- Silhouette remains distinct at actual gameplay camera distance.
- Face, hair, skin, wardrobe and accessories have deliberate material separation.
- No obvious mesh gaps, floating accessories, garment intersections or ground penetration.
- Walk/run cycles show credible foot contact and no severe sliding.
- Jump/landing poses preserve balance and do not visibly deform the shoulders, hips, knees or hands.
- Idle animation plays its complete authored range.
- Character renders through the project's actual Godot import path.
- Character remains readable on the Galaxy A16 at the intended gameplay resolution.
- Measurements, source, generator, provenance and hashes are recorded.
- Any unresolved issue is listed; no quality claim is made from missing evidence.

## 3. Workstream B — Lagos street-corner benchmark

### B1. Scene composition

Build one compact, navigable street-corner module, not a full neighbourhood. It should contain:
- A believable road edge, pavement and pedestrian path.
- One distinctive building frontage with coherent doors, windows, signage and awning or balcony detail.
- One transport or street-life element that is culturally and spatially appropriate.
- A restrained set of props that communicate use and scale.
- One recognisable landmark or colour/shape cue for navigation.
- A clear player route and a small interaction point.
- Daylight presentation first; night lighting is a later variant, not a dependency.

Use fictional business names and signage unless a real brand partnership is explicitly approved. Avoid generic "African street" dressing. Every visible element should have a grounded purpose and should not rely on stereotypes or random clutter.

### B2. Environment evidence views

Provide:
1. Wide establishing view from the intended player approach.
2. Player-eye/gameplay camera view at normal movement distance.
3. Reverse view showing navigation continuity.
4. Material close-ups for asphalt, concrete/plaster, painted metal, glass and any fabric/wood used.
5. Lighting comparison showing character readability in sun and shade.
6. Collision/navigation overlay or equivalent debug evidence.
7. In-engine Android capture from the exported build.

### B3. Environment acceptance criteria

- Road, pavement, building and prop dimensions are consistent and traversable.
- The player route and interaction point are immediately readable.
- Signage remains legible without dominating the composition.
- Materials are distinguishable without excessive gloss, uniform grunge or oversaturation.
- No prop blocks the camera or creates an accidental navigation trap.
- Collision shapes match visible geometry closely enough to avoid obvious clipping.
- Scene complexity and texture memory are measured, not guessed.
- The exported scene renders correctly on the Galaxy A16.

## 4. Workstream C — In-engine benchmark scene

Create a dedicated benchmark scene or isolated test level. Do not replace the configured first-district main scene or alter the verified Kemi movement controller as part of art benchmarking.

The scene must:
- Load the chosen character using the same runtime import path intended for gameplay.
- Preserve the existing CharacterBody3D/controller ownership and collision contract.
- Expose idle, walk, run, jump and landing for visual inspection.
- Place the character beside the benchmark street frontage.
- Support repeatable camera positions and lighting conditions.
- Include a debug mode for mesh, collision and navigation inspection.
- Keep all benchmark-only code/assets clearly isolated and removable.

No character-selection/game-flow integration is implied by this benchmark. That remains a separate phase with its own acceptance gate.

## 5. Performance and Android evidence

The Galaxy A16 is the first physical reference device. Do not invent a frame-rate target before capturing a baseline. Record the actual result, then agree a target based on the device and project needs.

For every exported test build, record:
- Git commit SHA.
- APK filename, byte size and SHA-256.
- Godot version and export preset.
- Device model, Android version and build number.
- Graphics renderer and project quality settings.
- Scene load time and any visible stutter.
- Sustained frame pacing/FPS observation, including whether the scene was warmed up.
- Memory observation if available from reliable tooling.
- Thermal behaviour during a repeatable 5-minute test.
- Visual defects, crashes, touch-control regressions and reproduction steps.

Test sequence:
1. Clean-install the exact APK.
2. Launch the benchmark scene.
3. Inspect idle for 30 seconds.
4. Walk and run a fixed route for 60 seconds.
5. Perform 10 jump/landing cycles.
6. Rotate the camera through the agreed views.
7. Repeat under the second lighting condition.
8. Continue for 5 minutes and record performance/thermal observations.
9. Exit and relaunch to confirm no startup regression.

A desktop/headless pass is not a substitute for this physical test. If the device test cannot be run, mark the gate **not verified**.

## 6. Asset budget and reproducibility

Each delivered asset must include:
- Editable source.
- Deterministic generator or documented authoring steps.
- Pinned authoring software version.
- Runtime export and import configuration.
- Asset budget JSON with measured values.
- SHA-256 for source/runtime handoff files.
- Provenance and licence record.
- Preview renders from the source application and from Godot.
- Known limitations and defects.

Regenerate derived GLBs after any source animation, geometry, material or export-range correction. Update measured sizes and hashes only after the final regeneration. A changed source with stale runtime binary or stale asset budget fails acceptance.

## 7. Required deliverables

| ID | Deliverable | Acceptance evidence |
| --- | --- | --- |
| VB-01 | Roster comparison audit | Measurements, defects, provenance and recommendation for Kemi/Tunde/Amara |
| VB-02 | Selected character view pack | Ten consistent views, labelled with commit and asset hash |
| VB-03 | Character in-engine benchmark | Godot scene, animation inspection and import validation |
| VB-04 | Lagos street-corner module | Source assets, runtime scene, material and navigation evidence |
| VB-05 | Android benchmark APK | Exact commit, APK SHA-256 and clean-install test record |
| VB-06 | Performance report | Repeatable Galaxy A16 observations, defects and limitations |
| VB-07 | Owner review pack | Concise comparison, open decisions and approval request |

## 8. Ownership and change boundaries

Before implementation begins, the assigned agent must state:
- Exact base branch and starting SHA.
- Files/directories it owns.
- Files/directories it will not modify.
- Dependencies and required tools.
- Exact deliverables and tests.
- Whether Android hardware is available.
- Any paid asset/tool/service requirement.

Do not let two agents write to the same scene, controller, asset generator or import configuration concurrently. Do not modify the verified Kemi controller or configured main scene without a separate, explicit task. Do not add paid assets, plugins, SDKs or subscriptions. Do not merge any PR.

## 9. Review gate

The benchmark is ready for owner review only when:
- The comparison audit is complete.
- All required source and runtime evidence is present.
- The in-engine scene has been inspected.
- The Android build is tied to an exact commit and hash.
- The Galaxy A16 test is completed or explicitly marked not verified.
- Performance observations and defects are disclosed.
- No existing working gameplay path has regressed.

Owner approval is required before the benchmark becomes the production reference for further character and district work.

## 10. Immediate sequence

1. Recheck and resolve the known PR #10 animation export and async-validation defects before treating Tunde/Amara as production-ready.
2. Complete the roster comparison audit using the exact current assets.
3. Select one character candidate for the first visual benchmark.
4. Produce the compact street-corner module and in-engine presentation scene.
5. Export and physically test on the Galaxy A16.
6. Present the evidence pack for owner approval.
7. Only after approval, expand the character pipeline and district art production.
