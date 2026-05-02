extends CanvasLayer

@onready var _hp_label: Label = $Panel/HBox/HP/Value
@onready var _wave_label: Label = $Panel/HBox/Wave/Value
@onready var _enemies_label: Label = $Panel/HBox/Enemies/Value

var _player: CharacterBody2D
var _spawner: Node

func _ready() -> void:
	_player = get_node("../Player")
	_spawner = get_node("../EnemySpawner")
	_spawner.stats_changed.connect(_update_stats)
	_update_stats()

func _process(_delta: float) -> void:
	if is_instance_valid(_player):
		_hp_label.text = "%d/%d" % [_player.health, _player.max_health]

func _update_stats() -> void:
	_wave_label.text = str(_spawner.current_wave)
	_enemies_label.text = str(_spawner.enemies_alive)
