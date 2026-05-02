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
├── enemy_spawner.gd    - Wave-based enemy spawner
├── bullet.tscn         - Bullet projectile (Area2D)
├── bullet.gd           - Bullet movement and damage script
├── hud.tscn            - Bottom HUD (HP, wave, enemies)
├── hud.gd              - HUD update script
├── item.tscn           - Item pickup (Area2D)
├── item.gd             - Item pickup script (COFFEE, GUN, HEART)
├── explosion.tscn      - Enemy death explosion effect
├── explosion.gd        - Expanding ring explosion animation
├── game_over.tscn      - Game over screen (CanvasLayer)
├── game_over.gd        - Game over script with restart
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
- **Health:** `health`: 10.0, `max_health`: 10.0 (configurable via `@export`)
  - `invincible_time`: 1.0s invincibility after taking damage
  - Takes damage from enemy contact via `take_damage()`
- **Item Pickups:** `apply_item_effect()` handles collected items
  - COFFEE: 1.5x speed boost for 5s (refreshes on re-pickup)
  - GUN: fire rate boost (0.1s cooldown) for 5s (refreshes on re-pickup)
  - HEART: +3 HP (capped at `max_health`)
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
- **Contact Damage:** Area2D hitbox (CircleShape2D, radius 5) detects player on layer 2
  - `contact_damage`: 1.0 per tick (configurable via `@export`)
  - `contact_cooldown`: 1.0s between damage ticks
- **Collision:** Layer 3, scans layer 1 (bushes only — passes through player)
- **Animations:** idle (4 frames, autoplay), run (4 frames), dead (1 frame)
- **Spawn:** Wave-based spawning via EnemySpawner
  - Wave 1: 3 enemies, +2 per wave (`base_enemies` / `enemies_increase`)
  - Enemies spawn one at a time every 2s (`spawn_interval`)
  - Next wave starts 3s after all enemies killed (`wave_delay`)
  - Each enemy gets a unique spawn point + ±20px random offset
  - Random modulate tint per enemy for visual distinction
- **Spawn Points:** 12 markers around map edges (Top/Right/Bottom/Left, 3 each)
- **Item Drops:** 30% chance to drop an item on death (`drop_chance`)
  - Weighted random: coffee 30%, gun 30%, heart 40% (configurable via `@export`)
  - Items spawn at the enemy's death position

### Item System
- **Node Type:** Area2D
- **Scene:** item.tscn (Sprite2D + CollisionShape2D)
- **Script:** item.gd with `ItemType` enum (COFFEE, GUN, HEART)
- **Visual:** Sprite2D texture set from `assets/items/` based on `item_type`
- **Collision:** collision_layer=0, collision_mask=2 (detects player on layer 2)
- **Interaction:** On `body_entered`, calls `apply_item_effect()` on player, then queue_free

### Bullet System
- **Node Type:** Area2D
- **Visual:** Drawn via `_draw()` as a small yellow circle (3px radius, no sprite needed)
- **Speed:** 400 px/s (configurable via `@export var speed`)
- **Damage:** 1.0 per hit (configurable via `@export var damage`)
- **Lifetime:** 2.0 seconds, self-destructs on timeout or collision
- **Collision:** collision_mask = 5 (layers 1 and 3: bushes and enemies)
- **Interaction:** Calls `take_damage()` on any body with that method, then queue_free

### HUD System
- **Node Type:** CanvasLayer
- **Position:** Bottom bar, semi-transparent black panel (60px tall)
- **Displays:** HP (live from player), WAVE (current wave number), ENEMIES (alive count)
- **Update:** HP via `_process`, wave/enemies via `stats_changed` signal from spawner

### Game Over System
- **Node Type:** CanvasLayer (renders on top of HUD)
- **Trigger:** Connects to player's `died` signal in `_ready()`
- **Display:** Full-screen purple panel (85% opacity) with "GAME OVER" title, waves survived count, and "Play Again" button
- **Restart:** Button calls `get_tree().reload_current_scene()`
- **Cleanup:** Calls `stop_spawning()` on the spawner to halt enemy waves

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
@export var spawn_interval: float = 2.0  # Seconds between spawns
```

### Change Drop Rates
```gdscript
# In enemy.gd, modify:
@export var drop_chance: float = 0.3     # 0.0-1.0, chance any item drops
@export var coffee_weight: float = 0.3   # Relative weight for coffee
@export var gun_weight: float = 0.3      # Relative weight for gun
@export var heart_weight: float = 0.4    # Relative weight for heart
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

### Change Wave Settings
```gdscript
# In enemy_spawner.gd, modify:
@export var base_enemies: int = 3        # Enemies in wave 1
@export var enemies_increase: int = 2    # Extra enemies per subsequent wave
@export var spawn_interval: float = 2.0   # Seconds between spawns
@export var wave_delay: float = 3.0      # Seconds before next wave
```

## Known Constraints
- Viewport: 768x816 pixels
- World extends beyond viewport (scrolling not implemented)
- No respawn or level progression beyond scene reload

## Git Workflow
- Main branch: `main`
- Commit messages: Use conventional commits (feat:, fix:, etc.)
- Always test in Godot before committing
