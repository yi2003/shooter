extends CanvasLayer

func _ready() -> void:
	var player: Node = get_node("../Player")
	player.died.connect(_on_player_died)
	$Panel/VBox/PlayAgain.pressed.connect(_on_play_again)

func _on_player_died() -> void:
	var spawner: Node = get_node("../EnemySpawner")
	spawner.stop_spawning()
	$Panel/VBox/WavesLabel.text = "Waves Survived: " + str(spawner.current_wave)
	visible = true

func _on_play_again() -> void:
	get_tree().reload_current_scene()
