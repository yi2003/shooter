extends CharacterBody2D

@export var speed: float = 80.0
@export var jitter_angle: float = 0.5

var player: CharacterBody2D
var _jitter: float = 0.0
var _timer: Timer

func _ready() -> void:
	player = get_node("../Player")
	_timer = Timer.new()
	_timer.timeout.connect(_update_jitter)
	add_child(_timer)
	_update_jitter()

func _update_jitter() -> void:
	_jitter = randf_range(-jitter_angle, jitter_angle)
	_timer.start(randf_range(0.3, 0.8))

func _physics_process(_delta: float) -> void:
	if player == null:
		return
	var direction := (player.global_position - global_position).normalized().rotated(_jitter)
	velocity = direction * speed
	move_and_slide()
	$AnimatedSprite2D.play("run")
