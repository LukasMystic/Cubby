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

## TODO

- [x] Make the interaction dialogue page
- [x] Make a JSON decode parser for the DataModel
- [ ] Find another asset to make a template for the NPC
- [ ] Make NPCs interactable using the interact button
- [ ] Add interaction range indicator — highlight/glow on the NPC (or player) when the player enters interact range, and hide it when they walk away
- [ ] Add real map assets — replace the placeholder background with the actual map, set proper scene boundaries, and add collision detection so the player can't walk through walls or off the edge
