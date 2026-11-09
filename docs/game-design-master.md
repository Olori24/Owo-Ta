# OWO TÀ — Master Game Design Direction

**Status:** Product direction approved; implementation roadmap proposed  
**Platform:** Android first | **Engine baseline:** Godot 4.3  
**Genre:** Premium 3D urban adventure with racing and exploration  
**World:** Hybrid explorable districts | **Story:** Cinematic narrative and interactive decisions

## 1. Product vision

OWO TÀ is a premium Nigerian urban adventure set in a fictionalised, interconnected Lagos. Players explore neighbourhoods, meet memorable characters, build relationships, take on story and side missions, develop skills and reputation, and shape their journey through consequential decisions.

The game must be recognisably rooted in Lagos without reducing Nigerian life to stereotypes or treating one character as representative of an entire culture. Its humour, dialogue, fashion, soundscape, locations and everyday details should be specific, researched and respectful.

**Player promise:** Find your lane. Build your name. Own your street.

## 2. Approved creative pillars

1. **Premium stylized realism:** expressive, high-quality characters and carefully art-directed environments, with a coherent visual language.
2. **A living Lagos:** districts with distinct identities, ambient activity, landmarks, transport, interiors and discoverable details.
3. **Character-led storytelling:** memorable protagonists, allies, rivals and community figures with motivations and evolving relationships.
4. **Player agency:** cinematic scenes establish stakes; player choices influence dialogue, relationships, reputation, opportunities and selected mission outcomes.
5. **Mobile-first performance:** responsive controls, readable presentation and scalable graphics on supported Android devices.

## 3. World structure

Use a hybrid structure: explorable district spaces connected by authored story missions, events and progression gates. Avoid promising a seamless full-city simulation until the technical and content costs have been proven.

Proposed fictionalised district families:
- Mainland neighbourhoods: residential streets, community spaces, local businesses and transport connections.
- Commercial district: markets, workshops, shopping streets, vendors and busy junctions.
- Island business and entertainment district: offices, modern buildings, nightlife and premium destinations.
- Waterfront district: coastal paths, bridges, recreation and port-side atmosphere.
- Industrial district: warehouses, depots, logistics yards and service businesses.

Each district needs a documented gameplay purpose, visual identity, navigation landmarks, ambient audio palette, performance budget and mission opportunities. Real locations may inspire fictional composites; do not imply exact geographic accuracy without research.

## 4. Narrative direction

Working story concept: **OWO TÀ: Streets of Lagos**.

A young Lagosian returns to a neighbourhood where familiar relationships, economic pressures and new opportunities collide. The protagonist begins with limited resources. Their actions shape community trust, friendships, rivalries and access to opportunities.

This is a development premise, not a locked final script. Before production, write a story bible covering protagonist identity, supporting cast, antagonist motivations, timeline, themes, chapter arcs, dialogue voice, cultural review and branching consequences.

### Storytelling modes

**Cinematic:** opening and closing sequences, character introductions, major revelations, mission transitions and emotional turning points.

**Interactive:** branching dialogue, reputation changes, relationship progression, optional objectives, selected mission variants and consequences that persist into later chapters.

Choices must be legible and authored. Avoid fake choices that produce no discernible consequence. Use a manageable narrative state model rather than unconstrained branching that multiplies content beyond the team's capacity.

### Proposed first arc

1. Back to Lagos — arrival, controls, neighbourhood orientation and first relationships.
2. Street Connections — meet allies and learn local dynamics.
3. The First Hustle — take on work and establish a starting economy.
4. Trouble in the Neighbourhood — discover a conflict affecting the community.
5. The Rival — confront a competing interest and make a consequential choice.
6. Bigger Opportunities — unlock new contacts, activities and district access.
7. The Turning Point — resolve the opening arc and establish the next goal.

Chapter names and plot details remain provisional until the narrative bible is approved.

## 5. Core gameplay loop

**Explore → discover a person, place or opportunity → accept a mission → complete objectives → receive rewards and consequences → develop skills, relationships or reputation → unlock new opportunities.**

