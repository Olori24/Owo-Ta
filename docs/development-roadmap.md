# OWO TÀ — Development Roadmap

**Product direction:** Premium stylized realism · Hybrid explorable districts · Cinematic and interactive storytelling  
**Status:** Proposed sequencing; phase completion requires evidence and owner approval.

## Delivery principles

- Build vertical slices that are playable and testable.
- Preserve the current Godot 4.3 foundation and working Android controls.
- Keep PRs focused, branches isolated and dependencies explicit.
- Do not run parallel write tasks against the same files.
- Do not merge pull requests without the project owner's explicit approval.
- Do not introduce paid assets, tools, SDKs, services or subscriptions without approval.
- Distinguish planned features from implemented and device-verified features.

## Phase 0 — Baseline acceptance and review

**Purpose:** Stabilise the proven foundation before adding scope.

Tasks:
- Record the owner's Samsung Galaxy A16 test: Kemi visible; walking, running and jumping working in the KEMI-CHECK-01 build.
- Review PR #9 against its exact head SHA and record the physical-device evidence.
- Audit PR #10's Tunde and Amara assets, import behavior, provenance, animation quality, package cost and Android performance risks.
- Keep PR #10's scope accurately described: roster/selection additions do not yet make Tunde and Amara playable in the district.
- Establish a repeatable APK build and device-test record.

Exit gate:
- Exact commit and APK hash recorded.
- PR review findings resolved or explicitly accepted.
- Kemi's real-device acceptance evidence attached to the project record.
- No unreviewed change is silently merged.

## Phase 1 — Premium visual benchmark

**Purpose:** Agree what premium means in actual game assets.

Tasks:
- Review Kemi, Tunde and Amara against premium-visual-bible.md.
- Produce one approved character benchmark with front, side, back, neutral, walk and run views.
- Produce one small environment benchmark corner with road, pavement, building frontage, signage, props and lighting.
- Define camera distance, portrait framing, material response and readability requirements.
- Profile benchmark assets in an exported Android build.

Exit gate:
- Owner-approved visual reference.
- Documented asset measurements and provenance.
- Godot Forward Mobile render confirmed on baseline device.
- No unacceptable clipping, material or animation defects.
- Performance baseline recorded.

## Phase 2 — Character pipeline and player flow

**Purpose:** Make character choice a real game-flow feature without destabilising movement.

Tasks:
- Audit the existing standalone character-selection scene and typed CharacterDefinition resources.
- Define a game-start flow that consumes a selected character definition.
- Keep physics/controller ownership separate from visual character assets.
- Implement player visual spawning from the selected definition.
- Define save-data schema for selected character and unlock state.
- Test selection, fallback behavior, scene transitions, animations and touch input.

Exit gate:
- Selection screen leads into the actual district.
- Selected character appears as the player visual.
- Existing walking/running/jumping and camera controls still pass.
- Selection persists safely across restart if persistence is in scope.
- Physical-device test passes.

## Phase 3 — First premium Lagos district vertical slice

**Purpose:** Replace the current greybox incrementally with a small, convincing and navigable district.

Tasks:
- Select a compact district block and define its mission/navigation purpose.
- Produce a visual blockout with correct scale, landmarks, road and pedestrian routes.
- Replace high-visibility placeholder geometry with approved modular environment assets.
- Add a restrained set of street props, signs, lighting and ambient audio.
- Add basic world interaction points only where they support the first mission.
- Profile scene complexity and loading on Android.

Exit gate:
- One coherent district can be explored without blockers.
- Navigation landmarks and mission route are readable.
- Performance and memory meet agreed device targets.
- Placeholder geometry is clearly tracked rather than misrepresented as finished content.

## Phase 4 — Opening story chapter and mission framework

**Purpose:** Deliver the first complete narrative experience.

Tasks:
- Approve the story bible, protagonist, supporting cast, opening conflict and dialogue voice.
- Build mission data, objective tracking, triggers, rewards and failure/retry behavior.
- Implement dialogue presentation and branching choice state.
- Add cinematic transitions only where they add narrative value.
- Test choice consequences and save/load behavior.
- Complete a playable opening chapter from start to chapter outcome.

