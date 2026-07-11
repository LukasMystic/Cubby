# Joey & Mia Story Data

This folder contains JSON data for the English version of the interactive branching story **Joey & Mia**.

These files contain story content, not application code. The approved technical IDs, routing, node order, character states, and asset references must remain unchanged so the game backend can read the story safely.

## Location

```text
data/stories/joey-mia/
```

## Story Structure

```text
opening.json
└── Joey's Decision
    ├── 1.json
    │   ├── 1A.json
    │   ├── 1B.json
    │   └── 1C.json
    │
    ├── 2.json
    │   ├── 2A.json
    │   ├── 2B.json
    │   └── 2C.json
    │
    └── 3.json
        ├── 3A.json
        ├── 3B.json
        │   ├── 3b(i).json
        │   └── 3b(ii).json
        └── 3C.json
```

## Notes

- `main.json` is the story map/router and is not displayed as a scene.
- `opening.json` is the beginning of the story.
- Each branch file contains a `storybook_page` for the storybook screen.
- Path `3B(i)` displays three storybook pages: `3.json`, `3B.json`, and `3b(i).json`.
- Path `3B(ii)` displays three storybook pages: `3.json`, `3B.json`, and `3b(ii).json`.
- On every decision screen, Joey remains the first character entry and both characters remain `Idle`.
- `NeutralTalk` is used only when a Neutral character is the active speaker.
- A non-Neutral emotion keeps its emotion asset whether the character is Talking or Idle.

## Do Not Change

Do not translate or modify technical fields such as `branch_id`, `node_id`, `ending_id`, `connects_from`, `connects_to`, `target_file`, `choice_quality`, `expression_key`, `speech_state`, or `asset_file`.
