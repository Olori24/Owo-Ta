# OWO TÀ — Premium Visual Bible

**Approved direction:** Premium stylized realism  
**Primary device baseline:** Samsung Galaxy A16  
**Engine:** Godot 4.3  
**Purpose:** Shared art and asset-quality standards for characters, environments, vehicles, props, UI and lighting.

## 1. Art-direction statement

OWO TÀ should look like a premium, character-led Nigerian urban adventure: expressive but not childish, grounded but not photorealistic, colourful but controlled, cinematic without sacrificing mobile readability.

The target is **stylized realism**. Character anatomy, clothing folds, materials and lighting should feel believable, while shape language, colour grouping and facial expression remain deliberately art-directed.

Do not imitate a named commercial game. Build an original visual identity recognisable from a character silhouette, a Lagos street corner or a mission screen.

## 2. Visual identity

The existing project palette remains the starting point:

| Token | Hex | Intended use |
| --- | --- | --- |
| Night asphalt | #101820 | Deep neutral foundations, roads and dark UI |
| Lagos yellow | #FFC928 | Transport accents, route markers and highlights |
| Street teal | #18B9A8 | Secondary accents and transport details |
| Signal coral | #F06A52 | Mission alerts and selected emphasis |
| Warm cream | #FFF0D2 | Sign lettering and readable text |
| City blue | #142638 | Night environments, skyline depth and panels |

Use the palette with restraint. Real-world materials and district-specific colours may extend it, but new recurring colours must be documented as tokens. Do not make every surface saturated.

## 3. Character art standard

### Silhouette and anatomy
- Distinct, readable silhouettes at gameplay camera distance.
- Consistent stylized-realistic proportions across the roster.
- Believable joints, hands, feet, shoulder/hip articulation and clothing clearance.
- No floating accessories, intersecting garments, visible mesh gaps or obvious deformation at key poses.
- Character identity should remain readable without relying on skin tone or stereotypes.

### Face, hair and skin
- Intentional facial planes and readable eyes, nose, mouth and ears.
- Skin materials must avoid plastic shine, flat single-colour appearance and excessive specular response.
- Hair should have a designed silhouette and appropriate geometry/material treatment; avoid a single dark featureless mass.
- Facial details should survive the intended camera distance and Android resolution.
- Facial expression and head motion should support dialogue and story beats when those systems are implemented.

### Wardrobe
- Contemporary Nigerian urban fashion interpreted through specific fictional characters.
- Clothing must have coherent construction, seams, layers, folds and material response.
- Accessories should communicate character role and personality, not function as random decoration.
- Keep visual noise under control; large shape and colour grouping should read first.
- Character outfits need consistent variants and documented material slots.

### Rigging and animation
- Humanoid rigs must support stable locomotion and authored interaction poses.
- Required baseline clips: idle, walk, run, jump, landing, start/stop and turn; add character-specific clips where justified.
- Test foot contact, ground penetration, hand deformation, shoulder deformation, knee/elbow bends, root motion assumptions and animation transitions.
- Blend or transition states to avoid snapping where the controller requires it.
- A clip is not accepted merely because it exists in the GLB; inspect the actual imported skeleton pose.

### Character review checklist
- [ ] Strong silhouette at gameplay distance.
- [ ] Face, hair and skin materials read clearly.
- [ ] Wardrobe has believable shape and material separation.
- [ ] No major clipping or deformation in required animations.
- [ ] Materials and textures are consistent with the project's style.
- [ ] Character is recognisable in neutral, walking and running poses.
- [ ] Imported model renders correctly in Godot Forward Mobile on Android.
- [ ] Measured package size, triangles, joints, materials and texture memory recorded.
- [ ] Editable source, reproducible generator and provenance/license record included.

## 4. Environment art standard

Lagos should feel lived-in, layered and specific, not like generic blocks with Nigerian props pasted onto them.

### Architecture and street composition
- Use a coherent scale language for doors, windows, pavements, roads, shopfronts and street furniture.
- Build visual rhythm from building heights, setbacks, signage, awnings, balconies, fences and utility infrastructure.
- Use believable road markings, junction geometry, sidewalks and pedestrian paths.
- Place landmarks to support navigation and mission readability.
- Avoid dense prop clutter that obscures routes or overwhelms mobile rendering.

