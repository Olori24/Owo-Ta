# OWO TÀ — Narrative Bible and Opening Chapter Blueprint

**Status:** Working proposal for owner review  
**Design pillars:** Premium Nigerian urban adventure · Hybrid districts · Cinematic + interactive storytelling  
**Scope:** Story architecture and a testable opening vertical slice. This document does not claim these systems are implemented.

## 1. Narrative promise

The player enters a recognisable, fictionalised Lagos where opportunity, loyalty, ambition and community obligations collide. The story is grounded in everyday stakes before expanding into bigger conflicts. The city is not a backdrop: its people, businesses, transport, neighbourhoods and social networks create the missions.

The tone should combine tension, humour, warmth and consequence. Avoid caricature, poverty tourism, glorification of crime, or treating Lagos as a single uniform place.

## 2. Player-character policy

Kemi is the current playable prototype character. The game should eventually support a selected protagonist/character roster, but the narrative must not assume that every roster character has identical biography or dialogue.

Until the owner approves a protagonist canon:
- Use a player-defined lead in narrative documents.
- Keep the opening scenes compatible with Kemi as the initial playable avatar.
- Write dialogue with character-specific voice tags, not generic interchangeable lines.
- Do not lock family history, age, ethnicity, religion, or other personal biography without explicit creative approval.

## 3. Core cast roles (provisional)

| Role | Narrative function | Design requirement |
| --- | --- | --- |
| Player character | Learns the district and chooses how to respond to pressure | Agency; no forced personality assumptions |
| Trusted local contact | Introduces neighbourhood relationships and opportunities | Helpful but has independent goals |
| Ambitious peer | Offers competition, collaboration and optional challenges | Not a one-note rival |
| Community business owner | Connects missions to the local economy | Has stakes beyond serving as a quest giver |
| District antagonist | Creates the opening conflict through competing interests | Understandable motive; not an ethnic/social stereotype |
| Supporting ensemble | Vendors, drivers, neighbours, workers and friends | Distinct voices and believable daily routines |

Names, biographies and final casting remain to be approved.

## 4. Opening chapter: "Back on the Block" (working title)

**Player outcome:** Understand movement and camera, meet two recurring characters, complete a first useful task, make one meaningful low-risk choice, and unlock the next mission.

### Sequence A — Arrival
- Short cinematic establishes the district, time of day and immediate personal objective.
- Keep the sequence skippable after first viewing.
- Transition directly to player control; no long exposition.
- Teach camera look and movement in context.

### Sequence B — Find your contact
- A visible landmark guides the player to a local contact.
- Dialogue introduces a small neighbourhood problem and two possible approaches.
- Objective marker remains readable without obscuring the character or touch controls.

### Sequence C — First errand
- A short delivery/collection/repair-support task teaches navigation and interaction.
- The task uses a compact route with one optional discovery.
- Completion gives a modest, clearly explained in-game reward.

### Sequence D — The choice
The player chooses between two approaches to resolving a local disagreement:
- **Relationship-first:** spend time helping one party; gain trust with that character.
- **Efficiency-first:** solve the immediate task faster; gain a different contact/opportunity.

Both choices must progress the chapter. Their consequences differ in dialogue, relationship flags and one later optional opportunity. Do not block the main story behind a single choice.

### Sequence E — Chapter close
- A short scene reveals that the small problem is connected to a wider district issue.
- Unlock the next mission and show a concise recap of the player's choice.
- Return control quickly; avoid a long cutscene after a first-session tutorial.

## 5. Mission data contract

Every mission should be data-driven and define:
- Stable mission ID and chapter ID.
- Display title, short description and briefing.
- Start condition and prerequisite flags.
- Ordered and optional objectives.
- Objective completion/failure conditions.
- Dialogue/choice references.
- Rewards and relationship/reputation deltas.
- Checkpoint and retry policy.
- Completion flags and next-mission unlocks.
- Localization-ready text keys.
- Analytics events limited to necessary, privacy-reviewed gameplay telemetry.

Mission state must be explicit and serialisable. Avoid embedding mission progression in UI nodes or hard-coding it into the player controller.

## 6. Choice and consequence model

Use a compact state model rather than branching the entire story at every decision.

Suggested state categories:
- Relationship values per recurring character.
- District reputation.
- Boolean story flags for significant decisions.
- Mission completion and unlock flags.
- Player-selected character and cosmetic state.

A choice must specify:
1. What the player sees before choosing.
2. Immediate feedback.
3. The state change.
4. Where the consequence becomes visible again.
5. Whether it is reversible.

Do not advertise a choice as consequential unless at least one authored later response, opportunity, reward or mission variant reads that state.

## 7. Dialogue and cinematic standards

- Dialogue lines should be short enough for mobile reading and voice performance.
- Distinguish character voices through rhythm, vocabulary, humour and priorities.
- Nigerian English and local language use should be natural, character-specific and reviewed; avoid forced slang.
- Provide subtitles and adjustable text speed.
- Keep camera cuts motivated and avoid rapid motion that may cause discomfort.
- Every cinematic must have a skip path and restore gameplay state correctly.
- Do not require expensive facial animation for every line in the first vertical slice; prioritise body pose, framing, timing and strong writing.

## 8. Engagement and replayability

Build retention from meaningful play, not manipulative friction:
- Clear short-term goals and visible progress.
- Optional missions with distinct rewards.
- Collectibles tied to world discovery and character stories.
- Time trials and skill challenges with fair retry loops.
- Relationships that change dialogue and opportunities.
- Chapter recaps and a mission journal.
- Daily/limited-time content only if it can be operated reliably and fairly.

Avoid energy timers, punitive streak loss, forced ad views, artificial wait walls and pay-to-win progression.

## 9. First vertical-slice acceptance criteria

The opening chapter is accepted only when:
- A new player can start, learn controls and finish the chapter without external instructions.
- Mission objectives update reliably and recover correctly after interruption/restart.
- Dialogue and choice UI are readable and usable on the Galaxy A16.
- Both choice paths complete the chapter and produce a later observable difference.
- Rewards and unlocks are granted once, not duplicated on retries.
- Cinematics can be skipped without soft-locking the mission.
- The chapter runs in an exported Android build and is physically playtested.
- The test record identifies APK hash, commit, device model/build and observed defects.

## 10. Writing and cultural review

Before dialogue is locked:
- Review place names, transport details, work routines, business practices and local references.
- Avoid presenting invented details as documentary facts about real neighbourhoods.
- Use fictional businesses and signage unless a real partnership is approved.
- Review character motivations and humour for stereotypes and unintended harm.
- Maintain a glossary and style sheet for names, pronunciation, language and recurring terms.

## 11. Open creative decisions for owner approval

The following remain deliberately open:
- Canonical protagonist identity and biography.
- Exact real-world inspiration and fictional district names.
- Central conflict and antagonist motivation.
- Character relationship map and cast names.
- Language mix and voice performance approach.
- Whether the player can switch characters during the story or only before starting.
- The exact first mission and reward economy.

These decisions should be resolved before production dialogue and cinematic assets are commissioned.
