# Character State Audit

- Story text, node order, storybook content, IDs, and routing were not changed.
- Visual nodes audited: 60
- NeutralTalk is used only for a Neutral character who is the active speaker.
- A non-speaking character always has `speech_state: Idle`.
- Non-Neutral emotions keep their emotion asset whether Talking or Idle.

## Joey NeutralTalk nodes
- `3.json` / `3_001_dialogue`
- `3A.json` / `3A_001_dialogue`

## Mia NeutralTalk nodes
- None in Story 1-10. Mia's story dialogue always carries a stronger emotion.
