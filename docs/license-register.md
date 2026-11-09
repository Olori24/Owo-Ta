# Third-party licensing register

## Source assets and dependencies

| Asset / dependency | Source | License | Status | Notes |
| --- | --- | --- | --- | --- |
| Godot Engine 4.3 stable | Godot Engine | MIT License | Approved | Preserve the engine copyright and license notice with distributions. |
| Godot Android export templates | Godot Engine | MIT for Godot-authored portions; bundled third-party components retain their own licenses | Approved with notice audit | Before each release, inspect the matching Godot version's third-party notices and include all applicable notices in the shipped legal/third-party notices bundle. |
| OWO TÀ project icon | Original authored within repo | Original project asset | Approved | Created for foundation validation. |
| Placeholder scene UI | Original authored within repo | Original project asset | Approved | Used for testing and boot validation. |
| Kemi Adebayo character (`.blend`, `.glb`, four base-colour maps, eight clips) | Authored in this repository with `tools/blender/build_kemi_character.py`; no external source assets | Original project asset; no separate public license assigned | Approved for this project | Editable source: `assets/characters/kemi_adebayo/source/kemi_adebayo.blend`; runtime handoff: `assets/characters/kemi_adebayo/kemi_adebayo.glb`. Retain the repository owner’s existing project ownership and distribution control. |
| Blender 4.0.2 | Blender Foundation / Blender project | GNU GPL-3.0-or-later | Approved as an authoring tool | Used locally to create and export the character only; Blender is not linked, bundled, or required at game runtime. The project does not redistribute the Blender application. |
| External third-party models | N/A | N/A | Not used | No unlicensed asset ingestion allowed. |
| External audio packs | N/A | N/A | Not used | No paid or unlicensed media used. |

## Licensing rules

- Use only assets with confirmed ownership and compatible licensing.
- Preserve copyright notices and license texts required by engine, export-template, plugin, font, model, texture, and audio dependencies.
- Keep a record of each asset's source, version, license, and usage status before integration.
- Before distributing a game build, audit the exact engine/export-template version's bundled third-party components and ship their applicable notices.
- Do not upload private, paid, or shared secrets into the repository.
