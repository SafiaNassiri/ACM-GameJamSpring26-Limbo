# ACM-GameJamSpring26-Limbo

Limbo is a ragebait puzzle game where you play as a QA tester who gets sucked into the game they're supposed to be testing — and the only way out is to entertain Zyra, an all-powerful AI overlord with too much free time and zero empathy. Solve their puzzles. Survive their nonsense. Try not to throw your keyboard.

---

# Project Overview

This repository contains the source project for **Limbo**, built using **Godot Engine 4.6.1**.

Made for the **ACM Game Jam Spring 2026**.
Theme: **Not What It Seems.**

---

# Engine Version

This project uses Godot **4.6.1**.
Using a different version may cause compatibility issues.

Download Godot here: https://godotengine.org/download

---

# Getting Started

1. Clone the repository.
```
git clone https://github.com/SafiaNassiri/ACM-GameJamSpring26-Limbo.git
```
2. Open **Godot 4.6.1**.
3. Click **Import Project**.
4. Select the project folder and open the `project.godot` file.

---

# Game Design Document (GDD)

[Limbo — GDD](https://docs.google.com/document/d/1B1OkL54kuCSKMvNLnGaY3PXOqg9lsm8Z3Sr2Op7jubQ/edit?tab=t.0#heading=h.z6ne0og04bp5)

All contributors should review the GDD before implementing major features. Keep it updated as you work.

---

# Design Philosophy

Limbo is built around one core idea: **nothing is what it seems.**

Every puzzle is designed to subvert the player's expectations. Solutions that look obvious aren't. Buttons lie. Progress bars lie. Doors that look real aren't, and doors that look fake are. The player is never meant to feel in control — they're a jester performing for Zyra, and Zyra makes the rules.

### Ragebait by design
The game is intentionally meant to frustrate, mislead, and inconvenience the player. Puzzle outcomes should feel unfair on the first pass. The fun comes from the absurdity of it, not from clean game feel. If a puzzle doesn't make the player groan, it probably needs more Zyra in it.

### The "Not What It Seems" theme
This applies at every level — mechanics, narrative, and tone. The player thinks they're escaping. Zyra lets them think that. The ending reframes everything: the escape was real, but so is the implication that Zyra is already looking for the next poor soul. The player was never really in control of the outcome.

### Puzzle design decisions
- Puzzles are designed to punish assumption. If a player does the "obvious" thing, it should backfire.
- Teleports and setbacks are intentional. Getting sent backwards is part of the experience.
- Mr. Greene's dialogue is the reward system (a blue NPC created by Zyra). The worse the player does, the more .Mr. Greene talks.

---

# Project Folder Structure
```
project-root/
│
├── assets/         Art, textures, sprites, and visual assets.
├── icons/          Icon files in the following formats: png, ico, icns.
├── audio/          Music, sound effects, and voice assets.
├── scenes/         Godot scene files (.tscn) for levels, menus, and gameplay.
├── scripts/        GDScript files for game logic.
├── prefabs/        Reusable scene templates.
├── ui/             UI layouts, HUD elements, and menu scenes.
├── shaders/        Custom shaders.
├── data/           Config files and gameplay data.
├── project.godot   Main Godot project configuration.
└── README.md       You are here.
```

---

# Development Guidelines

### Naming conventions
```
PlayerController.gd
EnemySpawner.gd
MainMenu.tscn
Level_Forest_01.tscn
```
Avoid:
```
test.gd
thing.gd
new_scene.tscn
```
