extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 3.0

var spawn_points: Array[Marker2D] = []

func _ready() -> void:
	_collect_spawn_points()
	$Timer.wait_time = spawn_interval
	$Timer.timeout.connect(_spawn_enemy)
	$Timer.start()

func _collect_spawn_points() -> void:
	for group in get_children():
		if group is Node2D:
			for child in group.get_children():
				if child is Marker2D:
					spawn_points.append(child)

func _spawn_enemy() -> void:
	if spawn_points.is_empty() or enemy_scene == null:
		return
	var point := spawn_points[randi() % spawn_points.size()]
	var enemy := enemy_scene.instantiate()
	enemy.position = point.position
	get_parent().add_child(enemy)
