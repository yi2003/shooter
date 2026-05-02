extends CharacterBody2D

signal died

@export var speed: float = 200.0
@export var shoot_cooldown: float = 0.3
@export var health: float = 10.0
@export var max_health: float = 10.0
@export var invincible_time: float = 1.0

var _last_dir: Vector2 = Vector2.DOWN
var _shoot_ready: bool = true
var _invincible: bool = false
var _base_speed: float
var _base_shoot_cooldown: float
var _speed_buff_active: bool = false
var _gun_buff_active: bool = false
var _speed_buff_timer: Timer
var _gun_buff_timer: Timer

const BULLET = preload("res://scenes/bullet.tscn")

func _ready() -> void:
	_speed_buff_timer = Timer.new()
	_speed_buff_timer.one_shot = true
	_speed_buff_timer.timeout.connect(_on_speed_buff_expired)
	add_child(_speed_buff_timer)

	_gun_buff_timer = Timer.new()
	_gun_buff_timer.one_shot = true
	_gun_buff_timer.timeout.connect(_on_gun_buff_expired)
	add_child(_gun_buff_timer)

func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	move_and_slide()
	_update_animation(input_dir)

	if input_dir != Vector2.ZERO:
		_last_dir = input_dir

	if Input.is_action_just_pressed("ui_accept") and _shoot_ready:
		_shoot()

func _shoot() -> void:
	_shoot_ready = false
	var bullet := BULLET.instantiate()
	bullet.position = global_position
	bullet.direction = _last_dir.normalized()
	get_parent().add_child(bullet)

	var timer := get_tree().create_timer(shoot_cooldown)
	timer.timeout.connect(func(): _shoot_ready = true)

func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		$AnimatedSprite2D.stop()
		return

	var direction_name := _get_direction_name(dir)
	$AnimatedSprite2D.play(direction_name)

func take_damage(amount: float) -> void:
	if _invincible:
		return
	health -= amount
	print("Player took ", amount, " damage, health: ", health, "/", max_health)
	if health <= 0:
		print("Player died")
		died.emit()
		queue_free()
		return
	_invincible = true
	var timer := get_tree().create_timer(invincible_time)
	timer.timeout.connect(func(): _invincible = false)

func apply_item_effect(item_type: int) -> void:
	match item_type:
		0:  # COFFEE
			if not _speed_buff_active:
				_base_speed = speed
				speed *= 1.5
				_speed_buff_active = true
			_speed_buff_timer.start(5.0)
		1:  # GUN
			if not _gun_buff_active:
				_base_shoot_cooldown = shoot_cooldown
				shoot_cooldown = 0.1
				_gun_buff_active = true
			_gun_buff_timer.start(5.0)
		2:  # HEART
			health = min(health + 3.0, max_health)

func _on_speed_buff_expired() -> void:
	speed = _base_speed
	_speed_buff_active = false

func _on_gun_buff_expired() -> void:
	shoot_cooldown = _base_shoot_cooldown
	_gun_buff_active = false

func _get_direction_name(dir: Vector2) -> StringName:
	var angle := dir.angle()
	if angle < -7 * PI / 8 or angle > 7 * PI / 8:
		return &"W"
	if angle > PI / 8 and angle <= 3 * PI / 8:
		return &"SE"
	if angle > 3 * PI / 8 and angle <= 5 * PI / 8:
		return &"S"
	if angle > 5 * PI / 8 and angle <= 7 * PI / 8:
		return &"SW"
	if angle < -PI / 8 and angle >= -3 * PI / 8:
		return &"NE"
	if angle < -3 * PI / 8 and angle >= -5 * PI / 8:
		return &"N"
	if angle < -5 * PI / 8 and angle >= -7 * PI / 8:
		return &"NW"
	return &"E"