### Material language
- Concrete, painted plaster, weathered metal, glass, asphalt, fabric, wood and vegetation need distinct roughness and colour response.
- Use controlled wear, dirt and ageing. Avoid uniform grunge overlays across every surface.
- Signage must be legible at intended camera distance and must not use invented real-company branding.
- Use fictional brands unless a real partnership has been approved.

### Living-world staging
- Pedestrians, vendors, transport, storefronts and ambient activity should make districts feel inhabited.
- Ambient activity must be staged to support performance and gameplay readability.
- Interiors should be prioritised by mission value and player access, not built indiscriminately.
- Districts need unique landmark silhouettes, sound palettes, lighting conditions and activity loops.

### Environment review checklist
- [ ] District has a clear identity and navigable landmarks.
- [ ] Architecture and street dimensions are consistent.
- [ ] Materials are distinguishable and not excessively repetitive.
- [ ] Mission routes and interactive objects remain readable.
- [ ] Lighting supports navigation and mood without hiding gameplay.
- [ ] Scene has documented draw-call, mesh, texture and memory budgets.
- [ ] Performance profiled in an exported Android build.

## 5. Lighting, colour and camera

- Use lighting to establish time, mood, depth and focal hierarchy.
- Preserve character readability against both bright and dark backgrounds.
- Avoid relying on expensive real-time lights or shadows across the whole district.
- Establish baked, mixed or dynamic lighting policy per scene based on profiling.
- Use exposure and colour grading consistently; avoid crushed blacks and blown highlights.
- Camera framing must preserve control visibility and keep the player legible on portrait mobile screens.
- Effects such as bloom, fog, particles and reflections must be subtle, scalable and performance-tested.

## 6. Vehicles, props and interaction objects

Vehicles should have recognisable silhouettes and believable scale. A danfo, keke, okada and private car must not feel like the same generic vehicle with different colours.

- Define vehicle dimensions, wheel placement, suspension assumptions and collision volumes.
- Use distinct material response for paint, rubber, glass, chrome and interior surfaces.
- Props must support a gameplay or world-building purpose.
- Interactive objects need a readable visual affordance without excessive floating icons.
- Branded real-world assets require permission and legal review.

## 7. UI and HUD

The interface should be bold, legible and culturally grounded without becoming ornamental.

- Use a consistent typography scale and clear hierarchy.
- Keep touch targets generous and separated for mobile play.
- Reserve Lagos yellow for primary actions and route focus; use coral for warnings/urgent states; teal for secondary information.
- HUD should avoid covering character silhouettes, mission objectives or critical world cues.
- Menus, dialogue, mission cards and settings must share the same component language.
- Support text scaling and contrast checks.

## 8. Asset production and technical budgets

Existing character asset budgets are project guardrails, not proof of device performance. For every production asset, record:
- Editable source file and authoring software/version.
- Reproducible export/build command.
- Runtime format and import settings.
- Polygon/triangle count and mesh/surface count.
- Skeleton/joint count and animation clip list, where applicable.
- Texture dimensions, compression, colour space and estimated memory.
- Material count and shader features.
- File size and SHA-256 for release handoff.
- Provenance, ownership and license status.
- Device render/performance observations.

Use texture atlases and shared materials where they improve measured performance without damaging quality. Prefer efficient geometry and reuse. Do not set universal triangle or texture limits without considering screen coverage, material cost and device measurements.

## 9. Device quality tiers

The Galaxy A16 is the first physical baseline, not an assumption that every Android device behaves identically.

Create scalable tiers only after measuring actual hardware:
- **Baseline:** reliable frame pacing, readable characters, reduced expensive effects and controlled memory use.
- **Enhanced:** improved shadows, effects, texture detail and draw distance where supported.
- **High:** additional visual quality only when profiling demonstrates sufficient headroom.

The game must remain visually coherent at every tier. Quality settings should not disable essential gameplay information.

## 10. Review and approval process

1. Artist/agent submits source, runtime asset, preview, measurements and provenance.
2. Run deterministic generation and import validation where applicable.
3. Review the asset in the actual Godot scene, not only in Blender.
4. Review required poses/animations and camera-distance readability.
5. Test on the baseline Android device.
6. Record defects and rework before roster/world expansion.
7. Project owner approves the visual benchmark before it becomes the reference for further production.

## 11. Non-negotiable quality bar

No asset is called premium merely because it has high polygon counts, PBR textures or a large file size. Premium quality is the combined result of strong design, coherent art direction, clean execution, readable gameplay, reliable animation and measured performance on the actual target platform.
