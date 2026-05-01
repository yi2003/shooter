extends CharacterBody2D

signal died

@export var speed: float = 80.0
@export var jitter_angle: float = 0.5
@export var health: float = 2.0
@export var contact_damage: float = 1.0
@export var contact_cooldown: float = 1.0

var player: CharacterBody2D
var _jitter: float = 0.0
var _jitter_timer: Timer
var _dead: bool = false
var _player_in_range: bool = false
var _contact_timer: Timer

func _ready() -> void:
	player = get_node("../Player")
	print(name, " spawned at ", global_position, " - player found: ", player != null)

	_jitter_timer = Timer.new()
	_jitter_timer.timeout.connect(_update_jitter)
	add_child(_jitter_timer)
	_update_jitter()

	_contact_timer = Timer.new()
	_contact_timer.one_shot = true
	add_child(_contact_timer)

	var hitbox: Area2D = Area2D.new()
	hitbox.collision_layer = 0
	hitbox.collision_mask = 2
	var hitbox_shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = 5.0
	hitbox_shape.shape = circle
	hitbox.add_child(hitbox_shape)
	hitbox.body_entered.connect(func(b: Node2D): _on_player_touch(b, true))
	hitbox.body_exited.connect(func(b: Node2D): _on_player_touch(b, false))
	add_child(hitbox)

func _update_jitter() -> void:
	_jitter = randf_range(-jitter_angle, jitter_angle)
	_jitter_timer.start(randf_range(0.3, 0.8))

func _physics_process(_delta: float) -> void:
	if _dead or player == null:
		return
	var direction := (player.global_position - global_position).normalized().rotated(_jitter)
	velocity = direction * speed
	move_and_slide()
	$AnimatedSprite2D.play("run")

func _on_player_touch(body: Node2D, entered: bool) -> void:
	if body != player:
		return
	_player_in_range = entered
	if entered:
		_deal_contact_damage()

func _deal_contact_damage() -> void:
	if _dead or not _player_in_range:
		return
	if player.has_method("take_damage"):
		player.take_damage(contact_damage)
	_contact_timer.start(contact_cooldown)
	_contact_timer.timeout.connect(_deal_contact_damage, CONNECT_ONE_SHOT)

func take_damage(amount: float) -> void:
	if _dead:
		return
	health -= amount
	if health <= 0:
		_die()

func _die() -> void:
	_dead = true
	died.emit()
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.play("dead")
	velocity = Vector2.ZERO
	await get_tree().create_timer(0.5).timeout
	queue_free()
