# CLAUDE.md - Godot Shooter Project

## Project Overview
A 2D top-down shooter game built with Godot 4.6. Players control a character that can move in 8 directions and fight enemies that spawn from the edges of the map.

## Tech Stack
- **Engine:** Godot 4.6 (Forward Plus renderer)
- **Physics Engine:** Jolt Physics (3D), Godot Physics (2D)
- **Rendering:** DirectX 12 on Windows
- **Language:** GDScript

## Project Structure
```
scenes/
├── main.tscn           - Main game scene (entry point)
├── world.tscn          - TileMapLayer with grass and bushes
├── player.tscn         - Player character (CharacterBody2D)
├── player.gd           - Player movement script (8-directional)
├── enemy.tscn          - Goblin enemy (CharacterBody2D)
├── enemy.gd            - Enemy AI script (chase player with jitter)
├── enemy_spawner.gd    - Spawns enemies at random Marker2D points
├── bullet.tscn         - Bullet projectile (Area2D)
├── bullet.gd           - Bullet movement and damage script
assets/
├── player/             - 8 directional sprites (E, N, NE, NW, S, SE, SW, W)
├── enemies/goblin/     - Goblin sprites (idle, run, dead animations)
├── items/              - Pickup items (health, gun, coffee boxes)
├── Grass.png           - TileSet texture for world
```

## Controls
| Action | Keys |
|--------|------|
| Move Up | W / Up Arrow |
| Move Down | S / Down Arrow |
| Move Left | A / Left Arrow |
| Move Right | D / Right Arrow |
| Shoot | Space |

## Game Architecture

### Player System
- **Node Type:** CharacterBody2D
- **Movement:** Uses `Input.get_vector()` for normalized 8-directional movement
- **Speed:** 200 px/s (configurable via `@export var speed`)
- **Shooting:** Press Space (`ui_accept`) to fire bullets in the last movement direction
  - `shoot_cooldown`: 0.3s between shots (configurable via `@export`)
  - Bullets spawn as children of Main
- **Animations:** 8 directional animations (E, N, NE, NW, S, SE, SW, W)
- **Scale:** 3x3 (matches world scale)

### Enemy System
- **Scene:** enemy.tscn (CharacterBody2D)
- **Script:** enemy.gd
- **AI Behavior:** Enemies chase the player with randomized jitter for organic movement
  - `speed`: 80 px/s (configurable via `@export`)
  - `jitter_angle`: ±0.5 rad max deviation from direct path, re-randomized every 0.3–0.8s
  - Finds player via `get_node("../Player")` (both are children of Main)
- **Health:** `health`: 2.0 (configurable via `@export`), takes damage from bullets
  - On death: plays "dead" animation, disables collision, frees after 0.5s
- **Collision:** Layer 3, scans layer 1 (bushes only — passes through player)
- **Animations:** idle (4 frames, autoplay), run (4 frames), dead (1 frame)
- **Spawn:** EnemySpawner uses Timer + Marker2D nodes
- **Spawn Points:** 12 markers around map edges (Top/Right/Bottom/Left, 3 each)
- **Spawn Interval:** 3 seconds (configurable)

### Bullet System
- **Node Type:** Area2D
- **Visual:** Drawn via `_draw()` as a small yellow circle (3px radius, no sprite needed)
- **Speed:** 400 px/s (configurable via `@export var speed`)
- **Damage:** 1.0 per hit (configurable via `@export var damage`)
- **Lifetime:** 2.0 seconds, self-destructs on timeout or collision
- **Collision:** collision_mask = 5 (layers 1 and 3: bushes and enemies)
- **Interaction:** Calls `take_damage()` on any body with that method, then queue_free

### World System
- **TileMap:** Grass (ground) + Bushes (collision)
- **Scale:** 3x3
- **Collision:** Bush tiles have physics_layer_0 with collision_layer = 1
- **Tile Size:** 16x16 pixels (scaled to 48x48)

### Collision Layers
| Layer | Belongs To | Scans (Mask) |
|-------|-----------|--------------|
| 1 | Bushes (TileMap) | — |
| 2 | Player | Layer 1 (bushes) |
| 3 | Enemy | Layer 1 (bushes) |

Enemies and the player pass through each other (different layers, masks don't cross). Both collide with bushes on layer 1.

### Camera
- **Position:** (387, 431) - centered on play area
- **Zoom:** 0.75 (shows more of the map)

## Key Patterns

### Adding New Enemies
1. Create sprite assets in `assets/enemies/[name]/`
2. Create scene with CharacterBody2D + AnimatedSprite2D + CollisionShape2D
3. Add to enemy_spawner.gd's `enemy_scene` export

### Modifying Spawn Points
Edit Marker2D positions in `main.tscn` under EnemySpawner node:
- Top/Right/Bottom/Left groups contain 3 markers each
- Positions are in world coordinates (account for 3x scale)

### TileMap Collision
- Bushes TileSet has physics_layer_0 with collision_layer = 1
- Tile at atlas (6, 0) has collision polygon: `PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)`
- Player collides with layer 1 (mask=1), Enemy collides with layer 1 (mask=1)

## Build & Run
1. Open project in Godot 4.6+
2. Press F5 to run (main scene: main.tscn)
3. Use WASD/Arrow keys to move
4. Enemies spawn every 3 seconds from edges

## Common Tasks

### Change Player Speed
```gdscript
# In player.gd, modify:
@export var speed: float = 200.0  # Change this value
```

### Change Spawn Rate
```gdscript
# In enemy_spawner.gd, modify:
@export var spawn_interval: float = 3.0  # Seconds between spawns
```

### Add New Animation
1. Add sprite frames to AnimatedSprite2D in the Inspector
2. Name the animation (e.g., "attack")
3. Call `$AnimatedSprite2D.play("attack")` in script

### Change Enemy AI
```gdscript
# In enemy.gd, modify:
@export var speed: float = 80.0        # Movement speed
@export var jitter_angle: float = 0.5  # Max random angle deviation (radians)
@export var health: float = 2.0        # Hit points (2 bullets to kill by default)
```

### Change Bullet Stats
```gdscript
# In bullet.gd, modify:
@export var speed: float = 400.0   # Projectile speed
@export var damage: float = 1.0    # Damage per hit
@export var lifetime: float = 2.0  # Seconds before auto-destruct
```

### Change Shoot Cooldown
```gdscript
# In player.gd, modify:
@export var shoot_cooldown: float = 0.3  # Seconds between shots
```

## Known Constraints
- Viewport: 768x816 pixels
- World extends beyond viewport (scrolling not implemented)
- Enemies have no attack/damage against the player yet

## Git Workflow
- Main branch: `main`
- Commit messages: Use conventional commits (feat:, fix:, etc.)
- Always test in Godot before committing
