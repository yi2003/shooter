# Shooter

A 2D top-down shooter game built with Godot 4.6.

## Controls

| Action | Keys |
|--------|------|
| Move Up | W / Up Arrow |
| Move Down | S / Down Arrow |
| Move Left | A / Left Arrow |
| Move Right | D / Right Arrow |

## Project Structure

```
scenes/
  main.tscn      - Main game scene
  world.tscn      - World/environment
  player.tscn     - Player character (CharacterBody2D)
  player.gd       - Player movement script
assets/
  player/         - 8-directional player sprites (E, N, NE, NW, S, SE, SW, W)
  enemies/        - Enemy sprites (goblin)
  items/          - Pickups (health, gun, coffee boxes)
```

## Requirements

- Godot 4.6+

## Running

Open the project in Godot and press F5 to run.
