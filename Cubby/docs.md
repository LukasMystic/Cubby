# Game Page

A 2D open-world game screen where the player moves a character around using a virtual joystick and interacts with NPCs through a dialogue system.

---

## Data Flow

```
JoystickMonitor (input)
       ↓
GameViewModel — reads joystick, computes position & animation state
       ↓
GameScene — renders character sprite based on ViewModel state
GameView  — shows HUD (joystick, interact button, dialogue overlay)
```

Player presses **Interact** → `GameViewModel.interact()` → (future) loads a `Conversation` from JSON → `DialogueOverlay` shows lines → tap to advance → auto-dismiss at end.

---

## TODO

- [ ] Make the interaction dialogue page
- [ ] Find another asset to make a template for the NPC
- [ ] Make NPCs interactable using the interact button
- [ ] Highlight the player when they are within approachable distance of an NPC
- [ ] Make a JSON decode parser for the DataModel
