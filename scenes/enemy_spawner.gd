extends Node2D

@export var enemy_scene: PackedScene
@export var base_enemies: int = 3
@export var enemies_increase: int = 2
@export var spawn_interval: float = 2.0
@export var wave_delay: float = 3.0

signal stats_changed()

var spawn_points: Array[Marker2D] = []
var _available_points: Array[Marker2D] = []
var current_wave: int = 0
var enemies_to_spawn: int = 0
var enemies_spawned: int = 0
var enemies_alive: int = 0
var countdown: int = 0
var _wave_ending: bool = false

func _ready() -> void:
	_collect_spawn_points()
	$Timer.wait_time = spawn_interval
	$Timer.one_shot = false
	$Timer.timeout.connect(_try_spawn_enemy)
	_start_next_wave()

func _collect_spawn_points() -> void:
	for group in get_children():
		if group is Node2D:
			for child in group.get_children():
				if child is Marker2D:
					spawn_points.append(child)

func _start_next_wave() -> void:
	_wave_ending = false
	current_wave += 1
	enemies_to_spawn = base_enemies + (current_wave - 1) * enemies_increase
	enemies_spawned = 0
	enemies_alive = 0
	_available_points.assign(spawn_points)
	_available_points.shuffle()
	print("Wave ", current_wave, " started, spawning ", enemies_to_spawn, " enemies")
	stats_changed.emit()
	call_deferred("_try_spawn_enemy")
	$Timer.start()

func _try_spawn_enemy() -> void:
	if _wave_ending or enemies_spawned >= enemies_to_spawn:
		$Timer.stop()
		return
	_spawn_enemy()

func _spawn_enemy() -> void:
	if spawn_points.is_empty() or enemy_scene == null:
		return
	if _available_points.is_empty():
		_available_points.assign(spawn_points)
		_available_points.shuffle()
	var point: Marker2D = _available_points.pop_back()
	var offset: Vector2 = Vector2(randf_range(-20, 20), randf_range(-20, 20))
	var enemy: Node = enemy_scene.instantiate()
	enemy.position = point.position + offset
	enemy.died.connect(_on_enemy_died)
	enemy.get_node("AnimatedSprite2D").modulate = Color(
		randf_range(0.6, 1.0), randf_range(0.6, 1.0), randf_range(0.6, 1.0)
	)
	get_parent().add_child(enemy)
	enemies_spawned += 1
	enemies_alive += 1
	print("  Spawned enemy ", enemies_spawned, "/", enemies_to_spawn, " at ", enemy.position, " (alive: ", enemies_alive, ")")
	stats_changed.emit()

func stop_spawning() -> void:
	$Timer.stop()
	_wave_ending = true

func _on_enemy_died() -> void:
	enemies_alive -= 1
	print("  Enemy died (alive: ", enemies_alive, ", spawned: ", enemies_spawned, "/", enemies_to_spawn, ")")
	stats_changed.emit()
	if enemies_spawned >= enemies_to_spawn and enemies_alive <= 0 and not _wave_ending:
		_wave_ending = true
		for i in range(int(wave_delay), 0, -1):
			countdown = i
			stats_changed.emit()
			await get_tree().create_timer(1.0).timeout
		countdown = 0
		stats_changed.emit()
		_start_next_wave()
