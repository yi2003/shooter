extends CharacterBody2D

@export var speed: float = 80.0
@export var jitter_angle: float = 0.5
@export var health: float = 2.0

var player: CharacterBody2D
var _jitter: float = 0.0
var _timer: Timer
var _dead: bool = false

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
	if _dead or player == null:
		return
	var direction := (player.global_position - global_position).normalized().rotated(_jitter)
	velocity = direction * speed
	move_and_slide()
	$AnimatedSprite2D.play("run")

func take_damage(amount: float) -> void:
	if _dead:
		return
	health -= amount
	if health <= 0:
		_die()

func _die() -> void:
	_dead = true
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.play("dead")
	velocity = Vector2.ZERO
	await get_tree().create_timer(0.5).timeout
	queue_free()
