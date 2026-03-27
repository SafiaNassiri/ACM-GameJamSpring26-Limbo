# ACM-GameJamSpring26-Limbo

[Insert short description of the game]

---

# Project Overview

This repository contains the source project for **Limbo**, built using **Godot Engine 4.6.1**.

---

# Engine Version

This project uses:

Godot **4.6.1**

Using a different version of Godot may cause compatibility issues.

Download Godot here:  
https://godotengine.org/download

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

The full design documentation can be found here:

**Game Design Document:**  
[Limbo — GDD] (https://docs.google.com/document/d/1B1OkL54kuCSKMvNLnGaY3PXOqg9lsm8Z3Sr2Op7jubQ/edit?tab=t.0#heading=h.z6ne0og04bp5)

All contributors should review the GDD before implementing major features.
Make sure to update the GDD as you work.

---

# Project Folder Structure

The project is organized by **asset type and system responsibility** to keep the codebase clean and scalable.

```
project-root/
│
├── assets/
│   Art, textures, sprites, models, and other visual assets.
│
├── audio/
│   Music, sound effects, and voice assets.
│
├── scenes/
│   Godot scene files (.tscn) used for levels, menus, and gameplay elements.
│
├── scripts/
│   GDScript files that control game logic.
│
├── prefabs/
│   Reusable scene templates such as enemies, items, or UI components.
│
├── ui/
│   UI layouts, HUD elements, and menu scenes.
│
├── shaders/
│   Custom shaders used by the rendering pipeline.
│
├── data/
│   Structured gameplay data such as item stats, configuration files, and balance values.
│
├── project.godot
│   Main Godot project configuration file.
│
└── README.md
    Project overview and setup instructions.
```

---

# Development Guidelines

### Follow consistent naming conventions

Example:

```
PlayerController.gd
EnemySpawner.gd
MainMenu.tscn
Level_Forest_01.tscn
```

Avoid vague names like:

```
test.gd
thing.gd
new_scene.tscn
```
