# Game Page

A 2D open-world game screen where the player moves a character around using a virtual joystick and interacts with NPCs through a dialogue system.

---

## Data Flow

```
JoystickMonitor (input)
       ↓
GameViewModel — reads joystick, computes position & animation state
       ↓
GameScene — renders MC sprite + NPC Goblin sprite based on ViewModel state
GameView  — shows HUD (joystick, interact button)
       ↓ (interact pressed near NPC)
DialogueView (fullScreenCover)
       ↓
DialogueViewModel — loads main.json router + scene files, walks sequence nodes
       ↓
Displays speech / narrative / choice buttons → player picks → loads next branch file
```

---

## Camera

`GameScene` uses an `SKCameraNode` with:
- **zoom**: `setScale(0.6)` — 1.7× zoom so characters are clearly visible on screen
- **follow**: every frame, camera position snaps to the MC and is clamped so it never shows outside the world
- **world size**: `worldMultiplier = 2.5` — the world is 2.5× the screen size in both axes, giving the camera room to scroll

Camera clamp formula:
```
halfViewW = screenWidth × cameraScale / 2
camX = clamp(playerX, halfViewW, worldWidth - halfViewW)
```

## World & Background

`GPBackground` is scaled to fill the full world (`worldSize = screen × 2.5`), not just the screen. Player/NPC positions and movement bounds all use `worldSize` coordinates.

## Pause

Pause button (top-right HUD) sets `viewModel.isPaused`, which propagates to `gameScene.isPaused` via `didSet`. Pausing freezes all `SKAction`s and the `update()` loop.

Pause menu has: **Resume**, **Save** (shows a ✓ badge for 1.5s), **Main Menu** (currently just resumes — TODO: wire to NavigationStack).

## Progress Saving

`DialogueViewModel` auto-saves to `Documents/userProgress.json` whenever the player picks a choice at a `decision_point` node. Format: `{ "decisions": { "<nodeId>": "<chosenOption>" } }`. Loaded fresh on each read so it's always up to date.

## App Orientation

Landscape-only. Set in Xcode → Target → General → Supported Destinations → iPhone → Orientation (uncheck Portrait).

---

## TODO

- [x] Make the interaction dialogue page
- [x] Make a JSON decode parser for the DataModel
- [x] Add interaction range indicator — pixel-perfect green outline on NPC using `SKEffectNode` + `CIMorphologyMaximum` (radius 6), fades in/out over 0.2s
- [x] Make NPCs interactable using the interact button
- [x] Add camera follow with zoom
- [x] User progress saving (auto-save on dialogue decisions)
- [x] Pause button and pause menu (Resume / Save / Main Menu)
- [x] Migrate to `@Observable` (iOS 17)
- [x] Lock to landscape orientation
- [ ] Find real NPC asset (currently using placeholder Goblin)
- [ ] Add real map assets — replace placeholder background, set proper collision boundaries
- [ ] Wire Main Menu button in pause menu to NavigationStack
