# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Limbo** is a game built with **Godot Engine 4.6.1** using GDScript. The project is organized by asset type and system responsibility.

## Running the Project (Editor)

There is no CLI build system. Development is done through the Godot editor:

1. Open **Godot 4.6.1** (exact version required — other versions may cause compatibility issues)
2. Click **Import Project** and select `project.godot`
3. Press **F5** to run the game from the editor
4. Use **Project > Export** to build distributable binaries

## Running the Project (Headless)

Run from Git Bash in the project root:

```bash
"/c/Program Files/Godot/Godot_v4.6.1-stable_win64.exe" --headless --path "$(pwd -W)" res://Scenes/Testing/SomeScene.tscn
```

Replace `res://Scenes/Testing/SomeScene.tscn` with the target scene path.

## Running Tests

From Git Bash in the project root:

```bash
bash run_tests.sh
```

Scans all `*.test.gd` files recursively and runs each headlessly. Exit code 0 = all pass, exit code 1 = one or more failures.

Test files must extend `SceneTree` and call `quit(0)` on pass, `quit(1)` on fail:

```gdscript
extends SceneTree

func _init() -> void:
    assert(some_condition, "description of what failed")
    quit(0)
```

## Code Architecture

Scripts are organized by system under `Scripts/`:

- `Core/` — Core game systems
- `Enemies/` — Enemy AI and behavior
- `NPCs/` — NPC logic
- `Player/` — Player controller and mechanics
- `UI/` — UI scripts

Scenes are under `Scenes/`:

- `Levels/` — Level scenes
- `MainMenu/` — Menu scenes
- `Testing/` — Test/prototype scenes

Reusable scene templates live in `Prefabs/Characters/`, `Prefabs/Enemies/`, `Prefabs/Props/`, `Prefabs/UI/`.

## GDScript Conventions

Strict typing is enforced in `project.godot`. Untyped declarations, unsafe property access, unsafe method access, and unsafe casts all produce errors. Always use explicit type annotations in GDScript.

Naming conventions:

- Scripts: `PascalCase.gd` (e.g., `PlayerController.gd`, `EnemySpawner.gd`)
- Scenes: `PascalCase.tscn` for characters/prefabs, `Title_Variant_NN.tscn` for levels (e.g., `Level_Forest_01.tscn`)

## Important (GDScript)

- All variables, parameters, and return types require explicit type annotations. Untyped code is a compile error.
- All functions must declare a return type, including `-> void`.
- String repetition: use `"=".repeat(50)`, not `"=" * 50` (that is Python syntax, not GDScript).

## Assets

Two free art packs are included under `Assets/`:

- `Ninja Adventure - Asset Pack/` — CC0 license (free for commercial use)
- `Cute_Fantasy_Free/` — Free **non-commercial** license only. Do not use these assets in any commercial build.

## Game Design Document

All contributors should review the GDD before implementing major features and keep it updated. (Link to be added in README.)