Exit gate:
- Chapter can be completed end-to-end on Android.
- Objectives, dialogue and choice consequences work.
- No progression blockers or lost state.
- Narrative continuity reviewed.

## Phase 5 — Core progression and replayability

**Purpose:** Give players meaningful reasons to explore and return.

Tasks:
- In-game currency ledger and reward rules.
- Skills and character progression.
- Character relationships and district reputation.
- Achievements, optional objectives and time trials.
- Unlockable cosmetics and activities.
- Economy balancing and exploit prevention.

Exit gate:
- Rewards are consistent and auditable.
- Progress survives app restart.
- No pay-to-win requirement.
- Progression supports the narrative and does not create grind without purpose.

## Phase 6 — Vehicles and expanded activities

**Purpose:** Introduce vehicles and more varied gameplay after the district and mission loop are stable.

Tasks:
- Vehicle handling prototype for one vehicle class.
- Vehicle camera, collision, boarding/exiting and touch controls.
- One street race or time-trial activity.
- Vehicle visual standards and performance budgets.
- Expand only after one vehicle/activity is device-tested.

Exit gate:
- Vehicle control is responsive on Android.
- Collisions and camera behavior are stable.
- Activity can be completed and rewards correctly.
- Performance remains within agreed target.

## Phase 7 — World expansion

**Purpose:** Add connected districts and new narrative arcs without diluting quality.

Tasks:
- Prioritise district concepts by story and gameplay value.
- Reuse modular art systems where appropriate.
- Add new characters only against the approved visual bible.
- Add new missions, relationships and optional activities.
- Establish streaming/loading strategy before world scale grows.

Exit gate:
- Each district has distinct identity and purpose.
- Transitions and loading are reliable.
- Content production and performance remain sustainable.

## Phase 8 — Monetisation readiness

**Purpose:** Add revenue only after a stable, engaging core experience exists.

Tasks:
- Evaluate advertising providers and regional support.
- Design opt-in rewarded-ad placements and clear reward disclosures.
- Set strict frequency caps for any interstitial placements.
- Exclude active gameplay, races, dialogue and critical story moments.
- Implement consent/privacy controls and age-appropriate behavior.
- Evaluate optional cosmetics and brand partnerships.
- Test ads in sandbox/test mode before production.

Exit gate:
- Provider terms and platform policies reviewed.
- Privacy and consent flow reviewed.
- Ad frequency and placement tested.
- No deceptive or pay-to-win mechanics.
- Owner explicitly approves production monetisation.

## Phase 9 — Release candidate

Tasks:
- Device compatibility matrix.
- Performance, thermal and memory profiling.
- Crash reporting and analytics with data minimisation.
- Save-data integrity and recovery tests.
- Accessibility, UI scaling and input review.
- Security, privacy, licensing and third-party notice audit.
- Store assets, release notes, support and incident process.

Exit gate:
- Release candidate passes agreed functional, visual, performance, legal and operational checks.
- Exact build, commit and artifact hashes recorded.
- Owner authorises release.

## Parallel work rules

Independent documentation, asset audit and story design can run in parallel when file ownership does not overlap. Gameplay implementation must be sequenced where systems share scenes, controllers or save data.

Every agent task must include:
- Objective and non-goals.
- Base branch and exact starting SHA.
- Owned files/subsystems.
- Files/subsystems that must not be changed.
- Dependencies.
- Acceptance criteria.
- Required test and evidence.
- Explicit instruction not to merge.

A task is not dispatched unless the agent workflow confirms acceptance. A task is not complete until its pull request, exact commit and validation evidence are independently checked.

## Current next actions

1. Complete Phase 0 review and record Kemi device acceptance.
2. Audit PR #10's character assets before treating the expanded roster as production-ready.
3. Produce the Phase 1 visual benchmark.
4. Only then begin Phase 2 character selection integration and Phase 3 district art production.