Gameplay categories may include story and relationship missions, delivery and transport activities, street races and time trials, football and neighbourhood competitions, exploration and collectibles, business activities, community events and optional challenges.

Every activity must have a clear purpose, satisfying controls, understandable objectives and a reward or narrative consequence. Do not add activities solely to inflate the feature list.

## 6. Player progression and economy

Progression should reward skill, exploration, relationships and mission completion. Potential systems include character skills, earnable in-game currency, outfits, hairstyles, accessories, vehicle access and customisation, district reputation, relationships, achievements and optional challenges.

Keep the economy understandable and avoid pay-to-win advantages. Purchased content, if introduced, should be optional and clearly distinguished from earned progression.

## 7. Character direction

Kemi is the first character confirmed visible and playable on the owner's Samsung Galaxy A16, with walking, running and jumping verified by the owner. Tunde and Amara are proposed roster additions under PR #10 and are not yet confirmed playable in the district.

Characters need distinct silhouettes, motivations, speech patterns, wardrobe logic, animation performance and story functions. Each character's identity must be specific and fictional, supported by references and a provenance record.

## 8. Monetisation principles

Monetisation is a later-stage workstream, not a current implementation task.

Potential channels:
1. Opt-in rewarded ads for clearly disclosed optional rewards.
2. Limited interstitial ads only at natural breaks, never during active gameplay, races, dialogue or critical story moments.
3. Brand partnerships integrated into suitable fictional-world surfaces or sponsored events.
4. Optional cosmetic purchases that do not create pay-to-win advantages.

Before integration, evaluate provider terms, supported regions, age requirements, privacy disclosures, consent flows, data minimisation, frequency caps, offline behavior and platform policies. Do not select an SDK or create accounts/spend money without owner approval.

## 9. Technical and production constraints

- Preserve the existing Godot 4.3 project and tested movement/controller foundation.
- Treat the Samsung Galaxy A16 as the first physical-device performance baseline, not the only supported device.
- Establish measurable budgets for frame time, memory, draw calls, textures, meshes, animation, audio and loading.
- Use LOD, visibility/occlusion culling, texture compression, efficient materials and scalable settings where profiling justifies them.
- Profile actual exported Android builds. Headless tests and desktop renders do not prove Android performance.
- Keep editable sources, reproducible build steps, asset provenance and license information.
- Do not introduce paid services, assets, SDKs or subscriptions without explicit approval.

## 10. Product quality gates

A feature is not complete because it exists in a plan, screenshot, code branch or successful headless test.

Acceptance evidence must match the feature:
- Visual assets: approved in-engine renders and review on target hardware.
- Gameplay: repeatable interaction tests and physical-device playtest.
- Performance: measurements on named devices and build hashes.
- Story: script review, choice-state tests and narrative continuity review.
- Monetisation: sandbox testing, consent/privacy review and platform-policy check.

## 11. Current verified baseline and boundaries

- Kemi is visible in the actual Android game build marked KEMI-CHECK-01; the owner reported walking, running and jumping all work on the Samsung Galaxy A16.
- PR #9 contains the playable Kemi integration and remains a separate unmerged pull request at the time this document was created.
- PR #10 adds Tunde and Amara to the character roster/standalone selection experience; it does not yet make them playable in the district and its Android device performance is unverified.
- The first district is still an early greybox, not a premium finished Lagos environment.
- Vehicles, traffic simulation, mission engine, branching story, progression, ads and full open-world systems remain future work.

## 12. Immediate priorities

1. Record and review Kemi's physical-device acceptance evidence; complete PR #9 review without merging without owner approval.
2. Audit PR #10 for asset quality, provenance, roster integration and mobile performance risks.
3. Approve the premium visual bible and measurable character/environment asset standards.
4. Produce a visual benchmark scene and one character-quality iteration before expanding the roster.
5. Design the first district vertical slice and opening story chapter.
6. Implement systems only after their scope, dependencies and acceptance criteria are documented.
